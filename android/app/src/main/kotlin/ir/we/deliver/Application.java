package ir.we.deliver;

import android.Manifest;
import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Environment;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import com.nabinbhandari.android.permissions.PermissionHandler;
import com.nabinbhandari.android.permissions.Permissions;
import io.flutter.Log;
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

import java.io.*;
import java.util.ArrayList;


public class Application extends FlutterActivity implements PluginRegistrantCallback {
    private static final String GET_MEDIA_CHANNEL = "read_external";
    private static final String GET_PATH_CHANNEL = "get_path";



    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        StoragePathPlugin storagePathPlugin = new StoragePathPlugin(this);
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), GET_MEDIA_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("get_all_image")) {

                        try {
                            String dirPath = Environment.getExternalStoragePublicDirectory("DCIM").getPath();
                            File dir = new File(dirPath + "/pasf");

                            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "id")
                                    .setSmallIcon(R.mipmap.ic_launcher)
                                    .setContentTitle("My notification")
                                    .setContentText("Much longer text that cannot fit one line...")
                                    .setStyle(new NotificationCompat.BigTextStyle()
                                            .bigText("Much longer text that cannot fit one line..."))
                                    .setPriority(NotificationCompat.PRIORITY_DEFAULT);
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                CharSequence name = "sdsa";
                                String description = "des";
                                int importance = NotificationManager.IMPORTANCE_DEFAULT;
                                NotificationChannel channel = new NotificationChannel("123", name, importance);
                                channel.setDescription(description);
                                // Register the channel with the system; you can't change the importance
                                // or other notification behaviors after this
                                NotificationManager notificationManager = getSystemService(NotificationManager.class);
                                notificationManager.createNotificationChannel(channel);
                            }

                            NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);

// notificationId is a unique int for each notification that you must define
                            notificationManager.notify(3443, builder.build());


//                          try {
//                                BufferedReader br = new BufferedReader(new FileReader(file));
//                               String line;
//                              while ((line = br.readLine()) != null) {
//                                 text.append(line);
//                                  text.append('\n');
//                               }
//                               br.close();
//                           }
//                            catch (IOException e) {
//                               //You'll need to add proper error handling here
//                            }
                            if (!dir.exists()) {
                                dir.mkdirs();
                                Log.e("flutter", "add dir---------");
                            } else {
                                File newFile = new File(dir.getPath() + "/bugggsag" + ".txt");
                                FileWriter writer = new FileWriter(newFile);
                                writer.append("fgfg");
                                writer.flush();
                                writer.close();
                                Log.e("flutter", "file added");
                            }
                        } catch (Exception e) {
                            Log.e("add log exception ", e.toString());

                        }

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


    }


    @Override
    public void registerWith(PluginRegistry registry) {
        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    }


}