# Admiral usage examples

These checked examples back the root [README](../README.mbt.md) for the published `totto2727/admiral` package.

## Typed option

```mbt check
///|
async test "Admiral usage example 1 - passes a typed option to the callback" {
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

## Nested command and environment

```mbt check
///|
async test "Admiral usage example 2 - resolves a nested command option from environment" {
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

## Typed definition

```mbt check
///|
test "Admiral usage example 3 - preserves option metadata" {
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

## Schema rendering

```mbt check
///|
test "Admiral usage example 4 - exposes an option name in the schema" {
  let option = @admiral.string("name", description="User name")
  let app = @admiral.CliApp::CliApp(name="myapp", options=[option])
  let schema = app.render_schema()
  assert_true(schema.contains("name"))
}
```
