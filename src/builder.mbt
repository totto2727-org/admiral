///|
fn has_short(opt : OptionDef) -> Bool {
  opt.short != no_short
}

///|
fn build_option_to_flag(opt : OptionDef) -> @argparse.FlagArg {
  let env = opt.env.map(fn(value) { value[:] })
  if has_short(opt) {
    @argparse.FlagArg(opt.name, short=opt.short, about=opt.description, env?)
  } else {
    @argparse.FlagArg(opt.name, about=opt.description, env?)
  }
}

///|
fn build_option_to_option_arg(opt : OptionDef) -> @argparse.OptionArg {
  let env = opt.env.map(fn(value) { value[:] })
  match (has_short(opt), opt.default_value, opt.required) {
    (true, Some(dv), _) =>
      @argparse.OptionArg(
        opt.name,
        short=opt.short,
        about=opt.description,
        env?,
        default_values=[dv],
      )
    (true, None, true) =>
      @argparse.OptionArg(
        opt.name,
        short=opt.short,
        about=opt.description,
        env?,
        required=true,
      )
    (true, None, false) =>
      @argparse.OptionArg(
        opt.name,
        short=opt.short,
        about=opt.description,
        env?,
      )
    (false, Some(dv), _) =>
      @argparse.OptionArg(opt.name, about=opt.description, env?, default_values=[
        dv,
      ])
    (false, None, true) =>
      @argparse.OptionArg(opt.name, about=opt.description, env?, required=true)
    (false, None, false) =>
      @argparse.OptionArg(opt.name, about=opt.description, env?)
  }
}

///|
fn build_positional(pos : PositionalDef) -> @argparse.PositionArg {
  if pos.required {
    @argparse.PositionArg(
      pos.name,
      about=pos.description,
      num_args=@argparse.ValueRange(lower=1),
    )
  } else {
    @argparse.PositionArg(
      pos.name,
      about=pos.description,
      num_args=@argparse.ValueRange(lower=0),
    )
  }
}

///|
fn fallback_to_help_when_no_match(cmd : CommandDef) -> Bool {
  cmd.run is None
}

///|
pub fn build_command(cmd : CommandDef) -> @argparse.Command {
  let flags : Array[@argparse.FlagArg] = []
  let options : Array[@argparse.OptionArg] = []
  for opt in cmd.options {
    match opt.type_ {
      BoolOpt => flags.push(build_option_to_flag(opt))
      StringOpt | IntOpt | Int64Opt | UIntOpt | UInt64Opt | DoubleOpt =>
        options.push(build_option_to_option_arg(opt))
    }
  }
  let positionals = cmd.positionals.map(fn(p) { build_positional(p) })
  let subcommands = cmd.subcommands.map(fn(sub) { build_command(sub) })
  @argparse.Command(
    cmd.name,
    about=cmd.description,
    flags~,
    options~,
    positionals~,
    subcommands~,
    arg_required_else_help=fallback_to_help_when_no_match(cmd),
  )
}
