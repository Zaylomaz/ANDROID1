package com.rempc.app

import android.Manifest
import android.app.Service
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.location.LocationManager
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import android.provider.Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.util.Log
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.getSystemService
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.analytics.ktx.logEvent
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.firebase.crashlytics.ktx.crashlytics
import com.google.firebase.ktx.Firebase
import com.hiennv.flutter_callkit_incoming.Data
import com.hiennv.flutter_callkit_incoming.FlutterCallkitIncomingPlugin
import com.onesignal.OneSignal
import com.rempc.app.api.ApiClient
import com.rempc.app.callkit.*
import com.rempc.app.contacts.ContactField
import com.rempc.app.contacts.FastContactsPlugin
import com.rempc.app.eventBus.commands.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.jetbrains.annotations.Nullable


class MainActivity : FlutterActivity() {
    private var firstLaunch = true
    private var locationTrack: LocationTrack? = null;
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        disableScreenshots()
        super.configureFlutterEngine(flutterEngine)
        isActive = true
        if (proximityManager == null) {
            proximityManager = CallProximityManager(context)
        }
        OneSignal.setLogLevel(OneSignal.LOG_LEVEL.VERBOSE, OneSignal.LOG_LEVEL.NONE)
        OneSignal.initWithContext(this)
        OneSignal.provideUserConsent(true)
        OneSignal.setAppId("b5f06ebe-10f5-4b42-8c8d-4888a112d278") // production
        OneSignal.setLocationShared(false)
        OneSignal.setNotificationWillShowInForegroundHandler(
            OneSignalOnForeground(
                applicationContext
            )
        )
        OneSignal.setNotificationOpenedHandler(OneSignalNotificationOpenHandler(applicationContext))

        events =
            EventChannel(flutterEngine.dartExecutor.binaryMessenger, "rempc_incoming_events")
        events?.setStreamHandler(eventHandler)

        notifications =
            EventChannel(flutterEngine.dartExecutor.binaryMessenger, "notification_event_handler")
        notifications?.setStreamHandler(notificationEventHandler)

        chatEvents =
            EventChannel(flutterEngine.dartExecutor.binaryMessenger, "rempc_chat_events")
        chatEvents?.setStreamHandler(chatEventHandler)

        callkit =
            flutterEngine.plugins.get(FlutterCallkitIncomingPlugin::class.java) as FlutterCallkitIncomingPlugin?
        FlutterCallkitIncomingPlugin.externalBroadcastReceiver = callkitBroadcastReceiver

        var bluetooth_intentFilter_1: android.content.IntentFilter? =
            android.content.IntentFilter(BluetoothReceiver.ACTION_CONNECTION_STATE_CHANGED)
        var bluetooth_intentFilter_2: android.content.IntentFilter? =
            android.content.IntentFilter(BluetoothReceiver.ACTION_BT_HEADSET_STATE_CHANGED)
        registerReceiver(bluetoothReceiver, bluetooth_intentFilter_1)
        registerReceiver(bluetoothReceiver, bluetooth_intentFilter_2)

