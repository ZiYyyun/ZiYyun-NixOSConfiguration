# Programming Toolchains

This repository keeps project-oriented programming environments in `dev_toolchains/dev_compliers/`.
Reusable programming package groups are centralized in `dev_toolchains/libs/libs_cmp_packages.nix`.

## Entrypoints

```bash
nix develop
nix develop .#c
nix develop .#cpp
nix develop .#c-cpp
nix develop .#rust
nix develop .#python
nix develop .#node
nix develop .#go
nix develop .#java
nix develop .#dotnet
```

`nix develop`, `.#c`, `.#cpp`, and `.#c-cpp` currently enter the same C/C++ environment.

## Where To Edit

| Need | File |
| --- | --- |
| Add a package shared by every programming shell | `dev_toolchains/libs/libs_cmp_packages.nix`, group `programmingCommon` |
| Add a C/C++ library or tool | `dev_toolchains/libs/libs_cmp_packages.nix`, group `cFamily` |
| Add a Rust/Python/Node/Go/Java/.NET tool | `dev_toolchains/libs/libs_cmp_packages.nix`, matching programming group |
| Change shell variables or the welcome message | `dev_toolchains/dev_compliers/<name>.nix` |
| Add a new flake shell output | `flake.nix`, `devShells.${system}` |

## C / C++ / pthread / clangd

The C/C++ shell lives in:

```text
dev_toolchains/dev_compliers/dev_cmp_c-cpp.nix
```

It uses package group:

```text
dev_toolchains/libs/libs_cmp_packages.nix -> cFamily
```

Included tools and libraries:

- `clang`
- `clang-tools`
- `gcc`
- `glibc`
- `glibc.dev`
- `linuxHeaders`
- `libmodbus`
- `paho-mqtt-c`
- `openssl`
- `zlib`
- `gdb`
- `lldb`
- `cmake`
- `ninja`
- `bear`
- `valgrind`
- `boost`
- `fmt`
- `spdlog`

`pthread.h` comes from `glibc.dev`. For VS Code + clangd, enter the shell first:

```bash
nix develop .#c
code .
```

When compiling pthread code, still pass `-pthread`:

```bash
clang main.c -pthread -o main
```

For CMake projects, generate `compile_commands.json`:

```bash
cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -sf build/compile_commands.json compile_commands.json
```

For Makefile projects:

```bash
bear -- make
```

## Package Groups

programming package groups are intentionally collected in one file:

```text
dev_toolchains/libs/libs_cmp_packages.nix
```

Current groups:

- `programmingCommon`
- `cFamily`
- `rust`
- `python`
- `node`
- `go`
- `java`
- `dotnet`

This mirrors the embedded shell layout, but programming and embedded package groups stay in separate files.
