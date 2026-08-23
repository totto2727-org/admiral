name = "totto2727/admiral"

version = "0.6.5"

readme = "README.mbt.md"

repository = "https://github.com/totto2727-org/admiral"

license = "MIT"

keywords = [ "cli", "argparse", "moonbit" ]

description = "Async-first declarative CLI builder for MoonBit, inspired by gunshi"

import {
  "moonbitlang/async@0.21.0",
  "moonbitlang/x@0.5.1",
  "mizchi/tui@0.10.1",
  "totto2727/lens@0.4.3",
  "mizchi/x@0.5.3",
}

preferred_target = "js"

supported_targets = "js+native+wasm"

source = "src"
