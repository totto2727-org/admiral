///|
extern "js" fn read_project_name() -> String =
  #| () => {
  #|   const fs = require('node:fs');
  #|   const useStdin = process.stdin.isTTY;
  #|   const fd = useStdin ? process.stdin.fd : fs.openSync('/dev/tty', 'r');
  #|   try {
  #|     const byte = Buffer.alloc(1);
  #|     const line = [];
  #|     while (fs.readSync(fd, byte, 0, 1, null) !== 0 && byte[0] !== 10) {
  #|       line.push(byte[0]);
  #|     }
  #|     return Buffer.from(line).toString('utf8');
  #|   } finally {
  #|     if (!useStdin) fs.closeSync(fd);
  #|   }
  #| }
