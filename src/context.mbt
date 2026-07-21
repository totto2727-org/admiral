///|
pub fn Context::get_bool(self : Context, name : String) -> Bool {
  self.flags.get(name).unwrap_or(false)
}

///|
pub fn Context::get_string(self : Context, name : String) -> String? {
  match self.values.get(name) {
    Some(arr) => if arr.length() > 0 { Some(arr[0]) } else { None }
    None => None
  }
}

///|
pub fn Context::get_string_required(
  self : Context,
  name : String,
) -> String raise {
  match self.get_string(name) {
    Some(v) => v
    None => fail("missing required option: " + name)
  }
}

///|
pub fn Context::get_int(self : Context, name : String) -> Int? {
  match self.get_string(name) {
    Some(s) => Some(@string.parse_int(s, base=10)) catch { _ => None }
    None => None
  }
}

///|
pub fn Context::get_int_required(self : Context, name : String) -> Int raise {
  match self.get_int(name) {
    Some(v) => v
    None => fail("missing or invalid required option: " + name)
  }
}

///|
pub fn Context::get_int64(self : Context, name : String) -> Int64? {
  match self.get_string(name) {
    Some(s) => Some(@string.parse_int64(s, base=10)) catch { _ => None }
    None => None
  }
}

///|
pub fn Context::get_int64_required(
  self : Context,
  name : String,
) -> Int64 raise {
  match self.get_int64(name) {
    Some(v) => v
    None => fail("missing or invalid required option: " + name)
  }
}

///|
pub fn Context::get_uint(self : Context, name : String) -> UInt? {
  match self.get_string(name) {
    Some(s) => Some(@string.parse_uint(s, base=10)) catch { _ => None }
    None => None
  }
}

///|
pub fn Context::get_uint_required(self : Context, name : String) -> UInt raise {
  match self.get_uint(name) {
    Some(v) => v
    None => fail("missing or invalid required option: " + name)
  }
}

///|
pub fn Context::get_uint64(self : Context, name : String) -> UInt64? {
  match self.get_string(name) {
    Some(s) => Some(@string.parse_uint64(s, base=10)) catch { _ => None }
    None => None
  }
}

///|
pub fn Context::get_uint64_required(
  self : Context,
  name : String,
) -> UInt64 raise {
  match self.get_uint64(name) {
    Some(v) => v
    None => fail("missing or invalid required option: " + name)
  }
}

///|
pub fn Context::get_double(self : Context, name : String) -> Double? {
  match self.get_string(name) {
    Some(s) => Some(@string.parse_double(s)) catch { _ => None }
    None => None
  }
}

///|
pub fn Context::get_double_required(
  self : Context,
  name : String,
) -> Double raise {
  match self.get_double(name) {
    Some(v) => v
    None => fail("missing or invalid required option: " + name)
  }
}

///|
pub fn Context::get_strings(self : Context, name : String) -> Array[String] {
  self.values.get(name).unwrap_or([])
}

///|
pub fn Context::get_subcommand(self : Context) -> (String, Context)? {
  self.subcommand
}
