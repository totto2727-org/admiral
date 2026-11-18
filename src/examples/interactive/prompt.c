#include <moonbit.h>
#include <fcntl.h>

#ifdef _WIN32
#include <io.h>
#define open _open
#define read _read
#define close _close
#define isatty _isatty
#define TERMINAL_INPUT "CONIN$"
#else
#include <unistd.h>
#define TERMINAL_INPUT "/dev/tty"
#endif

MOONBIT_FFI_EXPORT int32_t admiral_example_open_prompt_input(void) {
  return isatty(0) ? 0 : open(TERMINAL_INPUT, O_RDONLY);
}

MOONBIT_FFI_EXPORT int32_t admiral_example_read_prompt_byte(int32_t fd) {
  unsigned char byte;
  return fd >= 0 && read(fd, &byte, 1) == 1 ? byte : -1;
}

MOONBIT_FFI_EXPORT void admiral_example_close_prompt_input(int32_t fd) {
  if (fd > 0) {
    close(fd);
  }
}
