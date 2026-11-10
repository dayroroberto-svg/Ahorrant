package com.ahorrant.ahorrant

import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.ahorrant/notifications"
        private val mainHandler = Handler(Looper.getMainLooper())

        @Volatile
        private var channel: MethodChannel? = null

        /** Envia una notificacion detectada a Flutter si la app esta activa. */
        fun notifyFlutter(
            title: String,
            text: String,
            timestamp: Long,
            packageName: String
        ) {
            mainHandler.post {
                channel?.invokeMethod(
                    "onNotification",
                    mapOf(
                        "package" to packageName,
                        "title" to title,
                        "text" to text,
                        "timestamp" to timestamp
                    )
                )
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel = methodChannel

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessGranted" -> {
                    result.success(AhorrantNotificationService.isAccessGranted(this))
                }

                "openNotificationSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }

                "getPendingNotifications" -> {
                    val queue = AhorrantNotificationService.drain(this)
                    val list = ArrayList<Map<String, Any?>>()
                    for (i in 0 until queue.length()) {
                        val item = queue.getJSONObject(i)
                        list.add(
                            mapOf(
                                "package" to item.optString("package"),
                                "title" to item.optString("title"),
                                "text" to item.optString("text"),
                                "timestamp" to item.optLong("timestamp")
                            )
                        )
                    }
                    result.success(list)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        channel = null
        super.onDestroy()
    }
}
