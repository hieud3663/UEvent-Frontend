package com.example.frontend

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DOWNLOADS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveFile" -> {
                        val fileName = call.argument<String>("fileName")
                        val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                        val bytes = call.argument<ByteArray>("bytes")

                        if (fileName.isNullOrBlank() || bytes == null) {
                            result.error("invalid_args", "Thiếu tên file hoặc dữ liệu file.", null)
                            return@setMethodCallHandler
                        }

                        try {
                            result.success(saveFileToDownloads(fileName, mimeType, bytes))
                        } catch (error: Exception) {
                            result.error("save_failed", error.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun saveFileToDownloads(
        fileName: String,
        mimeType: String,
        bytes: ByteArray,
    ): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveFileToDownloadsWithMediaStore(fileName, mimeType, bytes)
        } else {
            saveFileToLegacyDownloads(fileName, bytes)
        }
    }

    private fun saveFileToDownloadsWithMediaStore(
        fileName: String,
        mimeType: String,
        bytes: ByteArray,
    ): String {
        val resolver = applicationContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }

        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IOException("Không thể tạo file trong Downloads.")

        try {
            resolver.openOutputStream(uri)?.use { outputStream ->
                outputStream.write(bytes)
            } ?: throw IOException("Không thể mở file Downloads để ghi.")

            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return uri.toString()
        } catch (error: Exception) {
            resolver.delete(uri, null, null)
            throw error
        }
    }

    private fun saveFileToLegacyDownloads(fileName: String, bytes: ByteArray): String {
        val downloadsDirectory = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS,
        )
        if (!downloadsDirectory.exists() && !downloadsDirectory.mkdirs()) {
            throw IOException("Không thể tạo thư mục Downloads.")
        }

        val file = File(downloadsDirectory, fileName)
        FileOutputStream(file).use { outputStream ->
            outputStream.write(bytes)
        }
        return file.absolutePath
    }

    companion object {
        private const val DOWNLOADS_CHANNEL = "app.uevent/downloads"
    }
}
