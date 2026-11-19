///|
async test "editors receive effective argv, environment, config, and default values" {
  let query = @admiral.string(
    "query",
    config="query",
    env="QUERY",
    default=Some("default-query"),
    interactive=(_, current) => {
      assert_true(current is Some("argv-query"))
      Some("edited-query")
    },
  )
  let profile = @admiral.string(
    "profile",
    config="profile",
    env="PROFILE",
    default=Some("default-profile"),
    interactive=(_, current) => {
      assert_true(current is Some("env-profile"))
      None
    },
  )
  let region = @admiral.string(
    "region",
    config="region",
    default=Some("default-region"),
    interactive=(_, current) => {
      assert_true(current is Some("config-region"))
      None
    },
  )
  let limit = @admiral.int("limit", default=Some(10), interactive=(_, current) => {
    current.map(n => n + 1)
  })
  let project = @admiral.position_string("project", interactive=(ctx, current) => {
    assert_true(current is Some("argv-project"))
    Some(ctx.get_string_required(query) + "-project")
  })
  let app = @admiral.CliApp::CliApp(
    name="demo",
    commands=[
      @admiral.CommandDef::CommandDef(
        name="select",
        options=[query, profile, region, limit],
        positionals=[project],
        run=Some(ctx => {
          inspect(
            ctx.get_string_required(project),
            content="edited-query-project",
          )
          inspect(ctx.get_string_required(query), content="edited-query")
          inspect(ctx.get_string_required(profile), content="env-profile")
          inspect(ctx.get_string_required(region), content="config-region")
          inspect(ctx.get_int_required(limit), content="11")
        }),
      ),
    ],
    load_config=Some(() => {
      "query": Json::string("config-query"),
      "profile": Json::string("config-profile"),
      "region": Json::string("config-region"),
    }),
  )
  app.run(argv=Some(["select", "argv-project", "--query", "argv-query"]), env={
    "QUERY": "env-query",
    "PROFILE": "env-profile",
  })
}

///|
async test "an editor can supply a required option or positional" {
  let profile = @admiral.string("profile", required=true, interactive=(
    _,
    current,
  ) => {
    assert_true(current is None)
    Some("chosen-profile")
  })
  let project = @admiral.position_string("project", required=true, interactive=(
    _,
    current,
  ) => {
    assert_true(current is None)
    Some("chosen-project")
  })
  let app = @admiral.CliApp::CliApp(
    name="demo",
    options=[profile],
    positionals=[project],
    run=Some(ctx => {
      inspect(ctx.get_string_required(profile), content="chosen-profile")
      inspect(ctx.get_string_required(project), content="chosen-project")
    }),
  )
  app.run(argv=Some([]), env={})
}

///|
async test "empty edits cannot satisfy a required field and errors abort dispatch" {
  let ran = Ref(false)
  let files = @admiral.strings("files", required=true, interactive=(_, _) => {
    Some([])
  })
  let missing = @admiral.CliApp::CliApp(
    name="demo",
    options=[files],
    run=Some(_ => ran.val = true),
  )
  let outcome = Ok(missing.run(argv=Some(["--files", "before"]), env={})) catch {
    err => Err(err)
  }
  assert_true(outcome is Err(Failure(_)))
  let project = @admiral.position_string("project", interactive=(_, _) => {
    fail("selection cancelled")
  })
  let cancelled = @admiral.CliApp::CliApp(
    name="demo",
    positionals=[project],
    run=Some(_ => ran.val = true),
  )
  let outcome = Ok(cancelled.run(argv=Some(["before"]), env={})) catch {
    err => Err(err)
  }
  assert_true(outcome is Err(Failure(_)))
  assert_false(ran.val)
}

///|
async test "optional typed editors can replace flags and lists with false and empty" {
  let verbose = @admiral.bool(
    "verbose",
    interactive=@interactive.from_value(current => {
      assert_true(current is Some(true))
      Some(false)
    }),
  )
  let values = @admiral.ints("values", config="values", interactive=(_, current) => {
    assert_true(current is Some([3]))
    Some([])
  })
  let app = @admiral.CliApp::CliApp(
    name="demo",
    options=[verbose, values],
    load_config=Some(() => { "values": Json::array([Json::number(3)]) }),
    run=Some(ctx => {
      assert_false(ctx.get_bool(verbose))
      assert_true(ctx.get_ints(values).is_empty())
    }),
  )
  app.run(argv=Some(["--verbose"]), env={})
}

///|
async test "root option changes reach selected leaf and sibling editors never run" {
  let profile = @admiral.string("profile", interactive=(_, _) => Some("global"))
  let leaf = @admiral.string("local", interactive=(ctx, _) => {
    Some(ctx.get_string_required(profile) + "-leaf")
  })
  let unused = @admiral.string("unused", interactive=(_, _) => {
    fail("unselected command")
  })
  let app = @admiral.CliApp::CliApp(name="demo", options=[profile], commands=[
    @admiral.CommandDef::CommandDef(name="project", subcommands=[
      @admiral.CommandDef::CommandDef(
        name="show",
        options=[leaf],
        run=Some(ctx => {
          inspect(ctx.get_string_required(profile), content="global")
          inspect(ctx.get_string_required(leaf), content="global-leaf")
        }),
      ),
      @admiral.CommandDef::CommandDef(name="hide", options=[unused]),
    ]),
  ])
  app.run(argv=Some(["project", "show"]), env={})
}
