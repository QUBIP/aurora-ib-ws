{
  inputs = {
    #nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    #nixpkgs.follows = "nixpkgs-stable";
    nixpkgs.follows = "romen/nixpkgs";

    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";

    utils.url = "github:numtide/flake-utils";

    romen.url = "git+https://gitlab.com/nicola_tuveri_group/nix-tests/my-flakes.git?ref=master";
    #romen.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    naersk,
    romen,
    ...
  } @ inputs:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      naersk-lib = pkgs.callPackage naersk {};
      romen = inputs.romen.packages.${system};

      myopenssl = romen.openssl_3_2;
      #myopenssl = romen.openssl_3_2_with_oqs-provider;

      cc = pkgs.clangStdenv.cc;
      aurora-nativeBuildInputs =
        [
          cc
          pkgs.rust-bindgen
          pkgs.rustPlatform.bindgenHook
          pkgs.pkg-config
          pkgs.git
          myopenssl
          myopenssl.dev
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
          # Additional darwin specific inputs can be set here
          pkgs.libiconv
        ];

      aurora-naersk = naersk-lib.buildPackage {
        gitSubmodules = true;
        gitAllRefs = true;
        src = self;
        root = self;
        copyLibs = true;
        release = false;
        doDoc = true;
        doDocFail = true;

        CARGO_PROFILE_DEV_BUILD_OVERRIDE_DEBUG = true;
        RUST_BACKTRACE = "full";

        nativeBuildInputs = aurora-nativeBuildInputs;

        #preBuild = ''
        #  echo "PWD: $(pwd)"
        #  ls -la
        #  echo "$(git describe --tags)"

        #  cd aurora
        #  echo "PWD: $(pwd)"
        #  ls -la
        #  echo "$(git describe --tags)"
        #'';
      };
      aurora = aurora-naersk;

      dockerImage-runner = pkgs.dockerTools.buildImage {
        name = "qubip-ossl-rust-runner";
        tag = "latest-nix";
        compressor = "zstd";
        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths =
            aurora-nativeBuildInputs
            ++ (with pkgs; [
              cargo
              rustc
              rustfmt
              rustPackages.clippy
              just
              coreutils
              bashInteractive
              bash-completion
              which
              readline
              cacert
              libclang
              libclang.lib
              findutils
              tree
              eza
              gnugrep
              file
            ]);
        };
        runAsRoot = ''
          #!${pkgs.runtimeShell}
          mkdir -p /tmp
        '';
        config = {
          Cmd = ["/bin/bash"];
          Env = let
            lib = pkgs.lib;
            ccVer = lib.getVersion cc.cc;
            ccMajorVer = builtins.elemAt (lib.splitVersion ccVer) 0;
          in
            with pkgs; [
              "LIBCLANG_PATH=${libclang.lib}/lib"
              "PKG_CONFIG_PATH=/lib/pkgconfig"
              "BINDGEN_EXTRA_CLANG_ARGS=-idirafter\"${cc.cc.lib}/lib/clang/${ccMajorVer}/include\" -idirafter\"${cc.libc.dev}/include\""
            ];
        };
      };
    in {
      formatter = pkgs.alejandra;
      packages = rec {
        inherit myopenssl;
        inherit aurora;
        inherit dockerImage-runner;
        default = aurora;
      };

      #apps = rec {
      #    gdb = {
      #        type = "app";
      #        #program = "${pkgs.gdb}/bin/gdb -ex 'dir ${myopenssl.src}'";
      #        program = "${pkgs.gdb}/bin/gdb";
      #    };
      #    default = gdb;
      #};

      devShells = {
        default = with pkgs;
          mkShell {
            buildInputs =
              [
                romen.openssl_3_2_with_oqs-provider
                pkg-config
                cargo
                rustc
                rustfmt
                pre-commit
                rustPackages.clippy
                myopenssl
                myopenssl.dev
                just
                rustPlatform.bindgenHook
                nixpkgs-fmt

                neovim
                ruby
                python311Packages.nodeenv
                lazygit
                git-cliff
              ]
              ++ (
                if pkgs.stdenv.isLinux
                then [
                  gdb
                  valgrind
                  dive
                ]
                else if pkgs.stdenv.isDarwin
                then []
                else []
              )
              ++ aurora.nativeBuildInputs;
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
            RUST_BACKTRACE = "full";
            #RUST_LOG = "trace";
            RUST_LOG = "debug";
            #OPENSSL_MODULES = "./result/lib";
            OPENSSL_DEV_DIR = myopenssl.dev;
            OPENSSL_MODULES = "./target/debug";
            OPENSSL_SRC_FILES = myopenssl.src;
            OPENSSL_PFX = myopenssl;
            OPENSSL_CONF = "/dev/null";
            OQSPROVIDER_PATH = myopenssl.out.outPath + "/lib/ossl-modules/oqsprovider.so";
            GDB_CUSTOM_ARGS = "-d ${myopenssl.src}";
          };
      };
    });
}
