///|
pub extend OptionType with Debug::{to_repr}

///|
pub extend OptionType with Eq::{not_equal, equal}

///|
pub extend OptionType with Show::{to_string, output}

///|
pub extend OptionMetadata with Debug::{to_repr}

///|
pub extend PositionMetadata with Debug::{to_repr}

///|
pub extend ArgDef with Debug::{to_repr}

///|
pub extend NonEmptyArray with Debug::{to_repr}

///|
pub extend ConfigLoadFailure with Debug::{to_repr}

///|
pub extend ConfigLoadFailure with Eq::{not_equal, equal}

///|
pub extend ConfigLoadFailure with Show::{to_string, output}
