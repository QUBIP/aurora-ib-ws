<div align="center">

  `aurora` workspace for the Internet Browsing pilot

  <br />
  <a href="#about"><strong>Explore the docs »</strong></a>
  <br />
  <br />
  <a href="https://github.com/qubip/aurora-ib-ws/issues/new?assignees=&labels=bug&template=01_BUG_REPORT.md&title=bug%3A+">Report a Bug</a>
  ·
  <a href="https://github.com/qubip/aurora-ib-ws/issues/new?assignees=&labels=enhancement&template=02_FEATURE_REQUEST.md&title=feat%3A+">Request a Feature</a>
  ·
  <a href="https://github.com/qubip/aurora-ib-ws/issues/new?assignees=&labels=question&template=04_SUPPORT_QUESTION.md&title=support%3A+">Ask a Question</a>
</div>

<div align="center">
<br />

[![Project license](https://img.shields.io/github/license/qubip/aurora-ib-ws.svg?style=flat-square)][LICENSE]

[![Pull Requests welcome](https://img.shields.io/badge/PRs-welcome-ff69b4.svg?style=flat-square)](https://github.com/qubip/aurora-ib-ws/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22)
[![code with love by qubip](https://img.shields.io/badge/%3C%2F%3E%20with%20%E2%99%A5%20by-qubip%2Fnisec-ff1414.svg?style=flat-square)](https://github.com/orgs/QUBIP/teams/nisec)

</div>

> [!CAUTION]
>
> ### Development in Progress
>
> This project is **currently in development** and **not yet ready for production use**.
>
> **Expect changes** to occur from time to time, and at this stage, some features may be unavailable.

<details open="open">
<summary>Table of Contents</summary>

- [About](#about)
<!--
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
!-->
<!--
- [Usage](#usage)
!-->
- [Roadmap](#roadmap)
- [Support](#support)
- [Project assistance](#project-assistance)
- [Contributing](#contributing)
- [Authors & contributors](#authors--contributors)
- [Security](#security)
- [License](#license)
- [Acknowledgements](#acknowledgements)

</details>

---

## About

**_A Rust workspace to build
an [OpenSSL Provider](ossl:man:provider)
based on [`aurora`][link:aurora]
for the Internet Browsing pilot of
[QUBIP](https://qubip.eu)._**

> [!WARNING]
> **This repository uses [submodules][git:submodules]!**
>
> Clone it using `git clone --recursive`, or remember to
> `git submodule update --init` after cloning.

The purpose of this repository is to aid in the development
of the [OpenSSL Provider](ossl:man:provider)
for the Internet Browsing pilot of
[QUBIP](https://qubip.eu).

It uses [`git-submodules`][git:submodules] to tie together specific revisions of [`aurora`][link:aurora] and [`openssl_provider_forge`][link:openssl_provider_forge].

[git:submodules]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
[link:aurora]: ./aurora
[link:openssl_provider_forge]: ./openssl-provider-forge-rs

### Submodules

- [`aurora`][link:aurora] is a Rust implementation of an OpenSSL provider, tailored for the PQC transition.
- [`openssl-provider-forge-rs`][link:openssl_provider_forge] contains Rust code that is needed _in order to_
  write an OpenSSL provider in Rust (like [`aurora`][link:aurora] but possibly also others).
  This includes FFI-compatible Rust representations of the relevant C constants,
  structs, etc. that are defined in various OpenSSL header files (e.g. the
  `OSSL_PARAM` struct and the C enum it uses internally in the `data_type`
  field), as well as some pure Rust macros that are useful when writing a
  provider (e.g. a macro for creating dispatch table entries from function
  pointers).

### Building and testing using `podman` (or Docker if you tweak the commands)

We have a Container image published
[on DockerHub][dockerImage-nix:dockerhub]
that has a minimal
system to build and test this project.

The `justfile` includes a convenience target to run either an
interactive shell session within the container, or specific commands.

```sh
just dockerImage-runner-interactive
```

or (for example)

```sh
just dockerImage-runner-interactive just gatherinfo
```

This assumes a working `podman` installation.

[bindgen]: https://crates.io/crates/bindgen
[rust-openssl]: https://github.com/sfackler/rust-openssl
[dockerImage-nix:dockerhub]: https://hub.docker.com/repository/docker/nisectuni/qubip-ossl-rust-runner/tags/latest-nix/sha256-9dae631cf7005f9117830777e6b54acac157eb5650536de37ed6c8690b361ab7
[dockerImage-nix:gitlab]: https://gitlab.com/groups/nisec/qubip/registries/nisectuni/-/container_registries/8151798

<!--
## Getting Started

### Prerequisites

> **[?]**
> What are the project requirements/dependencies?

### Installation

> **[?]**
> Describe how to install and get started with the project.
!-->

<!--
## Usage

> **[?]**
> How does one go about using it?
> Provide various use cases and code examples here.
!-->

## Roadmap

See the [open issues](https://github.com/qubip/aurora-ib-ws/issues) for a list of proposed features (and known issues).

- [Top Feature Requests](https://github.com/qubip/aurora-ib-ws/issues?q=label%3Aenhancement+is%3Aopen+sort%3Areactions-%2B1-desc) (Add your votes using the 👍 reaction)
- [Top Bugs](https://github.com/qubip/aurora-ib-ws/issues?q=is%3Aissue+is%3Aopen+label%3Abug+sort%3Areactions-%2B1-desc) (Add your votes using the 👍 reaction)
- [Newest Bugs](https://github.com/qubip/aurora-ib-ws/issues?q=is%3Aopen+is%3Aissue+label%3Abug)

## Support

Reach out to the maintainers at one of the following places:

- [GitHub issues](https://github.com/qubip/aurora-ib-ws/issues/new?assignees=&labels=question&template=04_SUPPORT_QUESTION.md&title=support%3A+)
- <security@romen.dev> to disclose security issues according to our [security documentation](docs/SECURITY.md).
- <coc@romen.dev> to report violations of our [Code of Conduct](docs/CODE_OF_CONDUCT.md).
- Details about the GPG keys to encrypt reports are included in our [security documentation](docs/SECURITY.md).

## Project assistance

If you want to say **thank you** or/and support active development:

- Add a [GitHub Star](https://github.com/qubip/aurora-ib-ws) to the project.
- Mention this project on your social media of choice.
- Write interesting articles about the project, and cite us.

Together, we can make Aurora **better**!

## Contributing

The GitHub repository primarily serves as a mirror,
and will be updated every time a new version of Aurora is released.
It might not always be updated with the latest commits in between releases.
However, contributions are still very welcome!

Please read [our contribution guidelines](docs/CONTRIBUTING.md), and thank you for being involved!

## Authors & contributors

The original setup of this repository is by [NISEC](https://github.com/orgs/QUBIP/teams/nisec).

For a full list of all authors and contributors, see [the contributors page](https://github.com/qubip/aurora-ib-ws/contributors).

## Security

In this project, we aim to follow good security practices, but 100% security cannot be assured.
This project is provided **"as is"** without any **warranty**. Use at your own risk.

_For more information and to report security issues, please refer to our [security documentation](docs/SECURITY.md)._

## License

This project is licensed under the
[**Apache License, Version 2.0**](https://www.apache.org/licenses/LICENSE-2.0)
([Apache-2.0](https://spdx.org/licenses/Apache-2.0.html)).

```text
Copyright 2023-2025 Tampere University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

See [LICENSE][LICENSE] for more information.

[LICENSE]: LICENSE

## Acknowledgements

This work has been developed within the QUBIP project (https://www.qubip.eu),
funded by the European Union under the Horizon Europe framework programme
[grant agreement no. 101119746](https://doi.org/10.3030/101119746).
