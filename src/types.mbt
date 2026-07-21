///|
pub(all) enum OptionType {
  StringOpt
  BoolOpt
  IntOpt
  Int64Opt
  UIntOpt
  UInt64Opt
  DoubleOpt
} derive(Debug, Eq)

///|
pub impl Show for OptionType with fn output(self, logger) {
  match self {
    StringOpt => logger.write_string("StringOpt")
    BoolOpt => logger.write_string("BoolOpt")
    IntOpt => logger.write_string("IntOpt")
    Int64Opt => logger.write_string("Int64Opt")
    UIntOpt => logger.write_string("UIntOpt")
    UInt64Opt => logger.write_string("UInt64Opt")
    DoubleOpt => logger.write_string("DoubleOpt")
  }
}

///|
pub(all) struct OptionDef {
  name : String
  type_ : OptionType
  short : Char
  description : String
  env : String?
  required : Bool
  default_value : String?
} derive(Debug)

///|
pub(all) struct PositionalDef {
  name : String
  description : String
  required : Bool
}

///|
pub(all) struct CommandDef {
  name : String
  description : String
  options : Array[OptionDef]
  positionals : Array[PositionalDef]
  examples : Array[String]
  subcommands : Array[CommandDef]
  run : (async (Context) -> Unit)?
}

///|
pub(all) suberror ConfigLoadFailure {
  ConfigLoadFailure(String)
} derive(Debug, Eq)

///|
pub impl Show for ConfigLoadFailure with fn output(self, logger) {
  match self {
    ConfigLoadFailure(message) => logger.write_string(message)
  }
}

///|
pub(all) struct Context {
  flags : Map[String, Bool]
  values : Map[String, Array[String]]
  subcommand : (String, Context)?
}

///|
pub(all) struct CliApp {
  name : String
  version : String
  description : String
  root_options : Array[OptionDef]
  commands : Array[CommandDef]
  load_config : (() -> Map[String, String] raise ConfigLoadFailure)?
}
