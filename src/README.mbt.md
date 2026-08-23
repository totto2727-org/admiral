# admiral

Admiral is the public MoonBit package for declaring typed command-line interfaces with options, positions, nested commands, configuration, completion, and asynchronous execution.

The module [README](../README.mbt.md) owns installation and the baseline typed-option example. This package supports JavaScript and native targets and owns the typed CLI API documented below.

## Usage

Use a nested command when the selected command has its own option set. This example reads a port from the command-specific environment variable and passes the resolved typed value to the callback.

```mbt check
///|
async test "README package usage 1 - reads an injected environment value" {
  let port = @admiral.int("port", env="MYAPP_PORT")
  let captured = Ref(0)
  let app = @admiral.CliApp::CliApp(name="server", commands=[
    @admiral.CommandDef::CommandDef(
      name="serve",
      options=[port],
      run=Some(ctx => captured.val = ctx.get_int(port).unwrap_or(0)),
    ),
  ])
  app.run(argv=Some(["serve"]), env={ "MYAPP_PORT": "8080" })
  inspect(captured.val, content="8080")
}
```

## API

The [Mooncakes Admiral API reference](https://mooncakes.io/docs/totto2727/admiral) is the canonical generated index for every public type, helper, getter, builder, schema method, and completion method.

### Defining options and positions

Option and position constructors return typed definitions. The scalar helpers are `string`, `bool`, `int`, `int64`, `uint`, `uint64`, and `double`; each has a repeated form such as `strings` or `doubles`. Position helpers provide the same scalar and repeated numeric families.

Pass the same definition to `CommandDef::CommandDef` or `CliApp::CliApp` and to the matching `Context` getter so the option name remains one type-checked source of truth.

```mbt check
///|
test "README package definitions 1 - preserve option metadata" {
  let name = @admiral.string(
    "name",
    short='n',
    env="MYAPP_NAME",
    config="name",
    required=true,
  )
  let file = @admiral.position_string("file", config="input", required=true)
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

### Nested commands and positions

Commands can contain subcommands and each command owns its options, positions, examples, and callback. `Context::get_subcommand()` returns the selected subcommand name and its nested context when a child command was selected.

### Interactive input

Set `interactive=true` on definitions and provide one callback on the owning command or application. Admiral invokes it only when an opted-in definition is present and a TTY is available. `InteractiveContext::to_context()` exposes initial values, and typed setters replace selected values before the command callback runs.

### Schema and completion

`ToJson::to_json(app)` returns the structured schema, while `render_schema()` returns its string form. `render_bash_completion()`, `render_zsh_completion()`, and `render_fish_completion()` generate shell-specific completion scripts.

```mbt check
///|
test "README package schema 1 - exposes an option name" {
  let option = @admiral.string("name", description="User name")
  let app = @admiral.CliApp::CliApp(name="myapp", options=[option])
  let schema = app.render_schema()
  assert_true(schema.contains("name"))
}
```

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
