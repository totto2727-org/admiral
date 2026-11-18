///|
test "render_schema outputs JSON for simple command" {
  let app = @admiral.CliApp::CliApp(
    name="myapp",
    version="1.0.0",
    description="Test app",
    commands=[
      @admiral.CommandDef::CommandDef(
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
          @admiral.int("count", description="Repeat count", default=Some(3)),
          @admiral.int64("offset"),
          @admiral.uint("retries"),
          @admiral.uint64("limit"),
          @admiral.double("ratio"),
        ],
      ),
    ],
  )
  let schema = app.render_schema()
  // Verify key parts exist in JSON output
  inspect(schema.contains("\"name\":\"myapp\""), content="true")
  inspect(schema.contains("\"version\":\"1.0.0\""), content="true")
  inspect(schema.contains("\"description\":\"Test app\""), content="true")
  inspect(schema.contains("\"greet\""), content="true")
  inspect(schema.contains("\"type\":\"string\""), content="true")
  inspect(schema.contains("\"required\":true"), content="true")
  inspect(schema.contains("\"type\":\"bool\""), content="true")
  inspect(schema.contains("\"style\":\"flag\""), content="true")
  inspect(schema.contains("\"type\":\"int\""), content="true")
  inspect(schema.contains("\"type\":\"int64\""), content="true")
  inspect(schema.contains("\"type\":\"uint\""), content="true")
  inspect(schema.contains("\"type\":\"uint64\""), content="true")
  inspect(schema.contains("\"type\":\"double\""), content="true")
  inspect(schema.contains("\"default\":\"3\""), content="true")
  inspect(schema.contains("\"short\":\"n\""), content="true")
  inspect(schema.contains("\"interactive\":false"), content="true")
}

///|
test "render_schema outputs nested subcommands" {
  let app = @admiral.CliApp::CliApp(
    name="db-tool",
    version="0.1.0",
    description="DB tool",
    commands=[
      @admiral.CommandDef::CommandDef(
        name="db",
        description="Database commands",
        subcommands=[
          @admiral.CommandDef::CommandDef(
            name="migrate",
            description="Migrations",
            subcommands=[
              @admiral.CommandDef::CommandDef(
                name="up",
                description="Apply migrations",
                options=[@admiral.bool("dry-run", description="Dry run")],
              ),
            ],
          ),
        ],
      ),
    ],
  )
  let schema = app.render_schema()
  inspect(schema.contains("\"db\""), content="true")
  inspect(schema.contains("\"migrate\""), content="true")
  inspect(schema.contains("\"up\""), content="true")
  inspect(schema.contains("\"dry-run\""), content="true")
  inspect(schema.contains("\"Dry run\""), content="true")
}

///|
test "render_schema auto-generates examples when not provided" {
  let app = @admiral.CliApp::CliApp(
    name="myapp",
    version="0.1.0",
    description="Test",
    commands=[
      @admiral.CommandDef::CommandDef(
        name="greet",
        description="Greet someone",
        options=[
          @admiral.string("name", short='n', description="Name", required=true),
          @admiral.bool("loud", short='l', description="Loud"),
          @admiral.int("count", short='c', description="Count", default=Some(1)),
        ],
        // no examples provided
      ),
    ],
  )
  let schema = app.render_schema()
  // Should auto-generate an example
  inspect(schema.contains("\"examples\""), content="true")
  inspect(schema.contains("myapp greet --name"), content="true")
}

///|
test "render_schema does not override provided examples" {
  let app = @admiral.CliApp::CliApp(
    name="myapp",
    version="0.1.0",
    description="Test",
    commands=[
      @admiral.CommandDef::CommandDef(
        name="greet",
        description="Greet someone",
        options=[@admiral.string("name", description="Name", required=true)],
        examples=["myapp greet --name Alice"],
      ),
    ],
  )
  let schema = app.render_schema()
  inspect(schema.contains("myapp greet --name Alice"), content="true")
}

