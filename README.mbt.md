# admiral

Admiral is an async-first declarative CLI module for MoonBit applications that need typed arguments, configuration, interactive input, schema output, and shell completion.

## Usage

Add Admiral and its async runtime to the consuming module's `moon.mod`:

```text
import {
  "totto2727/admiral@0.6.4",
  "moonbitlang/async@0.20.3",
}

preferred_target = "js"
supported_targets = "js+native+wasm"
```

The checked [Admiral Usage example](src/README.mbt.md#usage) runs `greet --name Alice` and verifies that the callback receives `Alice`. The checked [target-file-discovery Usage example](src/util/target-file-discovery/README.mbt.md#usage) creates a temporary `project.toml` and verifies that home-level discovery returns its exact path.

## Key features

- Typed declarative CLI definitions, async command execution, configuration, interactive input, schema rendering, and completion.
- Cross-target asynchronous discovery of named files with inherited `.gitignore` rules.
- JavaScript, native, and Wasm module targets, with JavaScript as the preferred target.

## Prerequisites

- **MoonBit**: Install the MoonBit toolchain.
- **Supported targets**: Use JavaScript, native, or Wasm according to the consuming application.

## Setup

Import the CLI package in a consuming package's `moon.pkg`. This package supports JavaScript and native targets:

```text
supported_targets = "js+native"

import {
  "totto2727/admiral" @admiral,
  "moonbitlang/async",
}
```

Import the target-file discovery package instead when the application needs its JavaScript, native, and Wasm-compatible filesystem helpers:

```text
supported_targets = "js+native+wasm"

import {
  "totto2727/admiral/util/target-file-discovery" @target-file-discovery,
  "moonbitlang/async",
}
```

See the package guides for the complete end-user setup and API examples: [Admiral](src/README.mbt.md) and [target-file-discovery](src/util/target-file-discovery/README.mbt.md).

## API

The [Mooncakes Admiral API reference](https://mooncakes.io/docs/totto2727/admiral) is the canonical generated API index for the published CLI package. The [Admiral package guide](src/README.mbt.md) and [target-file-discovery guide](src/util/target-file-discovery/README.mbt.md) explain the representative usage contracts.

## Development

For development guidance, see [AGENTS.md](AGENTS.md).

## License

MIT. See [LICENSE](LICENSE).

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
