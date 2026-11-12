package com.ahorrant.ahorrant

import android.app.Notification
import android.content.Context
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

/**
 * Escucha notificaciones autorizadas por el usuario.
 *
 * Fuentes soportadas:
 *  - Yape (notificaciones propias de la app).
 *  - Gmail (correos de alerta bancaria que incluyen el monto).
 *
 * Guarda una cola corta en SharedPreferences para que Flutter la consuma
 * cuando este activo o al volver a abrir la app.
 */
class AhorrantNotificationService : NotificationListenerService() {

    companion object {
        private const val TAG = "AhorrantNotif"
        private const val PREFS = "ahorrant_notifications"
        private const val KEY_QUEUE = "pending_queue"
        private const val MAX_QUEUE = 50

        private val YAPE_PACKAGES = setOf(
            "com.bcp.innovacxion.yapeapp",
            "com.bcp.innovacxion.yape"
        )

        private val EMAIL_PACKAGES = setOf(
            "com.google.android.gm",
            "com.microsoft.office.outlook",
            "com.google.android.email"
        )

        // Apps de banca / billeteras peruanas (Plin, BCP, BBVA, etc.).
        private val BANK_PACKAGES = setOf(
            "pe.com.interbank.mobilebanking",
            "pe.indigital.tunki.user",
            "com.bcp.bank.bcp",
            "com.bbva.nxt_peru",
            "com.scotiabank.banking",
            "com.pdp.bim"
        )

        // Detecta indicios de monto en el texto del correo.
        private val MONEY_HINT = Regex(
            "(?i)(s\\s*/\\.?|soles|pen\\b|monto|consumo|compra|pago|transferencia|abono|deposito|depósito)"
        )

        /** Indica si el usuario concedio acceso al servicio de notificaciones. */
        fun isAccessGranted(context: Context): Boolean {
            val enabled = Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners"
            ) ?: return false
            return enabled.split(":").any { it.contains(context.packageName) }
        }

        /** Guarda una notificacion en la cola local. */
        fun enqueue(context: Context, packageName: String, title: String, text: String) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val queue = JSONArray(prefs.getString(KEY_QUEUE, "[]") ?: "[]")
            val item = JSONObject().apply {
                put("package", packageName)
                put("title", title)
                put("text", text)
                put("timestamp", System.currentTimeMillis())
            }
            queue.put(item)

            val trimmed = JSONArray()
            val start = maxOf(0, queue.length() - MAX_QUEUE)
            for (i in start until queue.length()) {
                trimmed.put(queue.get(i))
            }
            prefs.edit().putString(KEY_QUEUE, trimmed.toString()).apply()
        }

        /** Devuelve y vacia la cola de notificaciones pendientes. */
        fun drain(context: Context): JSONArray {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val queue = JSONArray(prefs.getString(KEY_QUEUE, "[]") ?: "[]")
            prefs.edit().putString(KEY_QUEUE, "[]").apply()
            return queue
        }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "Notification listener conectado")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.w(TAG, "Notification listener desconectado, solicitando reconexion...")
        // MIUI desconecta el listener; pedir reconexion automatica.
        requestRebind(android.content.ComponentName(this, javaClass))
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val statusBarNotification = sbn ?: return
        val packageName = statusBarNotification.packageName
        Log.d(TAG, "RECIBIDO de '$packageName'")
        val isYape = packageName in YAPE_PACKAGES
        val isEmail = packageName in EMAIL_PACKAGES
        val isBank = packageName in BANK_PACKAGES

        if (!isYape && !isEmail && !isBank) {
            Log.d(TAG, "Ignorado (paquete no soportado): '$packageName'")
            return
        }

        val notification = statusBarNotification.notification ?: return
        val extras = notification.extras ?: return

        val title = firstNonBlank(
            extras.getCharSequence(Notification.EXTRA_TITLE)?.toString(),
            extras.getCharSequence(Notification.EXTRA_TITLE_BIG)?.toString(),
            notification.tickerText?.toString()
        )

        val text = firstNonBlank(
            extras.getCharSequence(Notification.EXTRA_TEXT)?.toString(),
            extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString(),
            extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString(),
            notification.tickerText?.toString(),
            textLines(extras)
        )

        if (title.isBlank() && text.isBlank()) {
            Log.d(TAG, "Notificacion de $packageName sin titulo ni texto legible")
            return
        }

        if (isEmail) {
            // Los correos se registran solo si parecen contener un movimiento.
            val combinado = "$title $text"
            if (!MONEY_HINT.containsMatchIn(combinado)) {
                Log.d(TAG, "Correo sin indicios de monto, se ignora -> '$title | $text'")
                return
            }
            Log.d(TAG, "Correo con posible monto -> titulo='$title' texto='$text'")
        } else if (isBank) {
            val combinado = "$title $text"
            if (!MONEY_HINT.containsMatchIn(combinado)) {
                Log.d(TAG, "Banco sin indicios de monto, se ignora -> '$title | $text'")
                return
            }
            Log.d(TAG, "Banco/Plin con posible monto -> titulo='$title' texto='$text'")
        } else {
            Log.d(TAG, "Yape detectado -> titulo='$title' texto='$text'")
        }

        val context = applicationContext
        enqueue(context, packageName, title, text)
        Log.d(TAG, "Notificacion encolada -> '$title | $text'")
        MainActivity.notifyFlutter(title, text, System.currentTimeMillis(), packageName)
    }

    private fun firstNonBlank(vararg values: String?): String {
        return values.firstOrNull { !it.isNullOrBlank() } ?: ""
    }

    private fun textLines(extras: android.os.Bundle): String {
        val lines = extras.getCharSequenceArray(Notification.EXTRA_TEXT_LINES)
            ?: return ""
        return lines.joinToString(" ") { it?.toString() ?: "" }
    }
}