///|
test "render_schema auto-generates examples for nested commands" {
  let app = @admiral.CliApp::CliApp(
    name="myapp",
    version="0.1.0",
    description="Test",
    commands=[
      @admiral.CommandDef::CommandDef(name="db", description="DB", subcommands=[
        @admiral.CommandDef::CommandDef(
          name="migrate",
          description="Migrate",
          options=[@admiral.bool("dry-run", description="Dry")],
          // no examples
        ),
      ]),
    ],
  )
  let schema = app.render_schema()
  inspect(schema.contains("myapp db migrate"), content="true")
}

///|
test "CliApp ToJson::to_json returns Json value" {
  let app = @admiral.CliApp::CliApp(
    name="test",
    version="0.1.0",
    description="Test",
    commands=[
      @admiral.CommandDef::CommandDef(name="hello", description="Say hello", options=[
        @admiral.string("name", description="Name", required=true),
      ]),
    ],
  )
  let json = app.to_json()
  // Json can be converted back to string
  let s = json.stringify()
  inspect(s.contains("\"hello\""), content="true")
  inspect(s.contains("\"name\""), content="true")
}

///|
test "render_schema includes configured environment variable name" {
  let app = @admiral.CliApp::CliApp(name="test", commands=[
    @admiral.CommandDef::CommandDef(name="hello", options=[
      @admiral.string("name", env="ADMIRAL_SCHEMA_NAME"),
    ]),
  ])
  let schema = app.render_schema()
  inspect(schema.contains("\"env\":\"ADMIRAL_SCHEMA_NAME\""), content="true")
}

///|
test "render_schema omits env for unconfigured options" {
  let app = @admiral.CliApp::CliApp(name="test", commands=[
    @admiral.CommandDef::CommandDef(name="hello", options=[
      @admiral.string("name"),
    ]),
  ])
  let schema = app.render_schema()
  inspect(schema.contains("\"env\""), content="false")
}

///|
test "render_schema includes config keys for options and positions" {
  let app = @admiral.CliApp::CliApp(name="test", commands=[
    @admiral.CommandDef::CommandDef(
      name="run",
      options=[@admiral.string("name", config="name")],
      positionals=[@admiral.position_string("input", config="input")],
    ),
  ])
  let schema = app.render_schema()
  inspect(schema.contains("\"config\":\"name\""), content="true")
  inspect(schema.contains("\"config\":\"input\""), content="true")
}

///|
test "render_schema does not expose resolved environment values" {
  let key = "ADMIRAL_SCHEMA_NAME"
  let sentinel = "SCHEMA_FAKE_RESOLVED_VALUE_7C9F"
  let previous = @env.get_env_var(key)
  @env.set_env_var(key, sentinel)
  let app = @admiral.CliApp::CliApp(name="test", commands=[
    @admiral.CommandDef::CommandDef(name="hello", options=[
      @admiral.string("name", env=key),
    ]),
  ])
  let schema = app.render_schema()
  match previous {
    Some(value) => @env.set_env_var(key, value)
    None => @env.unset_env_var(key)
  }
  inspect(schema.contains("\"env\":\"ADMIRAL_SCHEMA_NAME\""), content="true")
  inspect(schema.contains(sentinel), content="false")
}

///|
test "render_schema includes typed position metadata" {
  let input = @admiral.position_int(
    "input",
    description="Input number",
    required=true,
  )
  let rest = @admiral.position_strings("rest")
  let app = @admiral.CliApp::CliApp(name="test", commands=[
    @admiral.CommandDef::CommandDef(name="collect", positionals=[input, rest]),
  ])
  let schema = app.render_schema()
  inspect(schema.contains("\"positionals\""), content="true")
  inspect(schema.contains("\"input\""), content="true")
  inspect(schema.contains("\"type\":\"int\""), content="true")
  inspect(schema.contains("\"multiple\":true"), content="true")
}

///|
test "render_schema includes interactive option and position metadata" {
  let app = @admiral.CliApp::CliApp(name="test", commands=[
    @admiral.CommandDef::CommandDef(
      name="select",
      options=[@admiral.string("query", interactive=true)],
      positionals=[@admiral.position_string("project", interactive=true)],
    ),
  ])
  let schema = app.render_schema()
  inspect(schema.contains("\"interactive\":true"), content="true")
}
