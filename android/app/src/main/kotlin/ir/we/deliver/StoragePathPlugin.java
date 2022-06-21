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


    public void getImagePaths(Result result) {
        Permissions.check(activity, Manifest.permission.READ_EXTERNAL_STORAGE, null, new PermissionHandler() {

            @Override
            public void onGranted() {
                getAllImage(result);
            }

            @Override
            public void onDenied(Context context, ArrayList<String> deniedPermissions) {
                result.error("1", "Permission denied", null);
            }
        });

    }

    private void getAllImage(Result result) {
        try {
            filesModelArrayList = new ArrayList<>();
            boolean hasFolder = false;
            int position = 0;
            Uri uri;
            Cursor cursor;
            int column_index_data, column_index_folder_name;

            String absolutePathOfImage;
            uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;

            String[] projection = {
                    MediaStore.MediaColumns.DATA,
                    MediaStore.Images.Media.BUCKET_DISPLAY_NAME};

            final String orderBy = MediaStore.Images.Media.DATE_TAKEN;
            cursor = activity.getContentResolver().query(uri, projection, null, null, orderBy + " DESC");

            column_index_data = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA);
            column_index_folder_name = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME);
            while (cursor.moveToNext()) {
                absolutePathOfImage = cursor.getString(column_index_data);

                for (int i = 0; i < filesModelArrayList.size(); i++) {
                    if (filesModelArrayList.get(i) != null &&
                            filesModelArrayList.get(i).getFolder() != null &&
                            filesModelArrayList.get(i).getFolder().equals(cursor.getString(column_index_folder_name))) {
                        hasFolder = true;
                        position = i;
                        break;
                    } else {
                        hasFolder = false;
                    }
                }


                if (hasFolder) {
                    ArrayList<String> arrayList = new ArrayList<>();
                    arrayList.addAll(filesModelArrayList.get(position).getFiles());
                    arrayList.add(absolutePathOfImage);
                    filesModelArrayList.get(position).setFiles(arrayList);

                } else {
                    ArrayList<String> arrayList = new ArrayList<>();
                    arrayList.add(absolutePathOfImage);
                    FileModel obj_model = new FileModel();
                    obj_model.setFolder(cursor.getString(column_index_folder_name));
                    obj_model.setFiles(arrayList);

                    filesModelArrayList.add(obj_model);

                }

            }
            Gson gson = new GsonBuilder().create();
//            Type listType = new TypeToken() {
//            }.getType();
            String json = gson.toJson(filesModelArrayList);
            if (cursor != null) {
                cursor.close();
            }
            result.success(json);
        } catch (Exception e) {
            result.success(e.toString());
        }

    }


    public void getAudioPath(Result result) {
        Permissions.check(activity, Manifest.permission.READ_EXTERNAL_STORAGE, null, new PermissionHandler() {
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


    public void getFilesPath(Result result) {
        Permissions.check(activity, Manifest.permission.READ_EXTERNAL_STORAGE, null, new PermissionHandler() {

            @RequiresApi(api = Build.VERSION_CODES.Q)
            @Override
            public void onGranted() {
                getAllFile(result);
            }

            @Override
            public void onDenied(Context context, ArrayList<String> deniedPermissions) {
                result.error("1", "Permission denied", null);
            }
        });

    }


    @RequiresApi(api = Build.VERSION_CODES.Q)
    private void getAllFile(Result result) {
        ArrayList<String> allFilePath = new ArrayList<>();
        Uri collection;

        final String[] projection = new String[]{
                MediaStore.Files.FileColumns.DISPLAY_NAME,
                MediaStore.Files.FileColumns.DATE_ADDED,
                MediaStore.Files.FileColumns.DATA,
                MediaStore.Files.FileColumns.MIME_TYPE,
        };

        final String sortOrder = MediaStore.Files.FileColumns.DATE_ADDED + " DESC";
        String pdf = MimeTypeMap.getSingleton().getMimeTypeFromExtension("pdf");
        String doc = MimeTypeMap.getSingleton().getMimeTypeFromExtension("doc");
        String docx = MimeTypeMap.getSingleton().getMimeTypeFromExtension("docx");
        String xls = MimeTypeMap.getSingleton().getMimeTypeFromExtension("xls");
        String xlsx = MimeTypeMap.getSingleton().getMimeTypeFromExtension("xlsx");
        String ppt = MimeTypeMap.getSingleton().getMimeTypeFromExtension("ppt");
        String pptx = MimeTypeMap.getSingleton().getMimeTypeFromExtension("pptx");
        String txt = MimeTypeMap.getSingleton().getMimeTypeFromExtension("txt");
        String rtx = MimeTypeMap.getSingleton().getMimeTypeFromExtension("rtx");
        String rtf = MimeTypeMap.getSingleton().getMimeTypeFromExtension("rtf");
        String html = MimeTypeMap.getSingleton().getMimeTypeFromExtension("html");
        String apk = MimeTypeMap.getSingleton().getMimeTypeFromExtension("apk");
        String mp4 = MimeTypeMap.getSingleton().getMimeTypeFromExtension("mp4");
        String zip = MimeTypeMap.getSingleton().getMimeTypeFromExtension("zip");
        String rar = MimeTypeMap.getSingleton().getMimeTypeFromExtension("rar");
        String mkv = MimeTypeMap.getSingleton().getMimeTypeFromExtension("mkv");
        String webm = MimeTypeMap.getSingleton().getMimeTypeFromExtension("webm");


        String where = MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?";
        final String[] selectionArgs = new String[]{rtx, pdf, doc, docx, xls, xlsx, pptx, txt, rtf, html, ppt, apk, mp4, zip, rar, mkv, webm};

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI;
        } else {
            collection = MediaStore.Files.getContentUri("external");
        }

        try (Cursor cursor = activity.getContentResolver().query(collection, projection, where, selectionArgs, sortOrder)) {
            assert cursor != null;

            if (cursor.moveToFirst()) {
                int columnData = cursor.getColumnIndex(MediaStore.Files.FileColumns.DATA);
                do {
                    allFilePath.add((cursor.getString(columnData)));
                } while (cursor.moveToNext());
            }
        }
        Gson gson = new GsonBuilder().create();

        result.success(gson.toJson(allFilePath));
    }
}
