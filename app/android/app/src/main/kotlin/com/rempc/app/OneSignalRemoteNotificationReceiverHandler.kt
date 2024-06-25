package com.rempc.app


import android.app.NotificationManager
import android.app.Service
import android.content.ContentResolver
import android.content.Context
import android.content.SharedPreferences
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.util.Log
import com.google.gson.Gson
import com.onesignal.OSNotificationReceivedEvent
import com.onesignal.OneSignal
import com.rempc.app.eventBus.commands.*
import com.rempc.app.eventBus.commands.GetCurrentGPSLocationCommand
import io.flutter.embedding.android.FlutterActivity
import org.greenrobot.eventbus.EventBus
import org.json.JSONException

class OneSignalRemoteNotificationReceiverHandler : OneSignal.OSRemoteNotificationReceivedHandler {
    private val TAG = OneSignalRemoteNotificationReceiverHandler::class.qualifiedName
    private val START_AUDIO_RECORD_COMMAND = "startAudioRecord"
    private val STOP_AUDIO_RECORD_COMMAND = "stopAudioRecord"
    private val START_SERVICE_COMMAND = "startService"
    private val GET_CURRENT_GPS_LOCATION = "getCurrentGPSLocation"
    private val START_SIP_COMMAND = "startSip"
    private val STOP_SIP_COMMAND = "stopSip"

    override fun remoteNotificationReceived(
        context: Context,
        notificationReceivedEvent: OSNotificationReceivedEvent
    ) {
        val notification = notificationReceivedEvent.notification
        Log.i(TAG, "Notification received:")
        Log.i(TAG, "Title: ${notification.title}")
        Log.i(TAG, "Body: ${notification.body}")

        when (notification.body) {
            START_AUDIO_RECORD_COMMAND -> {
                Log.d("PUSH MESSAGE", "START_AUDIO_RECORD_COMMAND")
                EventBus.getDefault().post(StartAudioRecordCommand())
                notificationReceivedEvent.complete(null)
            }

            STOP_AUDIO_RECORD_COMMAND -> {
                Log.d("PUSH MESSAGE", "STOP_AUDIO_RECORD_COMMAND")
                EventBus.getDefault().post(StopAudioRecordCommand())
                notificationReceivedEvent.complete(null)

            }

            START_SERVICE_COMMAND -> {
                EventBus.getDefault().post(StopAudioRecordCommand())
                notificationReceivedEvent.complete(null)
            }

            GET_CURRENT_GPS_LOCATION -> {
                val location = LocationTrack(context).lastKnownGPSLocation
                if (location != null) {
                    val isFake = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        location.isMock
                    } else {
                        location.isFromMockProvider
                    }
                    EventBus.getDefault().post(
                        GetCurrentGPSLocationCommand(
                            location.latitude,
                            location.longitude,
                            isFake,
                            "gps"
                        )
                    )
                }
                notificationReceivedEvent.complete(null)

            }

            START_SIP_COMMAND -> {
                EventBus.getDefault().post(StartSipCommand())
                notificationReceivedEvent.complete(null)
            }

            STOP_SIP_COMMAND -> {
                EventBus.getDefault().post(StopSipCommand())
                notificationReceivedEvent.complete(null)
            }

            else -> {
                MainActivity.sendNotificationEvent(
                    "PUSH_NOTIFICATION", mapOf(
                        "title" to notification.title,
                        "body" to notification.body,
                        "rawPayload" to notification.rawPayload
                    )
                )
                try {
                    if (notification.additionalData != null && notification.additionalData.has("channel_id")) {
                        val channelId: Int = notification.additionalData.getInt("channel_id")
                        EventBus.getDefault().post(NewChatMessage(channelId))
                        val sharedPref: SharedPreferences = context.getSharedPreferences(
                            "Chat",
                            Service.MODE_PRIVATE
                        )
                        var currentChannelId = 0
                        try {
                            currentChannelId = sharedPref.getInt("current_channel_id", 0)
                        } catch (e: Exception) {

                        }
                        if (currentChannelId == channelId) {
                            try {
                                notificationReceivedEvent.complete(notification)
                            } catch (e: Exception) {
                                notificationReceivedEvent.complete(null)
                            }

                        } else {
                            notificationReceivedEvent.complete(notification)
                        }
                        return
                    }
                } catch (e: JSONException) {
                    Log.i(TAG, "Notification error: $e")
                }
                notificationReceivedEvent.complete(notification)
                Log.i(TAG, "Notification complete: ${notification.title} ${notification.body}")
            }
        }
    }
}

