///|
async fn main {
  let query = @admiral.string(
    "query",
    short='q',
    description="Initial project search",
    env="ADMIRAL_PROJECT_QUERY",
    default=Some(""),
  )
  let project = @admiral.position_string(
    "project",
    description="Project selected by name",
    required=true,
    interactive?=@terminal.project_picker(query),
  )
  let app = @admiral.CliApp::CliApp(
    name="interactive-project",
    version="0.1.0",
    description="Admiral interactive project search example",
    positionals=[project],
    options=[query],
    run=Some(ctx => {
      println("Selected project: " + ctx.get_string_required(project))
    }),
  )
  app.run()
}
