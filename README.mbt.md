# admiral

Admiral is an async-first declarative CLI module for MoonBit applications that need typed arguments, configuration, interactive input, schema output, and shell completion.

## Usage

```mbt check
///|
async test "README usage 1 - passes a typed option to the callback" {
  let name = @admiral.string("name", required=true)
  let captured = Ref("")
  let app = @admiral.CliApp::CliApp(
    name="greeter",
    options=[name],
    run=Some(ctx => {
      captured.val = ctx.get_string_required(name) catch { _ => "missing" }
    }),
  )
  app.run(argv=Some(["--name", "Alice"]))
  inspect(captured.val, content="Alice")
}
```

For filesystem discovery, the checked [target-file-discovery Usage example](src/util/target-file-discovery/README.mbt.md#usage) creates a temporary `project.toml` and verifies that the helper returns its exact path.

## Key features

- Typed declarative CLI definitions, async command execution, configuration, interactive input, schema rendering, and completion.
- Cross-target asynchronous discovery of named files with inherited `.gitignore` rules.
- JavaScript, native, and Wasm module targets, with JavaScript as the preferred target.

## Prerequisites

- **MoonBit**: Install the MoonBit toolchain.
- **Supported targets**: Use JavaScript, native, or Wasm according to the consuming application.

## Setup

Add Admiral and its async runtime to the consuming module's `moon.mod`:

```text
import {
  "totto2727/admiral@0.6.4",
  "moonbitlang/async@0.20.3",
}

preferred_target = "js"
supported_targets = "js+native+wasm"
```

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

See the package guides for their distinct APIs: [Admiral](src/README.mbt.md) and [target-file-discovery](src/util/target-file-discovery/README.mbt.md).

## API

The [Mooncakes Admiral API reference](https://mooncakes.io/docs/totto2727/admiral) is the canonical generated API index for the published CLI package. The [Admiral package guide](src/README.mbt.md) and [target-file-discovery guide](src/util/target-file-discovery/README.mbt.md) explain the representative usage contracts.

## Development

For development guidance, see [AGENTS.md](AGENTS.md).

## License

MIT. See [LICENSE](LICENSE).

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
