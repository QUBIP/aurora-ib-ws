set export

default: all

alias info := gatherinfo

provname := "libaurora"
justfile_dir := parent_directory(canonicalize(justfile()))
osslsrcdir := justfile_dir + "/.osslsrcdir"

#build_type := "release"
build_type := "dev"
target := if build_type == "dev" { "target/debug" } else { "target/" + build_type }
OPENSSL_MODULES := justfile_dir + "/" + target

all: test connect_cloudflare

# Run cargo test suite
test:
    cargo test --profile={{build_type}}

# Print some info about the execution environment
gatherinfo:
    cargo version
    @#rustc --version
    pwd
    @#which openssl
    openssl version -a
    env | grep -E 'OPENSSL|OSSL' | sort

# Build the toy provider
build:
    cargo build --profile={{build_type}}

# Run `openssl list` loading the toy provider
list: gatherinfo build
    openssl list -verbose -provider {{provname}}
    openssl list -verbose -providers -provider {{provname}}
    openssl list -verbose -all-algorithms -provider {{provname}}

# Try an s_client connection to cloudflare servers
connect_cloudflare: build
    (echo "GET / HTTP/1.1"; echo "Host: pq.cloudflareresearch.com"; echo ""; sleep 1) | \
    openssl s_client -provider {{provname}} -provider default -groups X25519MLKEM768:SecP256r1MLKEM768 -trace -connect pq.cloudflareresearch.com:443
    #openssl s_client -provider {{provname}} -provider default -groups X25519MLKEM768 -trace -connect pq.cloudflareresearch.com:443

# Try an s_client connection to localhost:4443
connect_localhost: build
    openssl s_client -provider {{provname}} -provider default -groups X25519MLKEM768:SecP256r1MLKEM768:X25519Kyber768Draft00 -trace -connect localhost:4443
    #openssl s_client -provider {{provname}} -provider default -groups X25519MLKEM768 -trace -connect localhost:4443

# Host an s_server instance on localhost:4443
serve_localhost: build
    openssl s_server -provider {{provname}} -provider default -groups SecP256r1MLKEM768 -trace -port 4443 -key {{justfile_dir}}/testcerts/server-key.pem -cert {{justfile_dir}}/testcerts/server.pem
    #openssl s_server -provider {{provname}} -provider default -groups X25519MLKEM768 -trace -port 4443 -key {{justfile_dir}}/testcerts/server-key.pem -cert {{justfile_dir}}/testcerts/server.pem

# Try an s_client connection to localhost:4443 with ML-DSA-65
connect_localhost_mldsa65: build
    openssl s_client -provider {{provname}} -provider default -sigalgs mldsa65 -trace -connect localhost:4443

# Host an s_server instance on localhost:4443 with ML-DSA-65
serve_localhost_mldsa65: build
    openssl s_server -provider {{provname}} -provider default -client_sigalgs mldsa65 -trace -port 4443 -key {{justfile_dir}}/testcerts/server-key.pem -cert {{justfile_dir}}/testcerts/server.pem

# Untar OpenSSL source files for debugger
untar_ossl:
    rm -r "{{osslsrcdir}}"
    mkdir -p "{{osslsrcdir}}"
    tar -x -f "${OPENSSL_SRC_FILES}" --strip-components=1 -C "{{osslsrcdir}}"

# Run GDB
gdb: gatherinfo build untar_ossl
    gdb -d "{{osslsrcdir}}"

# Run GDB preloading `openssl`
gdbossl: gatherinfo build untar_ossl
    gdb -d "{{osslsrcdir}}" --args openssl

# Rust RustGDB with `openssl list`
rustgdbossl: gatherinfo build untar_ossl
    rust-gdb \
        -ex "source gdb_load_rust_pretty_printers.py" \
        -d "{{osslsrcdir}}" \
            -ex "br OSSL_PROVIDER_load" \
            -ex "disable br 1" \
        -s ./target/debug/{{provname}}.so \
            -ex "br aurora::query::query_operation" \
            -ex "disable br 2" \
            -ex "br aurora::adapters::libcrux::AdapterContext::get_op_kem" \
            -ex "disable br 3" \
            -ex "br aurora::adapters::libcrux::AdapterContext::get_op_keymgmt" \
            -ex "disable br 4" \
            -ex "br aurora::adapters::libcrux::X25519MLKEM768Draft00::kem_functions::decapsulate" \
        --args \
            openssl s_client -provider {{provname}} -provider default -groups X25519MLKEM768 -connect pq.cloudflareresearch.com:443
#            "$(which openssl)" list -verbose -all-algorithms -provider {{provname}}

# Run `list` under valgrind to check for memory leaks
valgrind-list: gatherinfo build
    valgrind --leak-check=full -s -- openssl list -providers -verbose -provider {{provname}}

# Use nix to build the runner container image
dockerImage-runner-nix-build:
    nix build .#dockerImage-runner

# Load nix result as a podman image
dockerImage-runner-podman-load: dockerImage-runner-nix-build
    zstdcat result | podman load

# Push the container image to dockerhub
dockerImage-runner-push-dockerhub:
    podman tag localhost/qubip-ossl-rust-runner:latest-nix docker.io/nisectuni/qubip-ossl-rust-runner:latest-nix
    podman push docker.io/nisectuni/qubip-ossl-rust-runner:latest-nix

# Push the container image to private gitlab registry
dockerImage-runner-push-gitlab:
    podman tag localhost/qubip-ossl-rust-runner:latest-nix registry.gitlab.com/nisec/qubip/registries/nisectuni/qubip-ossl-rust-runner:latest-nix
    podman push registry.gitlab.com/nisec/qubip/registries/nisectuni/qubip-ossl-rust-runner:latest-nix

# Push the container image to registries
dockerImage-runner-push: dockerImage-runner-push-dockerhub dockerImage-runner-push-gitlab

# Run an interactive shell within the dockerhub container (e.g. `just dockerImage-runner-interactive` or `just dockerImage-runner-interactive just gatherinfo`)
dockerImage-runner-interactive +ARGS='':
    podman run --rm -it -v $PWD:/srcs --workdir /srcs --pull newer docker.io/nisectuni/qubip-ossl-rust-runner:latest-nix {{ARGS}}
