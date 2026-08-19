# admiral

Admiral is an async-first declarative CLI module for MoonBit applications that need typed arguments, configuration, interactive input, schema output, and shell completion.

## Usage

Install the module and import the public CLI package:

```moonbit
import {
  "totto2727/admiral@0.6.4",
  "moonbitlang/async@0.20.3",
}
```

See the detailed [Admiral guide](src/README.mbt.md) and [target-file-discovery guide](src/util/target-file-discovery/README.mbt.md) for package-specific examples.

## Key features

- Typed declarative CLI definitions, async command execution, configuration, interactive input, schema rendering, and completion.
- Cross-target asynchronous discovery of named files with inherited `.gitignore` rules.
- JavaScript, native, and Wasm module targets, with JavaScript as the preferred target.

## Prerequisites

- **MoonBit**: Install the MoonBit toolchain.
- **Supported targets**: Use JavaScript, native, or Wasm according to the consuming application.

## Setup

Declare the module in `moon.mod` and import the package in `moon.pkg`:

```moonbit
import {
  "totto2727/admiral@0.6.4",
  "moonbitlang/async@0.20.3",
}

preferred_target = "js"
supported_targets = "js+native"
```

See the package guides for the complete end-user setup and API examples: [Admiral](src/README.mbt.md) and [target-file-discovery](src/util/target-file-discovery/README.mbt.md).

## API

The [Mooncakes Admiral API reference](https://mooncakes.io/docs/totto2727/admiral) is the canonical generated API index for the published CLI package. The [Admiral package guide](src/README.mbt.md) and [target-file-discovery guide](src/util/target-file-discovery/README.mbt.md) explain the representative usage contracts.

## Development

For development guidance, see [AGENTS.md](AGENTS.md).

## License

MIT. See [LICENSE](LICENSE).

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
