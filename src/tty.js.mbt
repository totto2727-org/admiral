///|
extern "js" fn has_input_tty() -> Bool =
  #| () => {
  #|   if (typeof process === 'undefined') return false;
  #|   if (process.stdin?.isTTY) return true;
  #|   try {
  #|     const fs = require('node:fs');
  #|     const fd = fs.openSync('/dev/tty', 'r');
  #|     fs.closeSync(fd);
  #|     return true;
  #|   } catch {
  #|     return false;
  #|   }
  #| }
