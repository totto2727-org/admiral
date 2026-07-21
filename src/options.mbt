///|
/// sentinel value for "no short flag"
let no_short : Char = '\u0000'

///|
pub fn string(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  required? : Bool = false,
  default? : String? = None,
) -> OptionDef {
  {
    name,
    type_: StringOpt,
    short,
    description,
    env,
    required: match default {
      Some(_) => false
      None => required
    },
    default_value: default,
  }
}

///|
pub fn bool(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
) -> OptionDef {
  {
    name,
    type_: BoolOpt,
    short,
    description,
    env,
    required: false,
    default_value: None,
  }
}

///|
pub fn int(
  name : String,
  short? : Char = '\u0000',
  description? : String = "",
  env? : String,
  required? : Bool = false,
  default? : Int? = None,
) -> OptionDef {
  {
    name,
    type_: IntOpt,
    short,
    description,
    env,
    required: match default {
      Some(_) => false
      None => required
    },
    default_value: match default {
      Some(v) => Some(v.to_string())
      None => None
    },
  }
}
