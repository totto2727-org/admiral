///|
async fn main {
  let project = @admiral.position_string(
    "project",
    description="Project selected by name",
    required=true,
    interactive=true,
  )
  let app = @admiral.CliApp::CliApp(
    name="interactive-project",
    version="0.1.0",
    description="Admiral line prompt example",
    positionals=[project],
    interactive=Some(input => {
      if input.to_context().get_string(project) is None {
        println("Enter a project name:")
        let name = read_project_name().trim().to_owned()
        guard name != "" else { fail("no project name entered") }
        input.set_string(project, name)
      }
    }),
    run=Some(ctx => {
      println("Selected project: " + ctx.get_string_required(project))
    }),
  )
  app.run()
}
