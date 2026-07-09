#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(900, 570);

  HKEY hKey;
  if (RegOpenKeyEx(HKEY_CURRENT_USER, L"Software\\MetallCalc", 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
    DWORD x, y, width, height;
    DWORD type = REG_DWORD;
    DWORD cbData = sizeof(DWORD);
    if (RegQueryValueEx(hKey, L"WindowLeft", nullptr, &type, reinterpret_cast<LPBYTE>(&x), &cbData) == ERROR_SUCCESS &&
        RegQueryValueEx(hKey, L"WindowTop", nullptr, &type, reinterpret_cast<LPBYTE>(&y), &cbData) == ERROR_SUCCESS &&
        RegQueryValueEx(hKey, L"WindowWidth", nullptr, &type, reinterpret_cast<LPBYTE>(&width), &cbData) == ERROR_SUCCESS &&
        RegQueryValueEx(hKey, L"WindowHeight", nullptr, &type, reinterpret_cast<LPBYTE>(&height), &cbData) == ERROR_SUCCESS) {
      origin = Win32Window::Point(x, y);
      size = Win32Window::Size(width, height);
    }
    RegCloseKey(hKey);
  }
  if (!window.Create(L"MetallCalc", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
