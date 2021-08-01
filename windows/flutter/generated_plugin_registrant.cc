//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <dart_vlc/dart_vlc_plugin.h>
#include <desktoasts/desktoasts_plugin.h>
#include <file_selector_windows/file_selector_plugin.h>
#include <url_launcher_windows/url_launcher_plugin.h>
#include <window_size/window_size_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DartVlcPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DartVlcPlugin"));
  DesktoastsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktoastsPlugin"));
  FileSelectorPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorPlugin"));
  UrlLauncherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherPlugin"));
  WindowSizePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowSizePlugin"));
}
