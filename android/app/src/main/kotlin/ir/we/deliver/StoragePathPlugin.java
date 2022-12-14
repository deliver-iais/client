package ir.we.deliver;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.webkit.MimeTypeMap;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import com.nabinbhandari.android.permissions.PermissionHandler;
import com.nabinbhandari.android.permissions.Permissions;

import io.flutter.plugin.common.MethodChannel.Result;


import java.lang.reflect.Type;
import java.util.*;

/**
 * StoragePathPlugin
 */
public class StoragePathPlugin {

    public static ArrayList<FileModel> filesModelArrayList;

    Activity activity;

    public StoragePathPlugin(Activity activity) {
        this.activity = activity;
    }


    public void getAudioPath(Result result) {
        Permissions.check(activity, Manifest.permission.READ_MEDIA_AUDIO, null, new PermissionHandler() {
            @Override
            public void onGranted() {
                getAllAudio(result);
            }

            @Override
            public void onDenied(Context context, ArrayList<String> deniedPermissions) {
                result.error("1", "Permission denied", null);
            }
        });

    }

    private void getAllAudio(Result result) {
        try {
            List<String> allMusicPath = new ArrayList<>();
            //retrieve song info
            ContentResolver musicResolver = activity.getContentResolver();
            Uri musicUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
            Cursor musicCursor = musicResolver.query(musicUri, null, null, null, null);

            if (musicCursor != null && musicCursor.moveToFirst()) {
                //get columns
                int data = musicCursor.getColumnIndex
                        (MediaStore.Audio.Media.DATA);
                do {
                    allMusicPath.add((musicCursor.getString(data)));
                } while (musicCursor.moveToNext());
            }
            Gson gson = new GsonBuilder().create();

            result.success(gson.toJson(allMusicPath));
        } catch (Exception e) {
            result.error("1", e.toString(), null);
        }
    }
}
