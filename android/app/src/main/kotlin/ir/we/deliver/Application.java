package ir.we.deliver;

import android.Manifest;
import android.app.Activity;

import android.content.Context;
import android.os.Environment;
import com.nabinbhandari.android.permissions.PermissionHandler;
import com.nabinbhandari.android.permissions.Permissions;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.os.Bundle;
import android.os.PowerManager;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


import io.flutter.embedding.android.FlutterActivity;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;

import io.flutter.plugins.pathprovider.PathProviderPlugin;

import java.util.ArrayList;
import io.flutter.embedding.engine.FlutterEngine;

public class Application extends FlutterActivity implements PluginRegistrantCallback {
    private static final String GET_MEDIA_CHANNEL = "read_external";
    private static final String GET_PATH_CHANNEL = "get_path";

    private static final String GET_SCREEN_CHANNEL = "screen_management";
    private PowerManager powerManager;
    private PowerManager.WakeLock wakeLock;
    private int field = 0x00000020;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        StoragePathPlugin storagePathPlugin = new StoragePathPlugin(this);

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), GET_MEDIA_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("get_all_image")) {
                        storagePathPlugin.getImagePaths(result);
                    } else if (call.method.equals("get_all_music")) {
                        storagePathPlugin.getAudioPath(result);
                    } else if (call.method.equals("get_all_file")) {
                        storagePathPlugin.getFilesPath(result);
                    }
                });

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), GET_PATH_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    String type = call.argument("type");
                    Permissions.check(this, Manifest.permission.WRITE_EXTERNAL_STORAGE, null, new PermissionHandler() {

                        @Override
                        public void onGranted() {
                            result.success(Environment.getExternalStoragePublicDirectory(type).getPath());
                        }

                        @Override
                        public void onDenied(Context context, ArrayList<String> deniedPermissions) {
                            result.error("1", "Permission denied", null);
                        }
                    });

                });

        try {
            // Yeah, this is hidden field.
            field = PowerManager.class.getClass().getField("PROXIMITY_SCREEN_OFF_WAKE_LOCK").getInt(null);
        } catch (Throwable ignored) {
        }
        powerManager = (PowerManager) getSystemService(POWER_SERVICE);
        wakeLock = powerManager.newWakeLock(field, getLocalClassName());

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), GET_SCREEN_CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("turnOff")) {
                            if(!wakeLock.isHeld()) {
                                wakeLock.acquire();
                                System.out.println("turn Off");
                            }
                        }

                        if (call.method.equals("turnOn")) {
                            if(wakeLock.isHeld()) {
                                wakeLock.release();
                                System.out.println("turn On");
                            }
                        }
                    }
                });
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
    @Override
    public void registerWith(PluginRegistry registry) {
        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    }


}