//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <dart_vlc/dart_vlc_plugin.h>
#include <desktoasts/desktoasts_plugin.h>
#include <desktop_drop/desktop_drop_plugin.h>
#include <flutter_webrtc/flutter_web_r_t_c_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <window_size/window_size_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DartVlcPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DartVlcPlugin"));
  DesktoastsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktoastsPlugin"));
  DesktopDropPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopDropPlugin"));
  FlutterWebRTCPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWebRTCPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WindowSizePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowSizePlugin"));
}
