///|
fn option_type_to_string(t : OptionType) -> String {
  match t {
    StringOpt => "string"
    BoolOpt => "bool"
    IntOpt => "int"
    Int64Opt => "int64"
    UIntOpt => "uint"
    UInt64Opt => "uint64"
    DoubleOpt => "double"
  }
}

///|
#custom.serde(encode_only)
priv struct OptionSchema {
  #custom.serde(rename="type")
  kind : String
  description : String
  required : Bool
  multiple : Bool
  interactive : Bool
  #custom.serde(skip_serializing_if="Option::is_none")
  style : String?
  #custom.serde(skip_serializing_if="Option::is_none")
  short : String?
  #custom.serde(skip_serializing_if="Option::is_none")
  env : String?
  #custom.serde(skip_serializing_if="Option::is_none")
  config : String?
  #custom.serde(rename="default", skip_serializing_if="Option::is_none")
  default_value : String?
}

///|
#custom.serde(encode_only)
priv struct PositionSchema {
  #custom.serde(rename="type")
  kind : String
  description : String
  required : Bool
  multiple : Bool
  interactive : Bool
  #custom.serde(skip_serializing_if="Option::is_none")
  config : String?
}

///|
#custom.serde(encode_only)
priv struct CommandSchema {
  description : String
  #custom.serde(skip_serializing_if="Option::is_none")
  options : Map[String, OptionSchema]?
  #custom.serde(skip_serializing_if="Option::is_none")
  positionals : Map[String, PositionSchema]?
  #custom.serde(skip_serializing_if="Option::is_none")
  examples : Array[String]?
  #custom.serde(skip_serializing_if="Option::is_none")
  commands : Map[String, CommandSchema]?
}

///|
#custom.serde(encode_only)
priv struct CliSchema {
  name : String
  version : String
  description : String
  #custom.serde(skip_serializing_if="Option::is_none")
  options : Map[String, OptionSchema]?
  #custom.serde(skip_serializing_if="Option::is_none")
  positionals : Map[String, PositionSchema]?
  #custom.serde(skip_serializing_if="Option::is_none")
  commands : Map[String, CommandSchema]?
}

///|
fn schema_options(options : Array[StoredOption]) -> Map[String, OptionSchema]? {
  if options.is_empty() {
    return None
  }
  let result = Map([])
  for option in options {
    let metadata = option.metadata
    result[option.name] = OptionSchema::{
      kind: option_type_to_string(metadata.type_),
      description: metadata.description,
      required: metadata.required,
      multiple: metadata.multiple,
      interactive: metadata.interactive,
      style: if metadata.type_ == BoolOpt {
        Some("flag")
      } else {
        None
      },
      short: if metadata.short != no_short {
        Some(metadata.short.to_string())
      } else {
        None
      },
      env: metadata.env,
      config: option.config,
      default_value: metadata.default_value,
    }
  }
  Some(result)
}

///|
fn schema_positionals(
  positionals : Array[StoredPosition],
) -> Map[String, PositionSchema]? {
  if positionals.is_empty() {
    return None
  }
  let result = Map([])
  for position in positionals {
    let metadata = position.metadata
    result[position.name] = PositionSchema::{
      kind: option_type_to_string(metadata.type_),
      description: metadata.description,
      required: metadata.required,
      multiple: metadata.multiple,
      interactive: metadata.interactive,
      config: position.config,
    }
  }
  Some(result)
}

///|
fn generate_example(cmd_path : String, options : Array[StoredOption]) -> String {
  let parts : Array[String] = [cmd_path]
  for opt in options {
    if opt.metadata.required {
      parts.push("--" + opt.name + " <" + opt.name + ">")
    }
  }
  parts.join(" ")
}

///|
fn schema_commands(
  commands : Array[CommandDef],
  parent_path : String,
) -> Map[String, CommandSchema]? {
  if commands.is_empty() {
    return None
  }
  let result = Map([])
  for command in commands {
    let path = parent_path + " " + command.name
    let examples = if !command.examples.is_empty() {
      Some(command.examples)
    } else if !command.options.is_empty() || !command.positionals.is_empty() {
      Some([generate_example(path, command.options)])
    } else {
      None
    }
    result[command.name] = CommandSchema::{
      description: command.description,
      options: schema_options(command.options),
      positionals: schema_positionals(command.positionals),
      examples,
      commands: schema_commands(command.subcommands, path),
    }
  }
  Some(result)
}

///|
/// Serializes a `CliApp` into the JSON value used by `render_schema`.
pub impl ToJson for CliApp with fn to_json(self) -> Json {
  ToJson::to_json(CliSchema::{
    name: self.name,
    version: self.version,
    description: self.description,
    options: schema_options(self.root_options),
    positionals: schema_positionals(self.root_positionals),
    commands: schema_commands(self.commands, self.name),
  })
}

///|
pub extend CliApp with ToJson::{to_json}

///|
/// Renders the complete CLI definition as a JSON string for documentation and
/// tooling integrations.
pub fn CliApp::render_schema(self : CliApp) -> String {
  self.to_json().stringify()
}
