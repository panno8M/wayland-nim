# Package

version       = "0.1.0"
author        = "la.panon."
description   = "libwayland wrapper"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
namedBin      = {"wayland/scanner": "wayland-nim-scanner"}.toTable
binDir        = "bin"


# Dependencies

requires "nim >= 2.2.2"
