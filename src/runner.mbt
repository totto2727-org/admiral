///|
/// Constructs a command definition. The same typed option or position value can
/// be passed to the declaration and later to its matching context getter.
pub fn CommandDef::CommandDef(
  name~ : String,
  description~ : String = "",
  options~ : Array[&ToStoredOption] = [],
  positionals~ : Array[&ToStoredPosition] = [],
  examples~ : Array[String] = [],
  subcommands~ : Array[CommandDef] = [],
  run~ : (async (Context) -> Unit)? = None,
) -> CommandDef {
  let options = options.map(fn(option) {
    ToStoredOption::to_stored_option(option)
  })
  let positionals = positionals.map(fn(position) {
    ToStoredPosition::to_stored_position(position)
  })
  { name, description, options, positionals, examples, subcommands, run, }
}

///|
/// Constructs the root CLI application. `run` handles root arguments, while
/// `commands` dispatches nested command paths; `load_config` supplies a map of
/// independent configuration keys.
pub fn CliApp::CliApp(
  name~ : String,
  version~ : String = "0.0.0",
  description~ : String = "",
  options~ : Array[&ToStoredOption] = [],
  positionals~ : Array[&ToStoredPosition] = [],
  commands~ : Array[CommandDef] = [],
  run~ : (async (Context) -> Unit)? = None,
  load_config~ : (() -> Map[String, Json] raise ConfigLoadFailure)? = None,
) -> CliApp {
  let root_options = options.map(fn(option) {
    ToStoredOption::to_stored_option(option)
  })
  let root_positionals = positionals.map(fn(position) {
    ToStoredPosition::to_stored_position(position)
  })
  {
    name,
    version,
    description,
    root_options,
    root_positionals,
    commands,
    run,
    load_config,
  }
}

///|
fn matches_to_context(
  m : @argparse.Matches,
  config : Map[String, Json],
) -> Context {
  let sub = match m.subcommand {
    Some((name, sub_matches)) =>
      Some((name, matches_to_context(sub_matches, config)))
    None => None
  }
  Context(
    flags=m.flags,
    values=m.values,
    sources=m.sources,
    config~,
    subcommand=sub,
  )
}

///|
#cfg(target="js")
fn process_arguments() -> Array[String] {
  @env.args()[2:].to_owned()
}

///|
#cfg(not(target="js"))
fn process_arguments() -> Array[String] {
  @env.args()[1:].to_owned()
}

///|
fn find_command_def(commands : Array[CommandDef], name : String) -> CommandDef? {
  for cmd in commands {
    if cmd.name == name {
      return Some(cmd)
    }
  }
  None
}

///|
fn build_root_command(
  app : CliApp,
  config : Map[String, Json],
  edit_fields~ : Bool = false,
) -> @argparse.Command {
  let flags : Array[@argparse.FlagArg] = []
  let options : Array[@argparse.OptionArg] = []
  for opt in app.root_options {
    match opt.metadata.type_ {
      BoolOpt => flags.push(build_option_to_flag(opt, global=true))
      StringOpt | IntOpt | Int64Opt | UIntOpt | UInt64Opt | DoubleOpt =>
        options.push(
          build_option_to_option_arg(opt, config, edit_fields~, global=true),
        )
    }
  }
  let subcommands = app.commands.map(fn(c) {
    build_command_with_config(c, config, edit_fields~)
  })
  let positionals = app.root_positionals.map(fn(position) {
    build_position(position, config, edit_fields~)
  })
  @argparse.Command(
    app.name,
    about=app.description,
    version=app.version,
    flags~,
    options~,
    positionals~,
    subcommands~,
    arg_required_else_help=app.run is None,
  )
}

///|
fn print_help(command : @argparse.Command) -> Unit {
  let help = command.render_help()
  match help.strip_suffix("\n") {
    Some(text) => println(text)
    None => println(help)
  }
}

///|
async fn apply_field_editors(
  context : Context,
  options : Array[StoredOption],
  positionals : Array[StoredPosition],
  global_options : Bool,
) -> Context {
  let mut ctx = context
  for option in options {
    if option.editor is Some(editor) {
      ctx = (editor.apply)(ctx, global_options)
    }
  }
  for position in positionals {
    if position.editor is Some(editor) {
      ctx = (editor.apply)(ctx, false)
    }
  }
  ctx
}

///|
async fn execute_command(commands : Array[CommandDef], ctx : Context) -> Unit {
  match ctx.subcommand {
    Some((name, sub_ctx)) =>
      match find_command_def(commands, name) {
        Some(cmd) => {
          let command_context = apply_field_editors(
            sub_ctx,
            cmd.options,
            cmd.positionals,
            false,
          )
          if cmd.subcommands.length() > 0 &&
            command_context.subcommand is Some(_) {
            execute_command(cmd.subcommands, command_context)
          } else {
            match cmd.run {
              Some(run_fn) => run_fn(command_context)
              None => {
                let subs = cmd.subcommands.map(fn(c) { c.name }).join(", ")
                fail(
                  "missing subcommand for '" + name + "'. Available: " + subs,
                )
              }
            }
          }
        }
        None => fail("unknown command: " + name)
      }
    None => fail("no command specified. Use --help for usage.")
  }
}

///|
/// Resolves values, runs the registered field editors, then executes the command.
/// Fields without an editor do not trigger input. Editors do not require a TTY.
pub async fn CliApp::run(
  self : CliApp,
  argv~ : Array[String]? = None,
  env~ : Map[String, String] = @env.get_env_vars(),
) -> Unit {
  let config = match self.load_config {
    Some(load_config) => load_config()
    None => Map([])
  }
  let argparse_cmd = build_root_command(self, config, edit_fields=true)
  let matches = match argv {
    Some(args) => argparse_cmd.parse(argv=args, env~)
    None => argparse_cmd.parse(argv=process_arguments(), env~)
  }
  let ctx = matches_to_context(matches, config)
  if ctx.subcommand is None && self.run is None {
    return print_help(argparse_cmd)
  }
  let root_context = apply_field_editors(
    ctx,
    self.root_options,
    self.root_positionals,
    true,
  )
  match (root_context.subcommand, self.run) {
    (Some(_), _) => execute_command(self.commands, root_context)
    (None, Some(run)) => run(root_context)
    (None, None) => ()
  }
}
