//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <desktoasts/desktoasts_plugin.h>
#include <desktop_drop/desktop_drop_plugin.h>
#include <desktop_lifecycle/desktop_lifecycle_plugin.h>
#include <desktop_window/desktop_window_plugin.h>
#include <image_compression_flutter/image_compression_flutter_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <window_size/window_size_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DesktoastsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktoastsPlugin"));
  DesktopDropPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopDropPlugin"));
  DesktopLifecyclePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopLifecyclePlugin"));
  DesktopWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopWindowPlugin"));
  ImageCompressionFlutterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ImageCompressionFlutterPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WindowSizePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowSizePlugin"));
}
