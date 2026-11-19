///|
test "CLI schema JSON preserves nested commands and omits absent fields" {
  let app = CliApp::CliApp(name="app", version="1.0.0", description="Example", commands=[
    CommandDef::CommandDef(name="run", description="Run", options=[
      bool("verbose", short='v', description="Verbose"),
    ]),
    CommandDef::CommandDef(name="empty", description="Empty"),
  ])
  let expected : Json = {
    "name": "app",
    "version": "1.0.0",
    "description": "Example",
    "commands": {
      "run": {
        "description": "Run",
        "options": {
          "verbose": {
            "type": "bool",
            "description": "Verbose",
            "required": false,
            "multiple": false,
            "interactive": false,
            "style": "flag",
            "short": "v",
          },
        },
        "examples": ["app run"],
      },
      "empty": { "description": "Empty" },
    },
  }
  let rendered = @json.parse(app.render_schema())
  assert_eq(rendered, expected)
}
