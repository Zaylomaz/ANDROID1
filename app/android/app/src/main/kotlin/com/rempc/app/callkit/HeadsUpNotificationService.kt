package com.rempc.app.callkit

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.rempc.app.AppNotificationChannel
import com.rempc.app.R


class HeadsUpNotificationService : Service() {
    private var callerName = "Входящий"
    var timer = 1
    var timerThread: Thread = object : Thread() {
        override fun run() {
            try {
                while (!isInterrupted) {
                    sleep(1000)
                    timer += 1
                    updateNotification()
                }
            } catch (e: InterruptedException) {
                FirebaseCrashlytics.getInstance().recordException(e)
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.extras != null) {
            callerName = intent.getStringExtra("caller_name").toString()
        }
        try {
            if (timerThread.isAlive) {
                timerThread.interrupt()
                timerThread = object : Thread() {
                    override fun run() {
                        try {
                            while (!isInterrupted) {
                                sleep(1000)
                                timer += 1
                                updateNotification()
                            }
                        } catch (e: InterruptedException) {
                            FirebaseCrashlytics.getInstance().recordException(e)
                        }
                    }
                }
                timer = 1
            }
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
        try {
            val cancelCallAction =
                Intent(applicationContext, HeadsUpNotificationActionReceiver::class.java)
                    .putExtra(
                        "RESPONSE_ACTION",
                        "CANCEL",
                    )
                    .setAction("CANCEL_CALL")
            val cancelCallPendingIntent: PendingIntent = PendingIntent.getBroadcast(
                applicationContext,
                1201,
                cancelCallAction,
                PendingIntent.FLAG_IMMUTABLE
            )
            createChannel()

            val notificationBuilder =
                NotificationCompat.Builder(this, AppNotificationChannel.SIP_CHANNEL.channelId)
                    .setContentText(callerName + ": " + getCallTimer())
                    .setContentTitle("Активный вызов")
                    .setSmallIcon(R.drawable.logo)
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                    .setCategory(NotificationCompat.CATEGORY_CALL)
                    .addAction(R.drawable.ic_decline, "Завершить", cancelCallPendingIntent)
                    .setOnlyAlertOnce(true)

            val incomingCallNotification = notificationBuilder.build()
            startForeground(120, incomingCallNotification)

            timerThread.start()
        } catch (e: Exception) {
            e.addSuppressed(Exception(timerThread.state.name))
            FirebaseCrashlytics.getInstance().recordException(e)
        }
        return START_STICKY
    }

    private fun updateNotification() {
        try {
            val cancelCallAction =
                Intent(applicationContext, HeadsUpNotificationActionReceiver::class.java).putExtra(
                    "RESPONSE_ACTION",
                    "CANCEL",
                ).setAction("CANCEL_CALL")
            val cancelCallPendingIntent: PendingIntent = PendingIntent.getBroadcast(
                applicationContext,
                1201,
                cancelCallAction,
                PendingIntent.FLAG_IMMUTABLE
            )

            val notificationBuilder =
                NotificationCompat.Builder(this, AppNotificationChannel.SIP_CHANNEL.channelId)
                    .setContentText(callerName + ": " + getCallTimer())
                    .setContentTitle("Активный вызов")
                    .setSmallIcon(R.drawable.logo)
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                    .setCategory(NotificationCompat.CATEGORY_CALL)
                    .addAction(R.drawable.ic_decline, "Завершить", cancelCallPendingIntent)
                    .setOnlyAlertOnce(true)
            val mNotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            mNotificationManager.notify(120, notificationBuilder.build())
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                AppNotificationChannel.SIP_CHANNEL.channelId,
                AppNotificationChannel.SIP_CHANNEL.title,
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = "Call Notifications"
            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun getCallTimer(): String {
        var strTemp: String
        val minutes = timer / 60
        val seconds = timer % 60
        strTemp =
            if (minutes < 10) "0$minutes:" else "$minutes:"
        strTemp =
            if (seconds < 10) strTemp + "0" + seconds.toString() else strTemp + seconds.toString()
        return strTemp
    }

    override fun onDestroy() {
        try {
            timerThread.interrupt()
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
        super.onDestroy()
    }
}
