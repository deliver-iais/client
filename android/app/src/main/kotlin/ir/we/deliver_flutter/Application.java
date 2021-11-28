package ir.we.deliver;


import android.app.Activity;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.os.Bundle;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.embedding.android.FlutterActivity;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;

public class Application extends FlutterActivity implements PluginRegistrantCallback {
    private static final String CHANNEL = "flutter.native/helper";
    private static final String GET_MEDIA_CHANNEL = "get_media";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("helloFromNativeCode")) {
                            String greetings = "123456";
                            result.success(greetings);
                        }
                    }
                });
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), GET_MEDIA_CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        StoragePathPlugin(this);
                        result.success("sd");
                    }
                });
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    }

}