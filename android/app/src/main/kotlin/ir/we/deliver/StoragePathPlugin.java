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
        String mp3 = MimeTypeMap.getSingleton().getMimeTypeFromExtension("mp3");
        String mp4 = MimeTypeMap.getSingleton().getMimeTypeFromExtension("mp4");
        String pdf = MimeTypeMap.getSingleton().getMimeTypeFromExtension("pdf");
        String jpeg = MimeTypeMap.getSingleton().getMimeTypeFromExtension("jpeg");
        String jpg = MimeTypeMap.getSingleton().getMimeTypeFromExtension("jpg");
        String apk = MimeTypeMap.getSingleton().getMimeTypeFromExtension("apk");
        String txt = MimeTypeMap.getSingleton().getMimeTypeFromExtension("txt");
        String doc = MimeTypeMap.getSingleton().getMimeTypeFromExtension("doc");
        String docx = MimeTypeMap.getSingleton().getMimeTypeFromExtension("docx");
        String zip = MimeTypeMap.getSingleton().getMimeTypeFromExtension("zip");
        String rar = MimeTypeMap.getSingleton().getMimeTypeFromExtension("rar");
        String webp = MimeTypeMap.getSingleton().getMimeTypeFromExtension("webp");
        String ogg = MimeTypeMap.getSingleton().getMimeTypeFromExtension("ogg");
        String svg = MimeTypeMap.getSingleton().getMimeTypeFromExtension("svg");
        String csv = MimeTypeMap.getSingleton().getMimeTypeFromExtension("csv");
        String xls = MimeTypeMap.getSingleton().getMimeTypeFromExtension("xls");
        String gif = MimeTypeMap.getSingleton().getMimeTypeFromExtension("gif");
        String png = MimeTypeMap.getSingleton().getMimeTypeFromExtension("png");
        String m4a = MimeTypeMap.getSingleton().getMimeTypeFromExtension("m4a");
        String xml = MimeTypeMap.getSingleton().getMimeTypeFromExtension("xml");
        String pptx = MimeTypeMap.getSingleton().getMimeTypeFromExtension("pptx");
        String xlsm = MimeTypeMap.getSingleton().getMimeTypeFromExtension("xlsm");
        String xlsx = MimeTypeMap.getSingleton().getMimeTypeFromExtension("xlsx");
        String crt = MimeTypeMap.getSingleton().getMimeTypeFromExtension("crt");
        String tsg = MimeTypeMap.getSingleton().getMimeTypeFromExtension("tsg");
        String mkv = MimeTypeMap.getSingleton().getMimeTypeFromExtension("mkv");
        String jfif = MimeTypeMap.getSingleton().getMimeTypeFromExtension("jfif");
        String ico = MimeTypeMap.getSingleton().getMimeTypeFromExtension("ico");
        String wav = MimeTypeMap.getSingleton().getMimeTypeFromExtension("wav");
        String opus = MimeTypeMap.getSingleton().getMimeTypeFromExtension("opus");
        String pem = MimeTypeMap.getSingleton().getMimeTypeFromExtension("pem");
        String ipa = MimeTypeMap.getSingleton().getMimeTypeFromExtension("ipa");
        String tar = MimeTypeMap.getSingleton().getMimeTypeFromExtension("tar");
        String gzip = MimeTypeMap.getSingleton().getMimeTypeFromExtension("gzip");
        String psd = MimeTypeMap.getSingleton().getMimeTypeFromExtension("psd");
        String env = MimeTypeMap.getSingleton().getMimeTypeFromExtension("env");
        String exe = MimeTypeMap.getSingleton().getMimeTypeFromExtension("exe");
        String json = MimeTypeMap.getSingleton().getMimeTypeFromExtension("json");
        String html = MimeTypeMap.getSingleton().getMimeTypeFromExtension("html");
        String css = MimeTypeMap.getSingleton().getMimeTypeFromExtension("css");
        String scss = MimeTypeMap.getSingleton().getMimeTypeFromExtension("scss");
        String js = MimeTypeMap.getSingleton().getMimeTypeFromExtension("js");
        String ts = MimeTypeMap.getSingleton().getMimeTypeFromExtension("ts");
        String java = MimeTypeMap.getSingleton().getMimeTypeFromExtension("java");
        String kt = MimeTypeMap.getSingleton().getMimeTypeFromExtension("kt");
        String yaml = MimeTypeMap.getSingleton().getMimeTypeFromExtension("yaml");
        String yml = MimeTypeMap.getSingleton().getMimeTypeFromExtension("yml");
        String properties = MimeTypeMap.getSingleton().getMimeTypeFromExtension("properties");
        String srt = MimeTypeMap.getSingleton().getMimeTypeFromExtension("srt");
        String py = MimeTypeMap.getSingleton().getMimeTypeFromExtension("py");
        String conf = MimeTypeMap.getSingleton().getMimeTypeFromExtension("conf");
        String config = MimeTypeMap.getSingleton().getMimeTypeFromExtension("config");
        String icns = MimeTypeMap.getSingleton().getMimeTypeFromExtension("icns");
        String dart = MimeTypeMap.getSingleton().getMimeTypeFromExtension("dart");
        String c = MimeTypeMap.getSingleton().getMimeTypeFromExtension("c");
        String md = MimeTypeMap.getSingleton().getMimeTypeFromExtension("md");
        String bmp = MimeTypeMap.getSingleton().getMimeTypeFromExtension("bmp");
        String pom = MimeTypeMap.getSingleton().getMimeTypeFromExtension("pom");
        String jar = MimeTypeMap.getSingleton().getMimeTypeFromExtension("jar");
        String msi = MimeTypeMap.getSingleton().getMimeTypeFromExtension("msi");
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
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?"
                + " OR " + MediaStore.Files.FileColumns.MIME_TYPE + "=?";

        final String[] selectionArgs = new String[]{mp3, mp4, pdf, jpeg, jpg, apk, txt, doc, docx, zip, tar, webp, ogg, svg, csv, xls, gif, png, m4a, xml, pptx, xlsm, xlsx, crt, tsg, mkv, jfif, ico, wav, opus, pem, ipa, tar, gzip, psd, env, exe, json, html, css, scss, js, ts, java, kt, yaml, yml, properties, srt, xml, py, conf, config, icns, dart, c, md, bmp, pom, jar, msi, webm};

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
