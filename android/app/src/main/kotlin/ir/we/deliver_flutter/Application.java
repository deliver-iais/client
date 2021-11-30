package ir.we.deliver;

import android.app.Activity;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.os.Bundle;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.embedding.android.FlutterActivity;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;

import io.flutter.plugins.pathprovider.PathProviderPlugin;

public class Application extends FlutterActivity implements PluginRegistrantCallback {
    private static final String CHANNEL = "flutter.native/helper";
    private static final String GET_MEDIA_CHANNEL = "read_external";
    Activity activity;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        StoragePathPlugin storagePathPlugin = new StoragePathPlugin(this);
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), GET_MEDIA_CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("get_all_image")) {
                            storagePathPlugin.getImagePaths(result);
                        } else if (call.method.equals("get_all_music")) {
                            storagePathPlugin.getAudioPath(result);

                        } else if (call.method.equals("get_all_file")) {
                            storagePathPlugin.getFilesPath(result);
                        }
                    }
                });


    }


    @Override
    public void registerWith(PluginRegistry registry) {
        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    }

}