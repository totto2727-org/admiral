///|
priv struct Project {
  name : String
  description : String
}

///|
let projects : Array[Project] = [
  { name: "admiral", description: "Declarative CLI builder", },
  { name: "codex-sdk", description: "Codex SDK for MoonBit", },
  { name: "lens", description: "Typed JSON lenses", },
  { name: "workgraph-core", description: "Agent workflow runtime", },
  { name: "opencode-sdk", description: "OpenCode SDK for MoonBit", },
]

///|
fn search_projects(query : String) -> Array[Project] {
  let normalized = query.to_lower()
  if normalized.length() == 0 {
    return projects.copy()
  }
  projects
  .iter()
  .filter(project => {
    project.name.to_lower().contains(normalized) ||
    project.description.to_lower().contains(normalized)
  })
  .collect()
}

///|
fn drop_last_character(value : String) -> String {
  let characters : Array[Char] = value.iter().collect()
  if characters.length() == 0 {
    return value
  }
  characters
  .iter()
  .take(characters.length() - 1)
  .map(character => character.to_string())
  .collect()
  .join("")
}

///|
async fn select_project(
  initial_project : String?,
  initial_query : String,
) -> String? {
  let query = Ref(
    if initial_query.length() > 0 {
      initial_query
    } else {
      initial_project.unwrap_or("")
    },
  )
  let selected_index = Ref(0)
  let result : Ref[String?] = Ref(None)

  fn filtered_projects() -> Array[Project] {
    search_projects(query.val)
  }

  fn reset_selection() -> Unit {
    selected_index.val = 0
  }

  fn render() {
    let matches = filtered_projects()
    let rows = []
    for index, project in matches {
      let selected = index == selected_index.val
      rows.push(
        @tui.text(
          (if selected { "> " } else { "  " }) +
          project.name +
          "  " +
          project.description,
          fg=if selected { "cyan" } else { "white" },
          bold=selected,
        ),
      )
    }
    if rows.length() == 0 {
      rows.push(@tui.text("  No matching projects", fg="yellow"))
    }
    @tui.column(
      padding=1.0,
      gap=1.0,
      border="rounded",
      border_color="cyan",
      [
        @tui.text("Select a project", fg="cyan", bold=true),
        @tui.text("Search: " + query.val + "_", fg="yellow"),
      ] +
      rows +
      [@tui.text("Type to search | ↑↓ move | Enter select | Esc cancel")],
    )
  }

  fn handle_event(event : @tui.InputEvent) -> Bool {
    match event {
      @tui.InputEvent::Key(key) =>
        match key {
          @tui.KeyEvent::Special(@tui.SpecialKey::Escape, _)
          | @tui.KeyEvent::Char('c', @tui.KeyModifier::Ctrl) => false
          @tui.KeyEvent::Special(@tui.SpecialKey::Enter, _) => {
            let matches = filtered_projects()
            if matches.length() > 0 {
              result.val = Some(matches[selected_index.val].name)
            }
            false
          }
          @tui.KeyEvent::Special(@tui.SpecialKey::Up, _) => {
            if selected_index.val > 0 {
              selected_index.val = selected_index.val - 1
            }
            true
          }
          @tui.KeyEvent::Special(@tui.SpecialKey::Down, _) => {
            let matches = filtered_projects()
            if selected_index.val + 1 < matches.length() {
              selected_index.val = selected_index.val + 1
            }
            true
          }
          @tui.KeyEvent::Special(@tui.SpecialKey::Backspace, _) => {
            query.val = drop_last_character(query.val)
            reset_selection()
            true
          }
          @tui.KeyEvent::Char(character, @tui.KeyModifier::None)
          | @tui.KeyEvent::Char(character, @tui.KeyModifier::Shift) => {
            query.val = query.val + character.to_string()
            reset_selection()
            true
          }
          _ => true
        }
      _ => true
    }
  }

  let (width, height) = @tui.get_terminal_size()
  let app = @tui.VNodeApp::new(width, height)
  fn render_frame() -> Unit {
    @tui.print_raw(app.render_frame(render()))
  }
  @tui.enable_raw_mode()
  defer @tui.cleanup_stdin()
  @tui.print_raw(@tui.VNodeApp::init_terminal())
  defer @tui.print_raw(@tui.VNodeApp::restore_terminal())
  render_frame()
  while true {
    let key = @tui.read_key()
    if key.length() == 0 {
      @async.sleep(10)
    } else if handle_event(@tui.parse_input(key)) {
      render_frame()
    } else {
      break
    }
  }
  result.val
}

///|
/// An editor could not resolve a project without terminal input.
pub(all) suberror ProjectQueryError {
  NoProjectMatch(String)
  AmbiguousProjectQuery(String)
}

///|
pub impl Show for ProjectQueryError with fn output(self, logger) {
  match self {
    NoProjectMatch(query) =>
      logger.write_string("no projects match query '\{query}'")
    AmbiguousProjectQuery(query) =>
      logger.write_string(
        "multiple projects match query '\{query}'. Pass the project explicitly.",
      )
  }
}

///|
fn resolve_without_terminal(
  initial : String?,
  query : String,
) -> String? raise ProjectQueryError {
  if initial is Some(_) || query.is_empty() {
    return None
  }
  match search_projects(query) {
    [project] => Some(project.name)
    [] => raise NoProjectMatch(query)
    _ => raise AmbiguousProjectQuery(query)
  }
}

///|
/// Uses the query for initial filtering in a terminal, or selects a unique
/// match without prompting when no project was explicitly supplied.
pub fn project_picker(
  query : @admiral.OptionDef[String],
) -> @admiral.FieldEditor[String] {
  (ctx, initial) => {
    let initial_query = ctx.get_string(query).unwrap_or("")
    if !@io.is_tty() {
      return resolve_without_terminal(initial, initial_query)
    }
    match select_project(initial, initial_query) {
      Some(selected) => Some(selected)
      None => fail("project selection cancelled")
    }
  }
}
