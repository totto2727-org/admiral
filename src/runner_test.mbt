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
async test "argv supplies all supported numeric option types" {
  let captured = Ref("")
  let app = cli(name="test-app", commands=[
    command(
      name="numbers",
      options=[
        int("int"),
        int64("int64"),
        uint("uint"),
        uint64("uint64"),
        double("double"),
      ],
      run=Some(fn(ctx) {
        captured.val = [
          ctx.get_int("int").map(fn(value) { value.to_string() }).unwrap_or(""),
          ctx
          .get_int64("int64")
          .map(fn(value) { value.to_string() })
          .unwrap_or(""),
          ctx
          .get_uint("uint")
          .map(fn(value) { value.to_string() })
          .unwrap_or(""),
          ctx
          .get_uint64("uint64")
          .map(fn(value) { value.to_string() })
          .unwrap_or(""),
          ctx
          .get_double("double")
          .map(fn(value) { value.to_string() })
          .unwrap_or(""),
        ].join(":")
      }),
    ),
  ])
  app.run(
    argv=Some([
      "numbers", "--int=-42", "--int64", "9223372036854775807", "--uint", "4294967295",
      "--uint64", "18446744073709551615", "--double", "1.25",
    ]),
  )
  inspect(
    captured.val,
    content="-42:9223372036854775807:4294967295:18446744073709551615:1.25",
  )
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
async test "config supplies scalar options through argparse env" {
  let loaded = Ref(0)
  let captured = Ref("")
  let app = cli(
    name="test-app",
    load_config=Some(fn() {
      loaded.val = loaded.val + 1
      {
        "ADMIRAL_CONFIG_NAME": "config-name",
        "ADMIRAL_CONFIG_PORT": "7000",
        "ADMIRAL_CONFIG_VERBOSE": "true",
      }
    }),
    commands=[
      command(
        name="serve",
        options=[
          string("name", env="ADMIRAL_CONFIG_NAME", required=true),
          int("port", env="ADMIRAL_CONFIG_PORT", default=Some(3000)),
          bool("verbose", env="ADMIRAL_CONFIG_VERBOSE"),
        ],
        run=Some(fn(ctx) {
          captured.val = "\{ctx.get_string("name").unwrap_or("")}:\{ctx.get_int("port").unwrap_or(0)}:\{ctx.get_bool("verbose")}"
        }),
      ),
    ],
  )
  app.run(argv=Some(["serve"]), env=Map([]))
  inspect(loaded.val, content="1")
  inspect(captured.val, content="config-name:7000:true")
}

///|
async test "config precedence is below argv and real env and above defaults" {
  let captured = Ref("")
  let app = cli(
    name="test-app",
    load_config=Some(fn() {
      {
        "ADMIRAL_CONFIG_ARGV": "config-argv",
        "ADMIRAL_CONFIG_ENV": "config-env",
        "ADMIRAL_CONFIG_ONLY": "config-only",
      }
    }),
    commands=[
      command(
        name="show",
        options=[
          string(
            "argv-value",
            env="ADMIRAL_CONFIG_ARGV",
            default=Some("default-argv"),
          ),
          string(
            "env-value",
            env="ADMIRAL_CONFIG_ENV",
            default=Some("default-env"),
          ),
          string(
            "config-value",
            env="ADMIRAL_CONFIG_ONLY",
            default=Some("default-config"),
          ),
          string("default-value", default=Some("default-only")),
        ],
        run=Some(fn(ctx) {
          captured.val = [
            ctx.get_string("argv-value").unwrap_or(""),
            ctx.get_string("env-value").unwrap_or(""),
            ctx.get_string("config-value").unwrap_or(""),
            ctx.get_string("default-value").unwrap_or(""),
          ].join(":")
        }),
      ),
    ],
  )
  app.run(argv=Some(["show", "--argv-value", "argv-only"]), env={
    "ADMIRAL_CONFIG_ARGV": "env-argv",
    "ADMIRAL_CONFIG_ENV": "env-only",
  })
  inspect(captured.val, content="argv-only:env-only:config-only:default-only")
}

///|
async test "config satisfies required option through argparse" {
  let captured = Ref("")
  let app = cli(
    name="test-app",
    load_config=Some(fn() { { "ADMIRAL_CONFIG_REQUIRED": "config-required" } }),
    commands=[
      command(
        name="run",
        options=[string("name", env="ADMIRAL_CONFIG_REQUIRED", required=true)],
        run=Some(fn(ctx) { captured.val = ctx.get_string("name").unwrap_or("") }),
      ),
    ],
  )
  app.run(argv=Some(["run"]), env=Map([]))
  inspect(captured.val, content="config-required")
}

///|
async test "empty config keeps argparse required validation" {
  let called = Ref(false)
  let app = cli(name="test-app", load_config=Some(fn() { Map([]) }), commands=[
    command(
      name="run",
      options=[string("name", env="ADMIRAL_CONFIG_MISSING", required=true)],
      run=Some(fn(_) { called.val = true }),
    ),
  ])
  let error_message = Ref("")
  app.run(argv=Some(["run"]), env=Map([])) catch {
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
async test "config env value remains a single string" {
  let captured : Ref[Array[String]] = Ref([])
  let app = cli(
    name="test-app",
    load_config=Some(fn() { { "ADMIRAL_CONFIG_TAGS": "a,b" } }),
    commands=[
      command(
        name="show",
        options=[string("tags", env="ADMIRAL_CONFIG_TAGS")],
        run=Some(fn(ctx) { captured.val = ctx.get_strings("tags") }),
      ),
    ],
  )
  app.run(argv=Some(["show"]), env=Map([]))
  inspect(captured.val.length(), content="1")
  inspect(captured.val[0], content="a,b")
  app.run(argv=Some(["show"]), env={ "ADMIRAL_CONFIG_TAGS": "x,y" })
  inspect(captured.val.length(), content="1")
  inspect(captured.val[0], content="x,y")
}

///|
async test "config load failure propagates before command execution" {
  let called = Ref(false)
  let app = cli(
    name="test-app",
    load_config=Some(fn() -> Map[String, String] raise ConfigLoadFailure {
      raise ConfigLoadFailure("cannot load config")
    }),
    commands=[command(name="run", run=Some(fn(_) { called.val = true }))],
  )
  let error_message = Ref("")
  app.run(argv=Some(["run"]), env=Map([])) catch {
    error => error_message.val = error.to_string()
  }
  inspect(error_message.val.contains("cannot load config"), content="true")
  inspect(called.val, content="false")
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