        val channel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "helperService")

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startHelperService" -> {
                    locationTrack = LocationTrack(context)
                    val userAuthToken = call.argument<String>("userAuthToken")
                    val intent = Intent(this, HelperService::class.java)
                    intent.putExtra("userAuthToken", userAuthToken)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success("OK")
                }

                "requestNativePermissions" -> {
                    OneSignal.promptForPushNotifications()
                    val readImagePermission =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
                            Manifest.permission.READ_MEDIA_IMAGES
                        else
                            Manifest.permission.READ_EXTERNAL_STORAGE

                    if (ContextCompat.checkSelfPermission(
                            this,
                            readImagePermission
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(
                                    Manifest.permission.READ_MEDIA_IMAGES,
                                    Manifest.permission.READ_MEDIA_VIDEO,
                                    Manifest.permission.READ_MEDIA_AUDIO,
                                ),
                                101
                            )
                        } else {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                                101
                            )
                        }

                    }

                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(
                            Manifest.permission.ACCESS_FINE_LOCATION,
                            Manifest.permission.ACCESS_COARSE_LOCATION
                        ),
                        101
                    )

                    result.success("OK")
                }

                "initWorkers" -> {
                    EventBus.getDefault().post(InitWorkersCommand())
                    result.success("OK")
                }

                "getWorkerInfo" -> {
                    EventBus.getDefault().post(GetWorkersInfoCommand())
                    result.success("OK")
                }

                "stopHelperService" -> {
                    stopService(Intent(this, HelperService::class.java))
                    result.success("OK")
                }

                "getOneSignalUserId" -> {
                    result.success(OneSignal.getDeviceState()?.userId)
                }

                "setUserAuthToken" -> {
                    val userAuthToken = call.argument<String>("userAuthToken")
                    if (userAuthToken?.isNotEmpty() == true) {
                        EventBus.getDefault().post(SetUserAuthTokenCommand(userAuthToken))
                    }
                    result.success("OK")
                }

                "setReportUniqueId" -> {
                    val uniqueId = call.argument<String>("uniqueId")
                    val name = call.argument<String>("name")
                    if (uniqueId?.isNotEmpty() == true) {
                        val crashlytics: FirebaseCrashlytics = Firebase.crashlytics
                        crashlytics.setCustomKey("userId", uniqueId)
                        val firebaseAnalytics: FirebaseAnalytics = Firebase.analytics
                        firebaseAnalytics.setUserId(uniqueId)
                        if (name?.isNotEmpty() == true) {
                            crashlytics.setCustomKey("name", name)
                            firebaseAnalytics.setUserProperty("name", name)
                        }

                        firebaseAnalytics.logEvent(FirebaseAnalytics.Event.APP_OPEN) {
                            param("app_open", "app_open")
                            param("user_id", uniqueId)
                            name?.let { param("user_name", it) }
                        }
                        result.success("success")
                    } else {
                        result.success("failed")
                    }
                }

                "loginEvent" -> {
                    val email = call.argument<String>("email")
                    val firebaseAnalytics: FirebaseAnalytics = Firebase.analytics
                    if (email?.isNotEmpty() == true) {
                        firebaseAnalytics.logEvent(FirebaseAnalytics.Event.LOGIN) {
                            param("logged", "logged")
                            param("email", email)
                        }
                    }
                    result.success("OK")
                }

                "getCurrentPhoneNumber" -> {
                    val phones = mutableListOf("")
                    try {
                        if (ActivityCompat.checkSelfPermission(
                                this,
                                Manifest.permission.READ_SMS
                            ) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(
                                this,
                                Manifest.permission.READ_PHONE_NUMBERS
                            ) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(
                                this,
                                Manifest.permission.READ_PHONE_STATE
                            ) != PackageManager.PERMISSION_GRANTED
                        ) {
                            result.success(phones)
                        } else {
                            val subscriptionManager =
                                applicationContext.getSystemService<SubscriptionManager>()
                            val subscription: List<SubscriptionInfo>? =
                                subscriptionManager?.activeSubscriptionInfoList
                            if (subscription?.isNotEmpty() == true) {
                                for (i in subscription.indices) {
                                    val info: SubscriptionInfo = subscription[i]
                                    if (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                            subscriptionManager.getPhoneNumber(info.subscriptionId)
                                                .isNotEmpty()
                                        } else {
                                            info.number?.isNotEmpty() == true
                                        }
                                    ) {
                                        phones += if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                            subscriptionManager.getPhoneNumber(info.subscriptionId)
                                        } else {
                                            info.number
                                        }

                                    }
                                }
                            }
                            result.success(phones)
                        }
                    } catch (e: Exception) {
                        FirebaseCrashlytics.getInstance().recordException(e)
                        result.success(phones)
                    }
                }

                "getCurrentGPSLocation" -> {
                    result.success(
                        mapOf(
                            "latitude" to locationTrack?.getLatitude(),
                            "longitude" to locationTrack?.getLongitude(),
                            "isFake" to locationTrack?.isFake,
                        )
                    )
                }

                "isGPSEnabled" -> {
                    val locationManager = context
                        .getSystemService(LOCATION_SERVICE) as LocationManager
                    result.success(locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER))
                }

                "isIgnoringBatteryOptimizations" -> {
                    firstLaunch = false
                    val pm: PowerManager = getSystemService(POWER_SERVICE) as PowerManager
                    val isIgnoringBatteryOptimizations =
                        pm.isIgnoringBatteryOptimizations(packageName)
                    result.success(isIgnoringBatteryOptimizations)
                }

                "requestAllowUseBattery" -> {
                    val intent = Intent()
                    val packageName = context.packageName
                    val pm = context.getSystemService(POWER_SERVICE) as PowerManager
                    if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                        intent.action = ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                        intent.data = Uri.parse("package:$packageName")
                        context.startActivity(intent)
                    }
                    result.success("OK")
                }

                "getAndroidId" -> {
                    try {
                        val mId =
                            Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                        result.success(mId)
                    } catch (e: Exception) {
                        FirebaseCrashlytics.getInstance().recordException(e)
                        result.success("-")
                    }
                }

                "runSipClient" -> {
                    val login = call.argument<String>("login")
                    val password = call.argument<String>("password")
                    val host = call.argument<String>("host")
                    var microphoneVolume = call.argument<Double>("microphone_volume")
                    if (microphoneVolume == null) {
                        microphoneVolume = 2.9
                    }
                    var speakerVolume = call.argument<Double>("speaker_volume")
                    if (speakerVolume == null) {
                        speakerVolume = 2.9
                    }
                    if (login != null && password != null && host != null) {
                        EventBus.getDefault().post(
                            RegisterSipClientCommand(
                                host,
                                login,
                                password,
                                filesDir.absolutePath,
                                microphoneVolume.toFloat(),
                                speakerVolume.toFloat()
                            )
                        )
                    }

                    result.success("OK")
                }

                "updateSipVolume" -> {
                    var microphoneVolume = call.argument<Double>("microphone_volume")
                    if (microphoneVolume == null) {
                        microphoneVolume = 4.5
                    }
                    var speakerVolume = call.argument<Double>("speaker_volume")
                    if (speakerVolume == null) {
                        speakerVolume = 1.0
                    }
                    EventBus.getDefault().post(
                        UpdateSipVolumeConfigCommand(
                            microphoneVolume.toFloat(),
                            speakerVolume.toFloat()
                        )
                    )
                }

                "stopSipClient" -> {
                    EventBus.getDefault().post(StopSipClientCommand())
                }

                "getSipCallData" -> {
                    result.success(
                        hashMapOf(
                            "remoteUrl" to SipClient.currentCall?.info?.remoteUri,
                            "callId" to SipClient.currentCall?.info?.callIdString,
                            "state" to SipClient.currentCall?.info?.state,
                        )
                    )
                }

                "getCallScreenInfo" -> {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    result.success(
                        hashMapOf(
                            "callTimeSeconds" to SipClient.currentCall?.info?.connectDuration?.sec,
                            "isMuted" to audioManager.isMicrophoneMute,
                            "isSpeaker" to audioManager.isSpeakerphoneOn
                        )
                    )
                }

                "makeCall" -> {
                    val url = call.argument<String>("url")
                    if (url?.isNotEmpty() == true) {
                        EventBus.getDefault().post(SipMakeCallCommand(url))
                    }
                    result.success("OK")
                }

                "hangupCall" -> {
                    EventBus.getDefault().post(HangupCallCommand())
                    result.success("OK")
                }

                "acceptCall" -> {
                    EventBus.getDefault().post(AcceptCallCommand("in_app"))
                    result.success("OK")
                }

                "muteCall" -> {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    audioManager.isMicrophoneMute = true
                    result.success("OK")
                }

                "unMuteCall" -> {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    audioManager.isMicrophoneMute = false
                    result.success("OK")
                }

                "speakerCallOn" -> {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    audioManager.isSpeakerphoneOn = true
                    result.success("OK")
                }

                "speakerCallOff" -> {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    audioManager.isSpeakerphoneOn = false
                    result.success("OK")
                }

                "getChannelId" -> {
                    val sharedPref: SharedPreferences = getSharedPreferences("Chat", MODE_PRIVATE)
                    val channelId: String? = sharedPref.getString("channel_id", null)
                    if (channelId == null) {
                        result.success("")
                    } else {
                        result.success(channelId)
                    }
                }

                "resetChannelId" -> {
                    val sharedPref: SharedPreferences = getSharedPreferences("Chat", MODE_PRIVATE)
                    sharedPref.edit()
                        .putString("channel_id", "")
                        .apply()
                    result.success("OK")
                }

                "setCurrentChannelId" -> {
                    val sharedPref: SharedPreferences = getSharedPreferences("Chat", MODE_PRIVATE)
                    sharedPref.edit()
                        .putInt("current_channel_id", call.argument<Int>("channelId")!!)
                        .apply()
                    result.success("OK")
                }

                "getNotificationSounds" -> {
                    val sound = OneSignalNotificationSound().getCurrentSound(context);
                    val channels =
                        AppNotificationChannel.values().filter { it.defaultSound != null }
                    result.success(
                        mapOf(
                            "selected" to sound,
                            "list" to NotificationSound.values().map { e ->
                                mapOf(
                                    "title" to e.title,
                                    "href" to ContentResolver.SCHEME_ANDROID_RESOURCE + "://com.rempc.app/" + e.value,
                                )
                            }.toList(),
                            "channels" to channels
                                .map { c ->
                                    mapOf(
                                        "id" to c.channelId,
                                        "title" to c.title,
                                        "href" to OneSignalNotificationSound().getChannelSound(
                                            context,
                                            c
                                        ).toString()
                                    )
                                }.toList()
                        )
                    )
                }

                "playNotificationSound" -> {
                    val sound = call.argument<String>("sound")
                    OneSignalNotificationSound().playSound(
                        context,
                        NotificationSound.values().find { e -> e.title == sound })
                }

                "setNotificationSound" -> {
                    val sounds = call.argument<Map<String, String>>("sounds")
                    val channels = AppNotificationChannel.values()
                        .filter { sounds?.keys?.contains(it.channelId) == true }
                    channels.forEach {
                        val sound = NotificationSound.values().find { sound ->
                            sound.title == sounds?.get(it.channelId)
                        }
                        if (sound != null) {
                            OneSignalNotificationSound().setChannelSound(
                                applicationContext,
                                it,
                                sound
                            )
                        }
                    }
                    Log.d("sounds", sounds.toString())
                    Log.d("arguments", call.arguments<String>().toString())
                    result.success("OK")
                }

                "getPackageVersion" -> {
                    try {
                        val pInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            this.packageManager.getPackageInfo(
                                packageName,
                                PackageManager.PackageInfoFlags.of(0.toLong()),
                            )
                        } else {
                            this.packageManager.getPackageInfo(packageName, 0)
                        }
                        val version = pInfo.versionName
                        Log.d("App Version Info", "version: $version")
                        result.success(version)
                    } catch (e: PackageManager.NameNotFoundException) {
                        e.printStackTrace()
                        result.error("VERSION NOT FOUND", e.toString(), e)
                    }
                }

                "playSipSound" -> {
                    EventBus.getDefault().post(PlaySipRingtoneCommand())
                    result.success(true)
                }

                "stopSipSound" -> {
                    EventBus.getDefault().post(StopSipRingtoneCommand())
                    result.success(true)
                }

                "setupSipRingtone" -> {
                    EventBus.getDefault().post(SetupSipRingtoneCommand(call.arguments as String))
                    result.success(true)
                }

                "getSipRingtones" -> {
                    val sounds = callkit?.getRingtoneSounds()
                    result.success(sounds?.map { it.asMap() })
                }

                "getCurrentSipRingtone" -> {
                    val sharedPref: SharedPreferences =
                        getSharedPreferences("helperService", MODE_PRIVATE)
                    result.success(
                        sharedPref.getString(
                            HelperService.defaultRingtonePrefsKey,
                            "ringtone_default"
                        ) as String
                    )
                }

                "showTestScreen" -> {
                    callkit?.showIncomingNotification(
                        Data(
                            hashMapOf(
                                "id" to "id_some",
                                "nameCaller" to "Test Name",
                                "appName" to "RemPC",
                                "handle" to "Kyiv",
                                "type" to 0,
                                "android" to hashMapOf(
                                    "isCustomNotification" to true,
                                    "ringtonePath" to "ringtone_default",
                                    "backgroundColor" to "#0955fa",
                                    "actionColor" to "#4CAF50",
                                ),
                            )
                        )
                    )
                }

                "testAction" -> {
                    val apps = getInstalledGpsApps(context)
                    result.success(apps)
                }

                "syncContacts" -> {
                    val query = listOf(
                        ContactField.DISPLAY_NAME,
                        ContactField.PHONE_NUMBERS,
                    )
                    val deviceId =
                        Settings.Secure.getString(this.contentResolver, Settings.Secure.ANDROID_ID)
                    FastContactsPlugin(this).fetchAllContacts(
                        this, query, deviceId,
                        getAuthToken(this)
                    )
                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }

        try {
            val apiClient = ApiClient.getInstance().create(ApiClient::class.java)
            AppExecutors.instance?.networkIO()?.execute {
                try {
                    apiClient.onColdStart(HelperService.userToken ?: "").execute()
                } catch (e: Exception) {
                    Log.d("onColdStart", e.toString())
                }
            }
        } catch (e: Exception) {
            Log.d("AppExecutors ColdStart", e.toString())
        }
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onSetUserAuthTokenCommand(event: NewLocationCommand) {
        sendEvent(
            "LOCATION_CHANGE", mapOf(
                "latitude" to event.latitude,
                "longitude" to event.longitude,
                "isFake" to event.isFake,
            )
        )
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onCloseApplicationCommand(event: CloseApplicationCommand) {
        if (isActive) {
            finishAffinity()
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onNewChatMessage(event: NewChatMessage) {
        sendChatEvent(
            "NEW_CHANNEL_MESSAGE",
            mapOf(
                "channelId" to event.channelId.toString(),
            )
        )
    }

    override fun onStart() {
        disableScreenshots()
        super.onStart()
        EventBus.getDefault().register(this)
        isActive = true
    }

    override fun onStop() {
        EventBus.getDefault().unregister(this)
        super.onStop()
        isActive = false
    }

    override fun onPause() {
        super.onPause()
        isActive = false
    }

    override fun onResume() {
        disableScreenshots()
        super.onResume()
        if (!firstLaunch) {
            val mLocationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            if (!mLocationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                finishAffinity()
            }
            sendChatEvent(
                "CHECK_NOTIFICATION", mapOf(
                    "action" to "check",
                )
            )
        }
        isActive = true
    }

    override fun onDestroy() {
        locationTrack?.stopListener()
        super.onDestroy()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>, grantResults: IntArray,
    ) {
        when (requestCode) {
            101 -> {
                if ((grantResults.isNotEmpty() &&
                            grantResults[0] == PackageManager.PERMISSION_GRANTED)
                ) {
                    Log.d("PERMISSION SUCCESS", "PERMISSION_GRANTED")
                } else {
                    Log.d("PERMISSION grantResults", grantResults.toString())
                }
                return
            }

            else -> {

                Log.d("PERMISSION other", permissions.toString())
            }
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    private fun disableScreenshots() {
        if (BuildConfig.FLAVOR != "dev") {
            try {
                window.setFlags(
                    WindowManager.LayoutParams.FLAG_SECURE,
                    WindowManager.LayoutParams.FLAG_SECURE
                )
            } finally {
            }
        }
        Log.d(
            MainActivity::class.qualifiedName,
            "disableScreenshots => ${BuildConfig.FLAVOR == "prod"}",
        )
    }

    companion object {
        var isActive: Boolean = true
        var callkit: FlutterCallkitIncomingPlugin? = null
        var callkitBroadcastReceiver: CallkitIncomingBroadcastReceiver =
            CallkitIncomingBroadcastReceiver()

        var bluetoothReceiver: BluetoothReceiver = BluetoothReceiver()

        var proximityManager: CallProximityManager? = null

        private var events: EventChannel? = null
        private var notifications: EventChannel? = null
        private var chatEvents: EventChannel? = null
        private val eventHandler = EventCallbackHandler()
        private val notificationEventHandler = EventCallbackHandler()
        private val chatEventHandler = EventCallbackHandler()
        var internetIntentFilter: IntentFilter? = null

        fun sendEvent(event: String, body: Map<String, Any>) {
            eventHandler.send(event, body)
        }

        fun sendNotificationEvent(event: String, body: Map<String, Any>) {
            notificationEventHandler.send(event, body)
        }

        fun sendChatEvent(event: String, body: Map<String, Any>) {
            chatEventHandler.send(event, body)
        }
    }

    class EventCallbackHandler : EventChannel.StreamHandler {

        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
        }

        fun send(event: String, body: Map<String, Any>) {
            val data = mapOf(
                "event" to event,
                "body" to body
            )
            Handler(Looper.getMainLooper()).post {
                eventSink?.success(data)
            }
        }

        override fun onCancel(arguments: Any?) {
            eventSink = null
        }
    }

    @Nullable
    private fun getAuthToken(context: Context): String {
        val sharedPref: SharedPreferences = context.getSharedPreferences(
            "helperService",
            Service.MODE_PRIVATE
        )
        val value = sharedPref.getString("userAuthToken", null)
        if (value != null && value != "") {
            return value
        }
        return ""
    }
}