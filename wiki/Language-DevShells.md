# Language DevShells

本仓库把常用语言开发环境放在 `shells/languages/`，通过 Flake `devShells` 进入。

## 入口

```bash
nix develop
nix develop .#c
nix develop .#cpp
nix develop .#rust
nix develop .#python
nix develop .#node
nix develop .#go
nix develop .#java
nix develop .#dotnet
```

`nix develop` 默认等同于 `nix develop .#c`。

## C / pthread / clangd

C shell 在 `shells/languages/c.nix`，包含：

- `clang`
- `clang-tools`
- `glibc`
- `glibc.dev`
- `linuxHeaders`
- `gdb`
- `lldb`
- `cmake`
- `ninja`
- `bear`
- `valgrind`

`pthread.h` 来自 `glibc.dev`。只在系统包里安装 `glibc`，不一定能让 VS Code + clangd 在项目里找到头文件；项目开发时应进入 shell：

```bash
nix develop .#c
code .
```

pthread 程序编译时仍然需要 `-pthread`：

```bash
clang main.c -pthread -o main
```

如果项目使用 CMake，建议生成 `compile_commands.json`：

```bash
cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -sf build/compile_commands.json compile_commands.json
```

如果项目使用 Makefile，可以用 `bear` 生成：

```bash
bear -- make
```

clangd 优先读 `compile_commands.json`。没有这个文件时，它只能猜编译参数，在 Nix 环境下更容易找不到 libc、pthread 或第三方库头文件。

## C++

C++ shell 在 `shells/languages/cpp.nix`，在 C shell 基础上增加：

- `boost`
- `fmt`
- `spdlog`

入口：

```bash
nix develop .#cpp
```

## Rust

Rust shell 在 `shells/languages/rust.nix`，包含：

- `rustup`
- `rustc`
- `cargo`
- `rust-analyzer`
- `clippy`
- `rustfmt`
- 常见 native build 依赖

入口：

```bash
nix develop .#rust
```

## Python

Python shell 在 `shells/languages/python.nix`，包含：

- `python3`
- `uv`
- `pip`
- `virtualenv`
- `ipython`
- `ruff`
- `pyright`

入口：

```bash
nix develop .#python
```

## Node.js

Node shell 在 `shells/languages/node.nix`，包含：

- `nodejs`
- `pnpm`
- `yarn`
- `typescript`
- `typescript-language-server`
- `eslint`
- `prettier`

入口：

```bash
nix develop .#node
```

默认 npm registry 配到 `https://registry.npmmirror.com`。

## Go

Go shell 在 `shells/languages/go.nix`，包含：

- `go`
- `gopls`
- `delve`
- `gotools`
- `golangci-lint`

入口：

```bash
nix develop .#go
```

默认 `GOPROXY` 配到 `https://goproxy.cn,direct`。

## Java

Java shell 在 `shells/languages/java.nix`，包含：

- `jdk`
- `maven`
- `gradle`
- `jdt-language-server`

入口：

```bash
nix develop .#java
```

## .NET

.NET shell 在 `shells/languages/dotnet.nix`，包含：

- `dotnet-sdk`
- `csharp-ls`

入口：

```bash
nix develop .#dotnet
```
