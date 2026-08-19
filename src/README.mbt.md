# admiral

Admiral is the public MoonBit package for declaring typed command-line interfaces with options, positions, nested commands, configuration, completion, and asynchronous execution.

## Usage

The smallest command defines an option, attaches it to a command, and reads the typed value in its callback:

```mbt check
///|
async test "README package usage 1 - runs a typed greeting command" {
  let name = string("name", short='n', required=true)
  let captured = Ref("")
  let app = CliApp::CliApp(name="greeter", commands=[
    CommandDef::CommandDef(
      name="greet",
      options=[name],
      run=Some(ctx => {
        captured.val = ctx.get_string_required(name) catch { _ => "missing" }
      }),
    ),
  ])
  app.run(argv=Some(["greet", "--name", "Alice"]))
  inspect(captured.val, content="Alice")
}
```

## Key features

- Typed scalar and repeated options and positions for strings and numeric values.
- Independent environment and JSON configuration sources with `argv > env > config > default` precedence.
- Asynchronous command callbacks, nested subcommands, and TTY-gated interactive input.
- JSON schema output plus Bash, Zsh, and Fish completion generation.
- Automatic `--help` and `--version`, including help for incomplete command paths.

## Prerequisites

- **MoonBit**: Use a current MoonBit toolchain.
- **Targets**: The package supports JavaScript and native targets.

## Setup

Add Admiral and its async runtime to the consuming module:

```toml
import = [
  "totto2727/admiral@0.6.4",
  "moonbitlang/async@0.20.3",
]
preferred_target = "js"
supported_targets = "js+native"
```

Import the package in the consuming package:

```toml
import = ["totto2727/admiral", "moonbitlang/async"]
```

## API

The [Mooncakes Admiral API reference](https://mooncakes.io/docs/totto2727/admiral) is the canonical generated index for every public type, helper, getter, builder, schema method, and completion method.

### Defining options and positions

Option and position constructors return typed definitions. The scalar helpers are `string`, `bool`, `int`, `int64`, `uint`, `uint64`, and `double`; each has a repeated form such as `strings` or `doubles`. Position helpers provide the same scalar and repeated numeric families.

Pass the same definition to `CommandDef::CommandDef` or `CliApp::CliApp` and to the matching `Context` getter so the option name remains one type-checked source of truth.

```mbt check
///|
test "README package definitions 1 - preserve option metadata" {
  let name = string(
    "name",
    short='n',
    env="MYAPP_NAME",
    config="name",
    required=true,
  )
  let file = position_string("file", config="input", required=true)
  inspect(name.name, content="name")
  debug_inspect(name.metadata.env, content="Some(\"MYAPP_NAME\")")
  inspect(file.name, content="file")
}
```

### Reading values

`Context` exposes scalar getters such as `get_bool`, `get_string`, `get_int`, `get_int64`, `get_uint`, `get_uint64`, and `get_double`, plus raising `_required` variants. Repeated values use `get_strings`, `get_ints`, `get_int64s`, `get_uints`, `get_uint64s`, and `get_doubles`; their `_required` variants return `NonEmptyArray` and raise when no value is available.

### Environment and configuration

`CliApp::run` reads process arguments and environment by default, while tests and embedders can inject both sources. Values resolve in the order `argv > env > config > default`.

Environment-backed booleans accept `1`, `0`, `true`, `false`, `yes`, `no`, `on`, and `off`; the parsing and precedence rules come from [`moonbitlang/core/argparse`](https://github.com/moonbitlang/core/blob/1332a066d4143511c1b7db58877bc99991f548d6/argparse/command.mbt#L97-L115).

Provide `load_config` when configuration must come from a file or another source. It returns a `Map[String, Json]`, and its keys are the independent `config` names declared on definitions.

```mbt check
///|
async test "README package environment 1 - reads an injected environment" {
  let port = int("port", env="MYAPP_PORT")
  let captured = Ref(0)
  let app = CliApp::CliApp(name="server", commands=[
    CommandDef::CommandDef(
      name="serve",
      options=[port],
      run=Some(ctx => captured.val = ctx.get_int(port).unwrap_or(0)),
    ),
  ])
  app.run(argv=Some(["serve"]), env={ "MYAPP_PORT": "8080" })
  inspect(captured.val, content="8080")
}
```

### Nested commands and positions

Commands can contain subcommands and each command owns its options, positions, examples, and callback. `Context::get_subcommand()` returns the selected subcommand name and its nested context when a child command was selected.

### Interactive input

Set `interactive=true` on definitions and provide one callback on the owning command or application. Admiral invokes it only when an opted-in definition is present and a TTY is available. `InteractiveContext::to_context()` exposes initial values, and typed setters replace selected values before the command callback runs.

### Schema and completion

`ToJson::to_json(app)` returns the structured schema, while `render_schema()` returns its string form. `render_bash_completion()`, `render_zsh_completion()`, and `render_fish_completion()` generate shell-specific completion scripts.

```mbt check
///|
test "README package schema 1 - exposes an option name" {
  let option = string("name", description="User name")
  let app = CliApp::CliApp(name="myapp", options=[option])
  let schema = ToJson::to_json(app).stringify()
  assert_true(schema.contains("name"))
}
```

## Development

For development guidance, see [AGENTS.md](../AGENTS.md).

## License

MIT. See [LICENSE](../LICENSE).

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
