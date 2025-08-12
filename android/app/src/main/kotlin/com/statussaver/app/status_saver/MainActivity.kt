package com.statussaver.app.status_saver

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.app.Activity
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "com.statussaver.gallery"
    private var treePickResult: MethodChannel.Result? = null
    private val REQUEST_TREE = 9911

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveFile" -> {
                        val args = call.arguments as? Map<*, *>
                        val path = args?.get("path") as? String
                        val isVideo = args?.get("isVideo") as? Boolean ?: false
                        if (path.isNullOrEmpty()) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        try {
                            val ok = saveFileToGallery(path, isVideo)
                            result.success(ok)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    "queryStatusesImages" -> {
                        try {
                            val list = queryStatuses(false)
                            result.success(list)
                        } catch (e: Exception) {
                            result.success(emptyList<Map<String, Any?>>())
                        }
                    }
                    "queryStatusesVideos" -> {
                        try {
                            val list = queryStatuses(true)
                            result.success(list)
                        } catch (e: Exception) {
                            result.success(emptyList<Map<String, Any?>>())
                        }
                    }
                    "pickStatusesTree" -> {
                        treePickResult = result
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
                        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
                        startActivityForResult(intent, REQUEST_TREE)
                    }
                    "listFromPickedTreeImages" -> {
                        val list = listFromPickedTree(false)
                        result.success(list)
                    }
                    "listFromPickedTreeVideos" -> {
                        val list = listFromPickedTree(true)
                        result.success(list)
                    }
                    "hasPickedTree" -> {
                        val has = hasPickedTree()
                        result.success(has)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_TREE) {
            val result = treePickResult
            treePickResult = null
            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val uri = data.data!!
                try {
                    contentResolver.takePersistableUriPermission(
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    )
                } catch (_: Exception) {}
                getSharedPreferences("status_saver", MODE_PRIVATE)
                    .edit()
                    .putString("tree_uri", uri.toString())
                    .apply()
                result?.success(true)
            } else {
                result?.success(false)
            }
        }
    }

    private fun saveFileToGallery(sourcePath: String, isVideo: Boolean): Boolean {
        val sourceFile = File(sourcePath)
        if (!sourceFile.exists()) return false

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val collection: Uri = if (isVideo) {
                MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            } else {
                MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            }

            val fileName = sourceFile.name
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(
                    MediaStore.MediaColumns.MIME_TYPE,
                    if (isVideo) "video/mp4" else "image/jpeg"
                )
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    if (isVideo) "Movies/Status Saver" else "Pictures/Status Saver"
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

            val resolver = contentResolver
            val uri = resolver.insert(collection, values) ?: return false
            resolver.openOutputStream(uri)?.use { out ->
                FileInputStream(sourceFile).use { input ->
                    input.copyTo(out)
                }
            }
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            true
        } else {
            val targetDir = if (isVideo) {
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            } else {
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            }
            val album = File(targetDir, "Status Saver")
            if (!album.exists()) album.mkdirs()
            val dest = File(album, sourceFile.name)
            FileInputStream(sourceFile).use { input ->
                FileOutputStream(dest).use { out ->
                    input.copyTo(out)
                }
            }
            // Trigger media scan
            val scanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE).apply {
                data = Uri.fromFile(dest)
            }
            sendBroadcast(scanIntent)
            true
        }
    }
    private fun queryStatuses(isVideo: Boolean): List<Map<String, Any?>> {
        val resolver = contentResolver
        val collection: Uri = if (isVideo) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            } else MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            } else MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        }

        val projection = arrayOf(
            MediaStore.MediaColumns._ID,
            MediaStore.MediaColumns.DISPLAY_NAME,
            MediaStore.MediaColumns.MIME_TYPE,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
                MediaStore.MediaColumns.RELATIVE_PATH else MediaStore.MediaColumns.DATA,
            MediaStore.MediaColumns.DATE_MODIFIED
        )

        val selection: String
        val selectionArgs: Array<String>
        val like1 = "%WhatsApp/Media/.Statuses%"
        val like2 = "%WhatsApp Business/Media/.Statuses%"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            selection = "(${MediaStore.MediaColumns.RELATIVE_PATH} LIKE ? OR ${MediaStore.MediaColumns.RELATIVE_PATH} LIKE ?)"
            selectionArgs = arrayOf(like1, like2)
        } else {
            selection = "(${MediaStore.MediaColumns.DATA} LIKE ? OR ${MediaStore.MediaColumns.DATA} LIKE ?)"
            selectionArgs = arrayOf(like1, like2)
        }

        val list = mutableListOf<Map<String, Any?>>()
        resolver.query(collection, projection, selection, selectionArgs, MediaStore.MediaColumns.DATE_MODIFIED + " DESC")
            ?.use { cursor ->
                val idCol = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                val nameCol = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DISPLAY_NAME)
                val mimeCol = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.MIME_TYPE)
                val dateCol = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)

                val typeDir = File(cacheDir, if (isVideo) "status_cache_videos" else "status_cache_images")
                if (!typeDir.exists()) typeDir.mkdirs()

                while (cursor.moveToNext()) {
                    val id = cursor.getLong(idCol)
                    val name = cursor.getString(nameCol)
                    val mime = cursor.getString(mimeCol)
                    val date = cursor.getLong(dateCol)
                    val contentUri = Uri.withAppendedPath(collection, id.toString())

                    val dest = File(typeDir, name)
                    resolver.openInputStream(contentUri)?.use { input ->
                        FileOutputStream(dest).use { out ->
                            input.copyTo(out)
                        }
                    }

                    list.add(mapOf(
                        "path" to dest.absolutePath,
                        "mime" to mime,
                        "modified" to date
                    ))
                }
            }
        return list
    }
    private fun listFromPickedTree(isVideo: Boolean): List<Map<String, Any?>> {
        val prefs = getSharedPreferences("status_saver", MODE_PRIVATE)
        val uriString = prefs.getString("tree_uri", null) ?: return emptyList()
        val tree = DocumentFile.fromTreeUri(this, Uri.parse(uriString)) ?: return emptyList()

        fun findStatusesDir(root: DocumentFile): DocumentFile? {
            val candidates = listOf("WhatsApp", "WhatsApp Business")
            for (c in candidates) {
                val appDir = root.findFile(c) ?: continue
                val media = appDir.findFile("Media") ?: continue
                val statuses = media.findFile(".Statuses")
                if (statuses != null && statuses.isDirectory) return statuses
            }
            val statuses = root.findFile(".Statuses")
            return if (statuses != null && statuses.isDirectory) statuses else null
        }

        val statusesDir = findStatusesDir(tree) ?: return emptyList()
        val resolver = contentResolver
        val result = mutableListOf<Map<String, Any?>>()
        val cacheTypeDir = File(cacheDir, if (isVideo) "status_cache_videos" else "status_cache_images")
        if (!cacheTypeDir.exists()) cacheTypeDir.mkdirs()

        val files = statusesDir.listFiles()
        for (doc in files) {
            if (doc.isFile) {
                val name = doc.name ?: continue
                val isVid = name.toLowerCase().endsWith(".mp4")
                if ((isVideo && isVid) || (!isVideo && !isVid)) {
                    val dest = File(cacheTypeDir, name)
                    resolver.openInputStream(doc.uri)?.use { input ->
                        FileOutputStream(dest).use { out -> input.copyTo(out) }
                    }
                    result.add(mapOf(
                        "path" to dest.absolutePath,
                        "mime" to if (isVid) "video/mp4" else "image/jpeg",
                        "modified" to (doc.lastModified() / 1000)
                    ))
                }
            }
        }
        return result.sortedByDescending { it["modified"] as Long }
    }

    private fun hasPickedTree(): Boolean {
        val prefs = getSharedPreferences("status_saver", MODE_PRIVATE)
        return prefs.getString("tree_uri", null) != null
    }
}
