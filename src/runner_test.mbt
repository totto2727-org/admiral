///|
async test "cli creates CliApp and run executes async command" {
  let called = Ref(false)
  let captured_name = Ref("")
  let app = cli(
    name="test-app",
    version="1.0.0",
    description="Test application",
    commands=[
      command(
        name="greet",
        description="Greet someone",
        options=[string("name", short='n', description="Name", required=true)],
        run=Some(async fn(ctx) {
          @async.sleep(0)
          called.val = true
          captured_name.val = ctx.get_string_required("name") catch {
            _ => "error"
          }
        }),
      ),
    ],
  )
  app.run(argv=Some(["greet", "--name", "alice"]))
  inspect(called.val, content="true")
  inspect(captured_name.val, content="alice")
}

///|
async test "explicit argv preserves configured defaults" {
  let captured = Ref("")
  let app = cli(name="test-app", commands=[
    command(
      name="greet",
      options=[string("name", default=Some("fallback"))],
      run=Some(fn(ctx) {
        captured.val = ctx.get_string_required("name") catch { _ => "error" }
      }),
    ),
  ])
  app.run(argv=Some(["greet"]))
  inspect(captured.val, content="fallback")
}

///|
async test "env supplies string int and bool options" {
  let captured = Ref("")
  let app = cli(name="test-app", commands=[
    command(
      name="serve",
      options=[
        string("name", env="ADMIRAL_TEST_NAME"),
        int("port", env="ADMIRAL_TEST_PORT"),
        bool("verbose", env="ADMIRAL_TEST_VERBOSE"),
      ],
      run=Some(fn(ctx) {
        captured.val = "\{ctx.get_string("name").unwrap_or("")}:\{ctx.get_int("port").unwrap_or(0)}:\{ctx.get_bool("verbose")}"
      }),
    ),
  ])
  app.run(argv=Some(["serve"]), env={
    "ADMIRAL_TEST_NAME": "env-name",
    "ADMIRAL_TEST_PORT": "4242",
    "ADMIRAL_TEST_VERBOSE": "true",
  })
  inspect(captured.val, content="env-name:4242:true")
}

///|
async test "argv overrides env and configured default" {
  let captured = Ref("")
  let app = cli(name="test-app", commands=[
    command(
      name="greet",
      options=[
        string(
          "name",
          env="ADMIRAL_TEST_PRECEDENCE",
          default=Some("default-name"),
        ),
      ],
      run=Some(fn(ctx) {
        captured.val = ctx.get_string_required("name") catch { _ => "error" }
      }),
    ),
  ])
  app.run(argv=Some(["greet", "--name", "argv-name"]), env={
    "ADMIRAL_TEST_PRECEDENCE": "env-name",
  })
  inspect(captured.val, content="argv-name")
}

///|
async test "env overrides configured default" {
  let captured = Ref("")
  let app = cli(name="test-app", commands=[
    command(
      name="greet",
      options=[
        string(
          "name",
          env="ADMIRAL_TEST_ENV_DEFAULT",
          default=Some("default-name"),
        ),
      ],
      run=Some(fn(ctx) {
        captured.val = ctx.get_string_required("name") catch { _ => "error" }
      }),
    ),
  ])
  app.run(argv=Some(["greet"]), env={ "ADMIRAL_TEST_ENV_DEFAULT": "env-name" })
  inspect(captured.val, content="env-name")
}

///|
async test "configured default applies when argv and env omit option" {
  let captured = Ref("")
  let app = cli(name="test-app", commands=[
    command(
      name="greet",
      options=[
        string(
          "name",
          env="ADMIRAL_TEST_MISSING_DEFAULT",
          default=Some("default-name"),
        ),
      ],
      run=Some(fn(ctx) {
        captured.val = ctx.get_string_required("name") catch { _ => "error" }
      }),
    ),
  ])
  app.run(argv=Some(["greet"]), env=Map([]))
  inspect(captured.val, content="default-name")
}

///|
async test "env satisfies a required option" {
  let captured = Ref("")
  let app = cli(name="test-app", commands=[
    command(
      name="greet",
      options=[string("name", env="ADMIRAL_TEST_REQUIRED", required=true)],
      run=Some(fn(ctx) {
        captured.val = ctx.get_string_required("name") catch { _ => "error" }
      }),
    ),
  ])
  app.run(argv=Some(["greet"]), env={ "ADMIRAL_TEST_REQUIRED": "env-required" })
  inspect(captured.val, content="env-required")
}

///|
async test "missing required option still fails without argv or env" {
  let called = Ref(false)
  let app = cli(name="test-app", commands=[
    command(
      name="greet",
      options=[
        string("name", env="ADMIRAL_TEST_REQUIRED_MISSING", required=true),
      ],
      run=Some(fn(_ctx) { called.val = true }),
    ),
  ])
  let error_message = Ref("")
  app.run(argv=Some(["greet"]), env=Map([])) catch {
    error => error_message.val = error.to_string()
  }
  inspect(
    error_message.val.contains(
      "the following required argument was not provided: 'name'",
    ),
    content="true",
  )
  inspect(called.val, content="false")
}

