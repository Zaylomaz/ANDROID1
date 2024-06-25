package com.rempc.app

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.onesignal.OSNotification
import com.onesignal.OSNotificationOpenedResult
import com.onesignal.OSNotificationReceivedEvent
import com.onesignal.OneSignal
import org.json.JSONObject

class OneSignalNotificationOpenHandler(private val context : Context) : OneSignal.OSNotificationOpenedHandler {
    override fun notificationOpened(result: OSNotificationOpenedResult?) {
        if (result == null) return

        try {
            val data = result.notification.additionalData
            val channelId = data.optString("channel_id", "")
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "Chat",
                Service.MODE_PRIVATE
            )
            sharedPref.edit()
                .putString("channel_id", channelId)
                .apply()

            if (channelId != "") {
                MainActivity.sendChatEvent(
                    "CHECK_NOTIFICATION", mapOf(
                        "action" to "check",
                    )
                )
            }
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }

//        val intent = Intent(context, MainActivity::class.java)
//        intent.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_NEW_TASK
//        intent.putExtra("channel_id", channelId)
//        context.startActivity(intent)
    }
}

class OneSignalOnForeground(private val context: Context): OneSignal.OSNotificationWillShowInForegroundHandler {
    override fun notificationWillShowInForeground(notificationReceivedEvent: OSNotificationReceivedEvent?) {
        val notification = notificationReceivedEvent?.notification
        val additionalData = notification?.additionalData

        Log.d("OneSignalOnForeground", notification.toString())
        Log.d("OneSignalOnForeground", notification?.priority.toString())

        if (notification != null && notification.priority >= 0) {
            notificationReceivedEvent.complete(notification)
        }
        else {
            notificationReceivedEvent?.complete(null)
        }
    }

}