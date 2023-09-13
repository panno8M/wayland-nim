# Package

version       = "1.22.0"
author        = "la .panon."
description   = "The Wayland binding with utilities"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]

namedBin["wayland/tools/waylandNimScanner"] = "wayland-nim-scanner"
binDir = "bin"


# Dependencies

requires "nim >= 2.0.0"
requires "https://github.com/panno8M/nim-beyond >= 0.21.0"
