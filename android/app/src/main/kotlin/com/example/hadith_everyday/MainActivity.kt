package com.example.hadith_everyday

import android.app.WallpaperManager
import android.content.ContentValues
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.haditheveryday/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaper" -> {
                        val imagePath = call.argument<String>("imagePath")
                        val screen = call.argument<String>("screen") ?: "both"
                        if (imagePath != null) {
                            setWallpaperFromPath(imagePath, screen, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "imagePath is null", null)
                        }
                    }
                    "saveToGallery" -> {
                        val imagePath = call.argument<String>("imagePath")
                        if (imagePath != null) {
                            saveImageToGallery(imagePath, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "imagePath is null", null)
                        }
                    }
                    "isWallpaperSupported" -> {
                        val manager = WallpaperManager.getInstance(applicationContext)
                        result.success(manager.isWallpaperSupported)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setWallpaperFromPath(
        imagePath: String,
        screen: String,
        result: MethodChannel.Result
    ) {
        try {
            val wm = WallpaperManager.getInstance(applicationContext)
            if (!wm.isWallpaperSupported) {
                result.error("NOT_SUPPORTED", "Wallpaper not supported", null)
                return
            }
            val bitmap = BitmapFactory.decodeFile(imagePath)
                ?: run {
                    result.error("DECODE_ERROR", "Failed to decode $imagePath", null)
                    return
                }
            val flag = when (screen) {
                "lock" -> WallpaperManager.FLAG_LOCK
                "both" -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                else   -> WallpaperManager.FLAG_SYSTEM
            }
            wm.setBitmap(bitmap, null, true, flag)
            result.success(true)
        } catch (e: Exception) {
            result.error("WALLPAPER_ERROR", e.localizedMessage, null)
        }
    }

    private fun saveImageToGallery(imagePath: String, result: MethodChannel.Result) {
        try {
            val file = File(imagePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "Image not found: $imagePath", null)
                return
            }
            val fileName = "hadith_${System.currentTimeMillis()}.png"

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+ — use MediaStore (no WRITE_EXTERNAL_STORAGE needed)
                val values = ContentValues().apply {
                    put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
                    put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                    put(MediaStore.Images.Media.RELATIVE_PATH,
                        Environment.DIRECTORY_PICTURES + "/DailyHadith")
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }
                val resolver = contentResolver
                val uri = resolver.insert(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                    ?: run {
                        result.error("INSERT_FAILED", "MediaStore insert returned null", null)
                        return
                    }
                resolver.openOutputStream(uri)?.use { out ->
                    FileInputStream(file).use { it.copyTo(out) }
                }
                values.clear()
                values.put(MediaStore.Images.Media.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
            } else {
                // Android 9 and below
                val destDir = File(
                    Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_PICTURES), "DailyHadith")
                destDir.mkdirs()
                val dest = File(destDir, fileName)
                file.copyTo(dest, overwrite = true)
                // Trigger media scan
                val scanIntent = android.content.Intent(
                    android.content.Intent.ACTION_MEDIA_SCANNER_SCAN_FILE,
                    android.net.Uri.fromFile(dest))
                sendBroadcast(scanIntent)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", e.localizedMessage, null)
        }
    }
}
