///|
test "build_command converts simple command" {
  let cmd = @admiral.CommandDef::CommandDef(
    name="greet",
    description="Greet someone",
    options=[
      @admiral.string(
        "name",
        short='n',
        description="Name to greet",
        required=true,
      ),
      @admiral.bool("verbose", short='v', description="Verbose output"),
      @admiral.int(
        "count",
        short='c',
        description="Repeat count",
        default=Some(1),
      ),
      @admiral.int64("offset", description="Signed 64-bit offset"),
      @admiral.uint("retries", description="Unsigned count"),
      @admiral.uint64("limit", description="Unsigned 64-bit limit"),
      @admiral.double("ratio", description="Floating-point ratio"),
    ],
    run=Some(fn(_ctx) { () }),
  )
  let argparse_cmd = @admiral.build_command(cmd)
  let help = argparse_cmd.render_help()
  inspect(help.contains("greet"), content="true")
  inspect(help.contains("--name"), content="true")
  inspect(help.contains("--verbose"), content="true")
  inspect(help.contains("--count"), content="true")
  inspect(help.contains("--offset"), content="true")
  inspect(help.contains("--retries"), content="true")
  inspect(help.contains("--limit"), content="true")
  inspect(help.contains("--ratio"), content="true")
}

///|
test "build_command converts nested subcommands" {
  let sub = @admiral.CommandDef::CommandDef(
    name="serve",
    description="Start server",
    options=[@admiral.int("port", short='p', description="Port")],
    run=Some(fn(_ctx) { () }),
  )
  let root = @admiral.CommandDef::CommandDef(name="app", description="My app", subcommands=[
    sub,
  ])
  let argparse_cmd = @admiral.build_command(root)
  let help = argparse_cmd.render_help()
  inspect(help.contains("serve"), content="true")
}

///|
test "build_command exposes configured option environment variables in help" {
  let cmd = @admiral.CommandDef::CommandDef(
    name="greet",
    description="Greet someone",
    options=[
      @admiral.string("name", description="Name to greet", env="APP_NAME"),
      @admiral.string("output", description="Output path"),
    ],
    run=Some(fn(_ctx) { () }),
  )
  let help = @admiral.build_command(cmd).render_help()
  inspect(help.contains("APP_NAME"), content="true")
  inspect(help.contains("Output path [env:"), content="false")
}
