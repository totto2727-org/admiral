///|
/// The scalar value kinds supported by options and positional arguments.
#derive(Debug, Eq)
pub enum OptionType {
  StringOpt
  BoolOpt
  IntOpt
  Int64Opt
  UIntOpt
  UInt64Opt
  DoubleOpt
}

///|
pub extend OptionType with Debug::{to_repr}

///|
pub extend OptionType with Eq::{not_equal, equal}

///|
pub extend OptionType with Show::{to_string, output}

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
/// Metadata used to build and resolve a named option, including its short flag,
/// environment key, configuration key, required state, and multiplicity.
#derive(Debug)
pub struct OptionMetadata {
  type_ : OptionType
  short : Char
  description : String
  env : String?
  required : Bool
  default_value : String?
  multiple : Bool
  interactive : Bool
}

///|
pub extend OptionMetadata with Debug::{to_repr}

///|
/// Metadata used to build and resolve a positional argument.
#derive(Debug)
pub struct PositionMetadata {
  type_ : OptionType
  description : String
  required : Bool
  multiple : Bool
  interactive : Bool
}

///|
pub extend PositionMetadata with Debug::{to_repr}

///|
/// Typed, read-only argument definition shared by a parser declaration and its
/// matching `Context` getter.
#derive(Debug)
pub struct ArgDef[_, Metadata] {
  name : String
  config : String?
  metadata : Metadata
  priv editor : FieldEdit?
}

///|
pub extend ArgDef with Debug::{to_repr}

///|
/// Typed definition for an option declaration.
pub type OptionDef[T] = ArgDef[T, OptionMetadata]

///|
/// Typed definition for a positional argument declaration.
pub type PositionDef[T] = ArgDef[T, PositionMetadata]

///|
/// Non-empty view returned by required plural getters. `first` is the first
/// value, `rest` is the remaining view, and `all` preserves the full sequence.
#derive(Debug)
pub struct NonEmptyArray[T] {
  first : T
  rest : ArrayView[T]
  all : ReadOnlyArray[T]
}

///|
pub extend NonEmptyArray with Debug::{to_repr}

///|
type StoredOption = ArgDef[Unit, OptionMetadata]

///|
type StoredPosition = ArgDef[Unit, PositionMetadata]

///|
trait ToStoredOption {
  fn to_stored_option(Self) -> StoredOption
}

///|
pub impl[T] ToStoredOption for ArgDef[T, OptionMetadata] with fn to_stored_option(
  self,
) {
  {
    name: self.name,
    config: self.config,
    metadata: self.metadata,
    editor: self.editor,
  }
}

///|
trait ToStoredPosition {
  fn to_stored_position(Self) -> StoredPosition
}

///|
pub impl[T] ToStoredPosition for ArgDef[T, PositionMetadata] with fn to_stored_position(
  self,
) {
  {
    name: self.name,
    config: self.config,
    metadata: self.metadata,
    editor: self.editor,
  }
}

///|
/// A declarative command definition with options, positions, nested commands,
/// and an async execution callback.
pub struct CommandDef {
  name : String
  description : String
  options : Array[StoredOption]
  positionals : Array[StoredPosition]
  examples : Array[String]
  subcommands : Array[CommandDef]
  run : (async (Context) -> Unit)?
}

///|
/// Failure raised by a configuration loader when external configuration cannot
/// be read or decoded into a map.
#derive(Debug, Eq)
pub(all) suberror ConfigLoadFailure {
  ConfigLoadFailure(String)
}

///|
pub extend ConfigLoadFailure with Debug::{to_repr}

///|
pub extend ConfigLoadFailure with Eq::{not_equal, equal}

///|
pub extend ConfigLoadFailure with Show::{to_string, output}

///|
pub impl Show for ConfigLoadFailure with fn output(self, logger) {
  match self {
    ConfigLoadFailure(message) => logger.write_string(message)
  }
}

///|
/// Parsed values and independently loaded configuration for a command callback.
pub struct Context {
  flags : @immut_hashmap.HashMap[String, Bool]
  values : @immut_hashmap.HashMap[String, ReadOnlyArray[String]]
  sources : @immut_hashmap.HashMap[String, @argparse.ValueSource]
  config : @immut_hashmap.HashMap[String, Json]
  interactive_flags : @immut_hashmap.HashMap[String, Bool]
  interactive_values : @immut_hashmap.HashMap[String, ReadOnlyArray[String]]
  subcommand : (String, Context)?
}

///|
/// Creates a context from parser maps and an optional configuration map. The
/// constructor is useful for embedding or tests that provide explicit matches.
pub fn Context::Context(
  flags~ : Map[String, Bool] = Map([]),
  values~ : Map[String, Array[String]] = Map([]),
  sources~ : Map[String, @argparse.ValueSource] = Map([]),
  config~ : Map[String, Json] = Map([]),
  subcommand~ : (String, Context)? = None,
) -> Context {
  Context::{
    flags: @immut_hashmap.from_iter(flags.iter()),
    values: @immut_hashmap.from_iter(
      values
      .iter()
      .map(fn(entry) {
        let (key, items) = entry
        (key, ReadOnlyArray::from_array(items))
      }),
    ),
    sources: @immut_hashmap.from_iter(sources.iter()),
    config: @immut_hashmap.from_iter(config.iter()),
    interactive_flags: @immut_hashmap.new(),
    interactive_values: @immut_hashmap.new(),
    subcommand,
  }
}

///|
/// Root application definition containing global arguments and command routing.
pub struct CliApp {
  name : String
  version : String
  description : String
  root_options : Array[StoredOption]
  root_positionals : Array[StoredPosition]
  commands : Array[CommandDef]
  run : (async (Context) -> Unit)?
  load_config : (() -> Map[String, Json] raise ConfigLoadFailure)?
}
