///|
extern "C" fn open_prompt_input() -> Int32 = "admiral_example_open_prompt_input"

///|
extern "C" fn read_prompt_byte(fd : Int32) -> Int32 = "admiral_example_read_prompt_byte"

///|
extern "C" fn close_prompt_input(fd : Int32) -> Unit = "admiral_example_close_prompt_input"

///|
fn read_project_name() -> String raise {
  let fd = open_prompt_input()
  defer close_prompt_input(fd)
  let line = Buffer()
  while read_prompt_byte(fd) is byte && byte >= 0 && byte != 10 {
    line.write_byte(byte.to_byte())
  }
  @utf8.decode(line.to_bytes()[:])
}
