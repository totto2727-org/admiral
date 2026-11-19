name = "totto2727/admiral"

version = "0.7.0"

readme = "README.mbt.md"

repository = "https://github.com/totto2727-org/admiral"

license = "MIT"

keywords = [ "cli", "argparse", "moonbit" ]

description = "Async-first declarative CLI builder for MoonBit, inspired by gunshi"

import {
  "moonbitlang/async@0.22.9",
  "moonbitlang/regexp@0.3.7",
  "moonbitlang/x@0.5.7",
  "mizchi/x@0.6.1",
}

preferred_target = "js"

supported_targets = "js+native+wasm"

source = "src"
