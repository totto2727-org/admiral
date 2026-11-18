#include <moonbit.h>

#ifdef _WIN32
#include <windows.h>

MOONBIT_FFI_EXPORT int32_t admiral_has_input_tty(void) {
  DWORD mode;
  if (GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), &mode)) {
    return 1;
  }
  HANDLE console = CreateFileA("CONIN$", GENERIC_READ,
                               FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
                               OPEN_EXISTING, 0, NULL);
  if (console == INVALID_HANDLE_VALUE) {
    return 0;
  }
  CloseHandle(console);
  return 1;
}
#else
#include <fcntl.h>
#include <unistd.h>

MOONBIT_FFI_EXPORT int32_t admiral_has_input_tty(void) {
  if (isatty(STDIN_FILENO)) {
    return 1;
  }
  int fd = open("/dev/tty", O_RDONLY);
  if (fd < 0) {
    return 0;
  }
  close(fd);
  return 1;
}
#endif
