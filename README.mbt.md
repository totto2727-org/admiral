# admiral

Admiral is an async-first declarative CLI module for MoonBit applications that need typed arguments, configuration, interactive input, schema output, and shell completion.

## Usage

Build a greeter that passes a required name to its callback. The checked [typed-option example](src/usage_examples.mbt.md#typed-option) verifies that `--name Alice` produces the captured `"Alice"` value.

Use a nested command when it owns an option such as a server port. The checked [nested-command example](src/usage_examples.mbt.md#nested-command-and-environment) verifies that `MYAPP_PORT=8080` reaches the `serve` callback as an `Int`.

For filesystem discovery, the checked [target-file-discovery Usage example](src/util/target-file-discovery/README.mbt.md#usage) creates a temporary `project.toml` and verifies that the helper returns its exact path.

## Key features

- Typed declarative CLI definitions, async command execution, configuration, interactive input, schema rendering, and completion.
- Cross-target asynchronous discovery of named files with inherited `.gitignore` rules.
- JavaScript, native, and Wasm module targets, with JavaScript as the preferred target.

## Prerequisites

- **MoonBit**: Install the MoonBit toolchain.
- **Supported targets**: Use JavaScript, native, or Wasm according to the consuming application.

## Setup

```bash
moon add totto2727/admiral
moon add moonbitlang/async
```

Import the CLI package in a consuming package's `moon.pkg`. It supports JavaScript, native, and linear Wasm without a TUI dependency:

```text
supported_targets = "js+native+wasm"

import {
  "totto2727/admiral" @admiral,
  "moonbitlang/async",
}
```

Import the target-file discovery package from the same module instead when the application needs its JavaScript, native, and Wasm-compatible filesystem helpers:

```text
supported_targets = "js+native+wasm"

import {
  "totto2727/admiral/util/target-file-discovery" @target-file-discovery,
  "moonbitlang/core/async",
}

options(
  "allow-experimental-packages": [ "moonbitlang/core/async" ],
)
```

For the distinct filesystem helper API, see [target-file-discovery](src/util/target-file-discovery/README.mbt.md).

## API

The [Mooncakes Admiral API reference](https://mooncakes.io/docs/totto2727/admiral) is the canonical generated API index for the published CLI package. For the distinct filesystem helper API, see the [target-file-discovery guide](src/util/target-file-discovery/README.mbt.md).

### Defining options and positions

Option and position constructors return typed definitions. The scalar helpers are `string`, `bool`, `int`, `int64`, `uint`, `uint64`, and `double`; each has a repeated form such as `strings` or `doubles`. Position helpers provide the same scalar and repeated numeric families.

Pass the same definition to `CommandDef::CommandDef` or `CliApp::CliApp` and to the matching `Context` getter so the option name remains one type-checked source of truth.

The checked [typed-definition example](src/usage_examples.mbt.md#typed-definition) verifies option metadata and a required positional definition.

### Reading values

`Context` exposes scalar getters such as `get_bool`, `get_string`, `get_int`, `get_int64`, `get_uint`, `get_uint64`, and `get_double`, plus raising `_required` variants. Repeated values use `get_strings`, `get_ints`, `get_int64s`, `get_uints`, `get_uint64s`, and `get_doubles`; their `_required` variants return `NonEmptyArray` and raise when no value is available.

### Environment and configuration

`CliApp::run` reads process arguments and environment by default, while tests and embedders can inject both sources. Values resolve in the order `argv > env > config > default`.

Environment-backed booleans accept `1`, `0`, `true`, `false`, `yes`, `no`, `on`, and `off`; the parsing and precedence rules come from [`moonbitlang/core/argparse`](https://github.com/moonbitlang/core/blob/1332a066d4143511c1b7db58877bc99991f548d6/argparse/command.mbt#L97-L115).

Provide `load_config` when configuration must come from a file or another source. It returns a `Map[String, Json]`, and its keys are the independent `config` names declared on definitions.

### Nested commands and positions

Commands can contain subcommands and each command owns its options, positions, examples, and callback. `Context::get_subcommand()` returns the selected subcommand name and its nested context when a child command was selected.

### Interactive input

Set `interactive` on the option or positional that owns the editor. The editor receives the read-only `Context` and the current value after `argv > env > config > default` resolution. It can replace only its own field. Return `None` to keep the current value. To stop dispatch, raise an error: `CliApp::run` propagates the original error to its caller without invoking the command handler. An editor can supply a missing required value, but dispatch fails if that value is still missing after the editor runs.

```moonbit
let query = @admiral.string("query", env="ADMIRAL_PROJECT_QUERY", config="query")
let project = @admiral.position_string(
  "project",
  required=true,
  interactive=@terminal.project_picker(query),
)
```

In the [terminal example](examples/tui/src/main/main.mbt), the project picker reads `query` from `Context` and returns only the selected `project`. Run it from the repository root with `moon -C examples run --target native ./tui/src/main -- --query lens`. Without a TTY, the [adapter](examples/tui/src/picker/picker.mbt) keeps an explicit project or selects a unique match from the query without prompting. A query with zero or multiple matches is an error when no project was supplied.

Admiral does not check for a TTY or disable editors on Wasm. An application can register a different editor wherever its host provides the required input. The `totto2727/admiral/interactive` package defines the portable `Editor` contract and provides `from_value` for editors that only need the field's current value.

Editors run before the handler, root first and then along the selected command path. Within each scope, options run in declaration order, then positionals. When an editor is registered, it runs even when the field already has a value. Flags pass `Some(false)` when off, and repeated fields pass `None` when empty.

**Migrating from 0.6:** Replace `interactive=true` and the `CliApp` or `CommandDef` interactive callback with an editor on each field. Replace reads through `InteractiveContext::to_context()` with direct `Context` reads and typed setters with the editor's return value.

### Schema and completion

`ToJson::to_json(app)` returns the structured schema, while `render_schema()` returns its string form. `render_bash_completion()`, `render_zsh_completion()`, and `render_fish_completion()` generate shell-specific completion scripts.

The checked [schema-rendering example](src/usage_examples.mbt.md#schema-rendering) verifies that an option name appears in the generated schema.

## Development

For development guidance, see [AGENTS.md](AGENTS.md).
The Nix shell uses `moonbit-bin.latest` from the official [MoonBit community overlay](https://github.com/moonbit-community/moonbit-overlay).
For changes relative to upstream, see [Upstream differences](docs/upstream-differences.md).

## License

MIT. See [LICENSE](LICENSE).

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