///|
async test "invalid bool env value propagates parse failure" {
  let called = Ref(false)
  let app = cli(name="test-app", commands=[
    command(
      name="build",
      options=[bool("verbose", env="ADMIRAL_TEST_INVALID_BOOL")],
      run=Some(fn(_ctx) { called.val = true }),
    ),
  ])
  let error_message = Ref("")
  app.run(argv=Some(["build"]), env={
    "ADMIRAL_TEST_INVALID_BOOL": "definitely-not-bool",
  }) catch {
    error => error_message.val = error.to_string()
  }
  inspect(
    error_message.val.contains(
      "invalid value 'definitely-not-bool' for boolean flag; expected one of: 1, 0, true, false, yes, no, on, off",
    ),
    content="true",
  )
  inspect(called.val, content="false")
}

///|
async test "explicit empty env isolates parsing from ambient environment" {
  let captured = Ref("")
  let app = cli(name="test-app", commands=[
    command(
      name="greet",
      options=[
        string(
          "name",
          env="ADMIRAL_TEST_ISOLATED_NAME",
          default=Some("isolated-default"),
        ),
      ],
      run=Some(fn(ctx) {
        captured.val = ctx.get_string_required("name") catch { _ => "error" }
      }),
    ),
  ])
  app.run(argv=Some(["greet"]), env=Map([]))
  inspect(captured.val, content="isolated-default")
}

///|
async test "env reaches nested command options" {
  let captured = Ref("")
  let app = cli(name="test-app", commands=[
    command(name="admin", subcommands=[
      command(
        name="greet",
        options=[string("name", env="ADMIRAL_TEST_NESTED")],
        run=Some(fn(ctx) {
          captured.val = ctx.get_string_required("name") catch { _ => "error" }
        }),
      ),
    ]),
  ])
  app.run(argv=Some(["admin", "greet"]), env={
    "ADMIRAL_TEST_NESTED": "nested-env",
  })
  inspect(captured.val, content="nested-env")
}

///|
async test "cli run with bool flag" {
  let was_verbose = Ref(false)
  let app = cli(name="test-app", version="0.1.0", description="Test", commands=[
    command(
      name="build",
      description="Build project",
      options=[bool("verbose", short='v', description="Verbose")],
      run=Some(fn(ctx) { was_verbose.val = ctx.get_bool("verbose") }),
    ),
  ])
  app.run(argv=Some(["build", "--verbose"]))
  inspect(was_verbose.val, content="true")
}

///|
async test "cli run with int option" {
  let port_val = Ref(0)
  let app = cli(name="test-app", version="0.1.0", description="Test", commands=[
    command(
      name="serve",
      description="Start server",
      options=[int("port", short='p', description="Port", default=Some(3000))],
      run=Some(fn(ctx) {
        port_val.val = match ctx.get_int("port") {
          Some(p) => p
          None => 0
        }
      }),
    ),
  ])
  app.run(argv=Some(["serve", "--port", "8080"]))
  inspect(port_val.val, content="8080")
}

///|
async test "cli run with nested async subcommand" {
  let result = Ref("")
  let app = cli(name="test-app", version="0.1.0", description="Test", commands=[
    command(name="db", description="Database commands", subcommands=[
      command(
        name="migrate",
        description="Run migrations",
        options=[bool("dry-run", description="Dry run")],
        run=Some(fn(ctx) {
          result.val = if ctx.get_bool("dry-run") { "dry" } else { "real" }
        }),
      ),
    ]),
  ])
  app.run(argv=Some(["db", "migrate", "--dry-run"]))
  inspect(result.val, content="dry")
}

///|
async test "command errors still propagate" {
  let app = cli(name="test-app", commands=[
    command(name="fail", run=Some(_ctx => fail("command failed"))),
  ])
  let error_propagated = Ref(false)
  app.run(argv=Some(["fail"])) catch {
    _ => error_propagated.val = true
  }
  inspect(error_propagated.val, content="true")
}

///|
async test "unknown commands still fail" {
  let app = cli(name="test-app", commands=[
    command(name="run", run=Some(fn(_ctx) { () })),
  ])
  let error_propagated = Ref(false)
  app.run(argv=Some(["unknown"])) catch {
    _ => error_propagated.val = true
  }
  inspect(error_propagated.val, content="true")
}

///|
async test "invalid options still fail" {
  let app = cli(name="test-app", commands=[
    command(name="run", run=Some(fn(_ctx) { () })),
  ])
  let error_propagated = Ref(false)
  app.run(argv=Some(["run", "--unknown"])) catch {
    _ => error_propagated.val = true
  }
  inspect(error_propagated.val, content="true")
}