enum class NotificationSound(val value: Int, val title: String) {
    TELEGRAM(R.raw.telegram, "telegram"),
    OLD_CAR_HORN(R.raw.old_car_horn, "old_car_horn"),
    POPCORN(R.raw.popcorn, "popcorn"),
    AURORA(R.raw.aurora, "aurora"),
    BAMBOO(R.raw.bamboo, "bamboo"),
    BLOOM(R.raw.bloom, "bloom"),
    CALYPSO(R.raw.calypso, "calypso"),
    CANTINA_BAND(R.raw.cantina_band, "cantina_band"),
    CHOO_CHOO(R.raw.choo_choo, "choo_choo"),
    CHORD(R.raw.chord, "chord"),
    CIRCLES(R.raw.circles, "circles"),
    COMPLETE(R.raw.complete, "complete"),
    DESCENT(R.raw.descent, "descent"),
    DOORBELL(R.raw.doorbell, "doorbell"),
    FANFARE(R.raw.fanfare, "fanfare"),
    HEALTH_NOTIFICATION(R.raw.health_notification, "health_notification"),
    HELLO(R.raw.hello, "hello"),
    HILLSIDE(R.raw.hillside, "hillside"),
    INPUT(R.raw.input, "input"),
    KEYS(R.raw.keys, "keys"),
    LADDER(R.raw.ladder, "ladder"),
    MAIL_SENT(R.raw.mail_sent, "mail_sent"),
    NEW_MAIL(R.raw.new_mail, "new_mail"),
    NOIR(R.raw.noir, "noir"),
    NOTE(R.raw.note, "note"),
    NOTIFICATION_HAPTIC(R.raw.notification_haptic, "notification_haptic"),
    PULSE(R.raw.pulse, "pulse"),
    RECEIVED_MESSAGE(R.raw.received_message, "received_message"),
    SENT_MESSAGE(R.raw.sent_message, "sent_message"),
    SMS_RECEIVED1(R.raw.sms_received1, "sms_received1"),
    SMS_RECEIVED2(R.raw.sms_received2, "sms_received2"),
    SMS_RECEIVED3(R.raw.sms_received3, "sms_received3"),
    SMS_RECEIVED4(R.raw.sms_received4, "sms_received4"),
    SMS_RECEIVED5(R.raw.sms_received5, "sms_received5"),
    SMS_RECEIVED6(R.raw.sms_received6, "sms_received6"),
    SUSPENSE(R.raw.suspense, "suspense"),
    SYNTH(R.raw.synth, "synth"),
    TELEGRAPH(R.raw.telegraph, "telegraph"),
    TIPTOES(R.raw.tiptoes, "tiptoes"),
    TWEET_SENT(R.raw.tweet_sent, "tweet_sent"),
    TYPEWRITERS(R.raw.typewriters, "typewriters"),
}

