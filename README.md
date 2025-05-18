<div align="center">

# <img src="https://raw.githubusercontent.com/nim-lang/assets/master/Art/logo-crown.png" height="28px"/> wayland-nim

Nim bindings for wayland

 </div>

Target: libwayland 1.23.1, wayland-protocols 1.44

> [!WARNING]
> * The project is in the early stages of development and disruptive changes to the API are expected.

## Features

* It is a simple implementation of libwayland with the prefix removed. It can be easily migrated.
* Both server and client APIs are available.
* It comes with `wayland-nim-scanner` that generates glue codes for protocols like `wayland-scanner`.
* All wayland-protocols (stable, staging, unstable) are pre-converted and included in the package.
* The binding has been tested with the same contents as libwayland and is practicable.
* The majority of the bindings are generated automatically and can easily be adjusted to the desired libwayland version by yourself.  See [generator/generator.nim].
## Installation

To install manually:

```console
$ nimble install https://github.com/panno8M/wayland-nim
```

Via .nimble:

```nim
# *.nimble
requires "https://github.com/panno8M/wayland-nim"
```

[generator/generator.nim]: https://github.com/panno8M/wayland-nim/tree/master/generator/generator.nim