enum class AppNotificationChannel(
    val channelId: String,
    val title: String,
    val defaultSound: Uri?,
    val importance: Int = NotificationManager.IMPORTANCE_HIGH
) {
    MAIN_FOREGROUND_CHANNEL(
        "OS_93fb1eec-863b-4234-a470-83c877043255",
        "Foreground",
        getDefaultSound(NotificationSound.CANTINA_BAND)
    ),
    SIP_CHANNEL("SipChannel", "Sip Channel", null),
    NO_SOUND(
        "OS_4f52d74b-67bc-4c44-ad58-1017a5d011ad",
        "No sound",
        null,
        NotificationManager.IMPORTANCE_LOW
    ),
    NOTIFICATION_ABOUT_ORDER(
        "OS_fb2442d7-fab3-449a-acc7-ffdaae7bfb47",
        "Notification about order",
        getDefaultSound(NotificationSound.CANTINA_BAND)
    ),
    PENALTY(
        "OS_8be82044-147c-4b58-ade6-eb643219c2ad",
        "Penalty",
        getDefaultSound(NotificationSound.CANTINA_BAND)
    ),
    NEW_ORDER(
        "OS_06191f65-6218-4b59-8f75-3534432fea94",
        "New order",
        getDefaultSound(NotificationSound.CANTINA_BAND)
    ),
    NEW_CHAT_MESSAGE(
        "OS_a99ed4d9-ddd1-4f7e-8db3-a207b8fa65e3",
        "New chat message",
        getDefaultSound(NotificationSound.CANTINA_BAND)
    ),
    FINISHED_ORDER(
        "OS_088410fe-405a-456b-bac2-d2e01baec499",
        "Finished order",
        getDefaultSound(NotificationSound.CANTINA_BAND)
    ),
    MANAGER_LOST_CALL(
        "OS_10b02c38-b5ee-46aa-a9d0-44f2de81afe9",
        "Lost call for manager",
        getDefaultSound(NotificationSound.CANTINA_BAND)
    ),
    LOST_CALL(
        "OS_65c89091-5593-4863-86d4-8a3b864246c2",
        "Lost call",
        getDefaultSound(NotificationSound.CANTINA_BAND)
    ),
}

fun getDefaultSound(sound: NotificationSound = NotificationSound.TELEGRAM): Uri {
    return Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://com.rempc.app/" + sound.value)
}

class OneSignalNotificationSound {
    fun getChannelSound(applicationContext: Context, channel: AppNotificationChannel): Uri? {
        val preferences = applicationContext.getSharedPreferences(
            "NotificationChannelSound",
            FlutterActivity.MODE_PRIVATE
        )
        val sound = preferences.getString(channel.channelId, channel.defaultSound.toString())
        return if (sound?.isNotEmpty() == true) {
            Uri.parse(sound)
        } else {
            null
        }
    }

    fun setChannelSound(
        applicationContext: Context,
        channel: AppNotificationChannel,
        sound: NotificationSound
    ) {
        val preferences = applicationContext.getSharedPreferences(
            "NotificationChannelSound",
            FlutterActivity.MODE_PRIVATE
        )
        val editor = preferences.edit()
        editor.putString(
            channel.channelId,
            Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://com.rempc.app/" + sound.value)
                .toString()
        ).apply()
    }

    fun getCurrentSound(context: Context): String {
        try {
            val sharedPref: SharedPreferences =
                context.getSharedPreferences("NotificationSound", FlutterActivity.MODE_PRIVATE)
            val currentSound: String? =
                sharedPref.getString("notification_sound", NotificationSound.values().first().title)
            if (currentSound != null) {
                Log.d("curr", currentSound)
                return NotificationSound.values().find { e -> e.title == currentSound }!!.title
            }
            return NotificationSound.values().first().title
        } catch (e: Exception) {
            return NotificationSound.values().first().title
        }
    }

    fun setNotificationSound(context: Context, sound: NotificationSound) {
        val sharedPref: SharedPreferences =
            context.getSharedPreferences("NotificationSound", FlutterActivity.MODE_PRIVATE)
        val editor = sharedPref.edit()
        editor.putString("notification_sound", sound.title)
        editor.apply()
    }

    private fun getMediaFile(sound: NotificationSound): Uri {
        return Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + "com.rempc.app" + "/" + sound.value)
    }

    fun playSound(context: Context, sound: NotificationSound?) {
        if (sound != null) {
            val mediaPlayer: MediaPlayer? = MediaPlayer.create(context, getMediaFile(sound))
            mediaPlayer?.start()
        }
    }
}