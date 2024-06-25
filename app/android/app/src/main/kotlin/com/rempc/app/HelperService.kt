package com.rempc.app

import android.Manifest
import android.annotation.SuppressLint
import android.app.*
import android.content.*
import android.content.pm.PackageManager
import android.location.LocationManager
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaRecorder
import android.net.ConnectivityManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.webkit.MimeTypeMap
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.work.*
import com.google.common.util.concurrent.FutureCallback
import com.google.common.util.concurrent.Futures
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.analytics.ktx.logEvent
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.firebase.ktx.Firebase
import com.hiennv.flutter_callkit_incoming.Data
import com.rempc.app.MainActivity
import com.rempc.app.api.*
import com.rempc.app.callkit.HeadsUpNotificationService
import com.rempc.app.eventBus.commands.*
import com.rempc.app.models.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.runBlocking
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.io.File
import java.time.Duration
import java.util.*
import java.util.concurrent.TimeUnit


class HelperService : Service() {

    private val TAG = HelperService::class.qualifiedName
    private var needRecordAudio = false
    private var isRecording = false
    private var mediaRecorder: MediaRecorder? = null
    private var lastMediaFilePath = ""
    private var userAuthToken = ""
    private var apiClient = ApiClient.getInstance().create(ApiClient::class.java)

    private var statusContacts = 2
    private var statusLocation = 2
    private var statusMicrophone = 2
    private var statusCamera = 2
    private var statusCallLog = 2
    private var statusNotifications = 2
    private var statusStorage = 2

    private var lastPhoneName = ""
    private var lastPhoneUri = ""

    private lateinit var locationTrack: LocationTrack
    private var previousAudioMode: Int = AudioManager.MODE_NORMAL
    private var previousMicrophoneMute: Boolean = false
    private var previousSpeakerState: Boolean = false

    private var defaultRingtoneName = "ringtone_default"

    private lateinit var channel: MethodChannel
    private lateinit var flutterEngine: FlutterEngine

    private val DEVICE_STATE_WORKER_ID: UUID =
        UUID.fromString("d064b5af-7a3b-477e-a801-35b2b54172ec")
    private val APPS_SYNC_WORKER_ID: UUID = UUID.fromString("d32247e1-2279-45a4-ba3e-2c8c221f6bdc")
    private val CONTACTS_SYNC_WORKER_ID: UUID =
        UUID.fromString("e27d90c4-c093-45bd-b28e-6b0f4aef7cd8")
    private val CALL_LOG_SYNC_WORKER_ID: UUID =
        UUID.fromString("e64a2ae0-6f78-4c82-8805-dc9ed86ea6e7")

    inner class InternetBroadCastReceiver : BroadcastReceiver() {
        private var conn_name = ""
        override fun onReceive(context: Context, intent: Intent) {
            if (isNetworkChange(context)) {
                sipClient?.notifyChangeNetwork()
            }
        }

        private fun isNetworkChange(context: Context): Boolean {
            return true
//            var networkChanged = false
//            val connectivityManager = context.getSystemService(
//                CONNECTIVITY_SERVICE
//            ) as ConnectivityManager
//            val netInfo = connectivityManager.activeNetworkInfo
//            if (netInfo != null && netInfo.isConnectedOrConnecting &&
//                !conn_name.equals("", ignoreCase = true)
//            ) {
//                val new_con = netInfo.extraInfo
//                if (new_con != null && !new_con.equals(
//                        conn_name,
//                        ignoreCase = true
//                    )
//                ) networkChanged = true
//                conn_name = new_con ?: ""
//            } else {
//                if (conn_name.equals("", ignoreCase = true)) {
//                    netInfo?.extraInfo?.let {
//                        conn_name = it
//                    }
//                }
//            }
//            return networkChanged
        }
    }

    override fun onBind(p0: Intent?): IBinder? {
        return null
    }

//    @Subscribe(threadMode = ThreadMode.BACKGROUND)
//    fun onSipLog(event: SipLog) {
//        sipLog += event.log
//        if (sipLog.count() >= 20) {
//            try {
//                apiClient.sipLog(SipLogData(sipLog.joinToString("\n"), userAuthToken)).execute()
//                sipLog.clear()
//            } catch (e: Exception) {
//                FirebaseCrashlytics.getInstance().recordException(e)
//            }
//        }
//    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onSetUserAuthTokenCommand(event: SetUserAuthTokenCommand) {
        userAuthToken = event.userAuthToken
        userToken = event.userAuthToken
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onStartAudioRecordEvent(event: StartAudioRecordCommand) {
        needRecordAudio = true
        startAudioRecord()
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onStopAudioRecordEvent(event: StopAudioRecordCommand) {
        needRecordAudio = false
        stopMediaRecorder()
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onUpdateSipVolumeConfigCommand(event: UpdateSipVolumeConfigCommand) {
        sipClient?.updateConfig(event)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onRegisterSipClientEvent(event: RegisterSipClientCommand) {
        val sharedPref: SharedPreferences = getSharedPreferences("helperService", MODE_PRIVATE)
        sharedPref.edit()
            .putString("sipHost", event.host)
            .putString("sipUser", event.user)
            .putString("sipPassword", event.password)
            .putString("sipFilesDir", event.filesDir)
            .putFloat("sipMicrophoneVolume", event.microphoneVolume)
            .putFloat("sipSpeakerVolume", event.speakerVolume)
            .apply()

        sipClient?.init(event)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onStopSipClientEvent(event: StopSipClientCommand) {
        sipClient?.deinit()
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onUpdateSipStateCommand(event: UpdateSipStateCommand) {
        lastSipStatus = event
        updateNotification(event)
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onGetCurrentGPSLocationCommand(event: GetCurrentGPSLocationCommand) {
        sendLocation(event.latitude, event.longitude, event.isFake, event.provider)
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onNewLocationCommand(event: NewLocationCommand) {
        sendLocation(event.latitude, event.longitude, event.isFake, event.provider)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onStopSipCommand(event: StopSipCommand) {
        EventBus.getDefault().post(StopSipClientCommand())
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onStartSipCommand(event: StartSipCommand) {
        val sharedPref: SharedPreferences = getSharedPreferences("helperService", MODE_PRIVATE)

        val host = sharedPref.getString("sipHost", null)
        val user = sharedPref.getString("sipUser", null)
        val password = sharedPref.getString("sipPassword", null)
        val filesDir = sharedPref.getString("sipFilesDir", null)
        val microphoneVolume = sharedPref.getFloat("sipMicrophoneVolume", 4.5f)
        val speakerVolume = sharedPref.getFloat("sipSpeakerVolume", 1f)
        if (host != null && user != null && password != null && filesDir != null) {
            onRegisterSipClientEvent(
                RegisterSipClientCommand(
                    host,
                    user,
                    password,
                    filesDir,
                    microphoneVolume,
                    speakerVolume
                )
            )
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onSipMakeCallEvent(event: SipMakeCallCommand) {
        if (needRecordAudio) {
            stopMediaRecorder()
        }
        try {
            apiClient.phoneInfo(
                event.url,
                event.url,
                event.url,
                "1",
                userAuthToken,
            ).execute()
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
        EventBus.getDefault().post(CallLocationLog(event.url, "1"))
        sipClient?.makeCall(event.url)
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onWorkersInfoCommand(event: GetWorkersInfoCommand) {
        runBlocking { getWorkInfo() }
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onEndCallEvent(event: EndCallCommand) {
        EventBus.getDefault().post(SetAudioFocus(false))
        if (needRecordAudio) {
            startAudioRecord()
        }

        stopService(Intent(this, HeadsUpNotificationService::class.java))
        MainActivity.proximityManager?.stop()
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onCallLocationLog(event: CallLocationLog) {
        Log.d(TAG, "CallLocationLog ${event.callId} / ${event.callType}")
        Log.d(TAG, "CallLocationLog location ${locationTrack.canGetGPSLocation()}")
        try {
            if (locationTrack.canGetGPSLocation()) {
                val location = if (locationTrack.lastKnownGPSLocation != null) {
                    locationTrack.lastKnownGPSLocation
                } else {
                    locationTrack.lastKnownNetworkLocation
                }
                val isFake = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    location?.isMock
                } else {
                    location?.isFromMockProvider
                }
                Log.d(
                    TAG,
                    "CallLocationLog sendCallLocation ${location?.latitude} ${location?.longitude}"
                )
                apiClient.sendCallLocation(
                    userAuthToken,
                    event.callId,
                    event.callType,
                    location?.latitude.toString(),
                    location?.longitude.toString(),
                    if (isFake == true) 1 else 0,
                ).execute()
            }
        } catch (e: Exception) {
            Log.d(TAG, "CallLocationLog $e")
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onIncomingCallEvent(event: IncomingCallCommand) {
        if (needRecordAudio) {
            stopMediaRecorder()
        }
        try {
            apiClient.incomingCall(
                "incoming",
                event.remoteUrl.toString(),
                event.callId.toString(),
                userAuthToken
            ).execute()
            lastPhoneUri = event.remoteUrl.toString()
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }

        try {
            var name = "Неопределен";

            var city = "-";
            if (event.remoteUrl != null) {
                var phone: String = event.remoteUrl.toString()
                if (phone.contains("<")) {
                    phone = phone.substring(phone.indexOf('<') + 1)
                    phone = phone.substring(0, phone.indexOf('>'))
                }
                phone = phone.replace("sip:38", "")
                phone = phone.replace("sip:", "")
                phone = phone.substring(0, phone.indexOf('@'))
                try {
                    if (phone.length < 8) {
                        try {
                            val intTryPhone = Integer.getInteger(phone)
                            if (intTryPhone != null) {
                                if (intTryPhone < 900 || intTryPhone > 5000) {
                                    return
                                }
                            }
                        } catch (e: Exception) {
                            FirebaseCrashlytics.getInstance().recordException(e)
                        }
                    }
                } catch (e: Exception) {
                    FirebaseCrashlytics.getInstance().recordException(e)
                }
                val response = apiClient.phoneInfo(
                    phone,
                    event.remoteUrl.toString(),
                    event.callId.toString(),
                    "0",
                    userAuthToken,
                ).execute()
                EventBus.getDefault().post(CallLocationLog(event.callId.toString(), "0"))
                val names = response.body()?.getNames()
                if (!names.isNullOrEmpty()) {
                    name = names[0].toString()
                    lastPhoneName = name
                }
                val cities = response.body()?.getCities()
                if (!cities.isNullOrEmpty()) {
                    city = cities[0].toString()
                }
            }

            val callInfo: HashMap<String, Any?> = hashMapOf(
                "id" to event.callId.toString(),
                "nameCaller" to name,
                "appName" to "RemPC",
                "handle" to city,
                "type" to 0,
                "android" to hashMapOf(
                    "isCustomNotification" to true,
                    "ringtonePath" to defaultRingtoneName,
                    "backgroundColor" to "#0955fa",
                    "actionColor" to "#4CAF50",
                ),
            )
            val callData = Data(callInfo)
            MainActivity.callkit?.showIncomingNotification(callData)

            MainActivity.sendEvent(
                "INCOMING_CALL",
                mapOf(
                    "callId" to event.callId.toString(),
                    "remoteUrl" to event.remoteUrl.toString()
                )
            )
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onAcceptedCallEvent(event: AcceptedCallEvent) {
        try {
            AppExecutors.instance?.networkIO()?.execute {
                try {
                    apiClient.incomingCall(
                        "accepted_" + event.type,
                        lastPhoneUri,
                        SipClient.currentCall?.callId.toString(),
                        userAuthToken
                    ).execute()
                } catch (e: Exception) {
                    FirebaseCrashlytics.getInstance().recordException(e)
                }
            }
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onActiveCallNotificationCommand(event: ActiveCallNotificationCommand) {
        try {
            val intent = Intent(this, HeadsUpNotificationService::class.java)
            intent.putExtra("caller_name", lastPhoneName)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            MainActivity.proximityManager?.start()
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onInitWorkersCommand(event: InitWorkersCommand) {
        runBlocking { initWorkers() }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onPlaySipRingtoneCommand(event: PlaySipRingtoneCommand) {
        playSipRingtone()
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onStopSipRingtoneCommand(event: StopSipRingtoneCommand) {
        stopSipRingtone()
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onSetupSipRingtoneCommand(event: SetupSipRingtoneCommand) {
        setSipRingtone(event.id)
    }

    @Subscribe(threadMode = ThreadMode.BACKGROUND)
    fun onSetAudioFocus(event: SetAudioFocus) {
        setAudioFocus(event.focus)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onBluetoothHeadsetState(event: BluetoothHeadsetState) {

    }

    private fun setAudioFocus(focus: Boolean) {
        val audioManager: AudioManager =
            getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (focus) {
            previousAudioMode = audioManager.mode
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    audioManager.requestAudioFocus(
                        AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                            .setAudioAttributes(
                                AudioAttributes.Builder()
                                    .setUsage(AudioAttributes.USAGE_MEDIA)
                                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                                    .build()
                            )
                            .setAcceptsDelayedFocusGain(true)
                            .setOnAudioFocusChangeListener {
                                //Handle Focus Change
                            }.build()
                    )
                } else {
                    audioManager.requestAudioFocus(
                        { },
                        AudioManager.STREAM_VOICE_CALL,
                        AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
                    )
                }
            } catch (e: Exception) {
                FirebaseCrashlytics.getInstance().recordException(e)
            }
            audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
            previousMicrophoneMute = audioManager.isMicrophoneMute
            previousSpeakerState = audioManager.isSpeakerphoneOn
            audioManager.isMicrophoneMute = false
            audioManager.isSpeakerphoneOn = false
        } else {
            audioManager.mode = AudioManager.MODE_NORMAL
            try {
                audioManager.abandonAudioFocus(null)
            } catch (e: Exception) {
                FirebaseCrashlytics.getInstance().recordException(e)
            }
            audioManager.isMicrophoneMute = previousMicrophoneMute
            audioManager.isSpeakerphoneOn = previousSpeakerState
        }
    }

    override fun onCreate() {
        super.onCreate()
        val context: Context = this
        EventBus.getDefault().register(context)
//        connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
//        val networkRequest = NetworkRequest.Builder().build()
//        connectivityManager!!.registerNetworkCallback(networkRequest, networkCallback)
        locationTrack = LocationTrack(this@HelperService)
        getCurrentRingtoneName()

        lastMediaFilePath = this.cacheDir.absolutePath + "/recording.mp3"

        mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            MediaRecorder(context)
        } else {
            MediaRecorder()
        }

        mediaRecorder?.setOnErrorListener { _, _, _ ->
            Log.d("LISTENER ERROR", "setOnErrorListener")
            if (isRecording) {
                isRecording = false
                startAudioRecord()
            }
        }
    }

    private fun getCurrentRingtoneName() {
        val sharedPref: SharedPreferences = getSharedPreferences("helperService", MODE_PRIVATE)
        defaultRingtoneName =
            sharedPref.getString(defaultRingtonePrefsKey, "ringtone_default") as String
    }

    private fun setSipRingtone(ringtone: String) {
        stopSipRingtone()
        val sharedPref: SharedPreferences = getSharedPreferences("helperService", MODE_PRIVATE)
        val editor = sharedPref.edit()
        editor.putString(defaultRingtonePrefsKey, ringtone)
        editor.apply()
        getCurrentRingtoneName()
    }

    private fun playSipRingtone() {
        stopSipRingtone()
        val sounds = MainActivity.callkit?.getRingtoneSounds()
        if (sounds != null) {
            val sound = sounds.find { it.file == defaultRingtoneName }
            Log.d("defaultRingtoneName", defaultRingtoneName)
            Log.d("sound", sound?.name.toString())
            MainActivity.callkit?.playSound(this@HelperService, sound)
        }
    }

    private fun stopSipRingtone() {
        try {
            MainActivity.callkit?.stopSound(this@HelperService)
        } catch (_: Exception) {
        }
    }

    private fun initCallLogWorker(context: Context) {
        try {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()
            val callLogWorkRequest = PeriodicWorkRequestBuilder<CallLogWorker>(
                15,
                TimeUnit.MINUTES,
                15, TimeUnit.MINUTES,
            ).setConstraints(constraints).setInitialDelay(20, TimeUnit.SECONDS)
                .setId(CALL_LOG_SYNC_WORKER_ID).build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                "periodicCallLogWorker15",
                ExistingPeriodicWorkPolicy.UPDATE,
                callLogWorkRequest,
            )
        } catch (e: Exception) {
            Log.d("GET CALL LOG ERROR", e.toString())
        }
    }

    private fun initDeviceStateWorker(context: Context) {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()
        val periodicDeviceStateRequest = PeriodicWorkRequestBuilder<DeviceStateWorker>(
            15,
            TimeUnit.MINUTES,
            15, TimeUnit.MINUTES,
        ).setConstraints(constraints).setInitialDelay(5, TimeUnit.SECONDS)
            .setId(DEVICE_STATE_WORKER_ID).build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            "periodicDeviceStateWorker",
            ExistingPeriodicWorkPolicy.UPDATE,
            periodicDeviceStateRequest,
        )
    }

    private fun initContactsWorker(context: Context) {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()
        val periodicContactsRequest = PeriodicWorkRequestBuilder<ContactsSyncWorker>(
            15,
            TimeUnit.MINUTES,
            15, TimeUnit.MINUTES,
        ).setConstraints(constraints).setInitialDelay(10, TimeUnit.SECONDS)
            .setId(CONTACTS_SYNC_WORKER_ID).build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            "periodicContactsWorker15",
            ExistingPeriodicWorkPolicy.UPDATE,
            periodicContactsRequest,
        )
    }

    private fun initAppsWorker(context: Context) {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()
        val periodicAppsRequest = PeriodicWorkRequestBuilder<AppsSyncWorker>(
            15,
            TimeUnit.MINUTES,
            15, TimeUnit.MINUTES,
        ).setConstraints(constraints).setInitialDelay(15, TimeUnit.SECONDS)
            .setId(APPS_SYNC_WORKER_ID).build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            "periodicAppsWorker15",
            ExistingPeriodicWorkPolicy.UPDATE,
            periodicAppsRequest,
        )
    }

    @SuppressLint("RestrictedApi")
    private suspend fun initWorkers() {
        try {
            apiClient.logEvent(
                userAuthToken,
                LoggerBody("initWorkers", mapOf("startService" to true))
            ).execute()
            WorkManager.getInstance(this@HelperService).pruneWork()

            val deviceWorkInfo =
                WorkManager.getInstance(this@HelperService)
                    .getWorkInfoById(DEVICE_STATE_WORKER_ID).await()
            val contactsWorkInfo =
                WorkManager.getInstance(this@HelperService)
                    .getWorkInfoById(CONTACTS_SYNC_WORKER_ID).await()
            val appsWorkInfo =
                WorkManager.getInstance(this@HelperService).getWorkInfoById(APPS_SYNC_WORKER_ID)
                    .await()
            if (deviceWorkInfo == null || deviceWorkInfo.state.isFinished) {
                Log.d("initWorkers", "initDeviceStateWorker")
                initDeviceStateWorker(this@HelperService)
            }
            if (contactsWorkInfo == null || contactsWorkInfo.state.isFinished) {
                Log.d("initWorkers", "initContactsWorker")
                initContactsWorker(this@HelperService)
            }
            if (appsWorkInfo == null || appsWorkInfo.state.isFinished) {
                Log.d("initWorkers", "initAppsWorker")
                initAppsWorker(this@HelperService)
            }
            val flavor = BuildConfig.FLAVOR;
            if (flavor == "prodapk") {
                val callSyncWorkInfo = WorkManager.getInstance(this@HelperService)
                    .getWorkInfoById(CALL_LOG_SYNC_WORKER_ID)
                if (callSyncWorkInfo.await().state != WorkInfo.State.ENQUEUED) {
                    Log.d("initWorkers", "initCallLogWorker")
                    initCallLogWorker(this@HelperService)
                }
            }
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
            apiClient.logEvent(
                userAuthToken,
                LoggerBody("initWorkersError", mapOf("error" to e.toString()))
            ).execute()
        }
    }

    @SuppressLint("RestrictedApi")
    private suspend fun getWorkInfo() {
        apiClient.logEvent(userAuthToken, LoggerBody("testLogs", mapOf("test" to true))).execute()
        val deviceWorkInfo =
            WorkManager.getInstance(this@HelperService).getWorkInfoById(DEVICE_STATE_WORKER_ID)
                .await()
        val contactsWorkInfo =
            WorkManager.getInstance(this@HelperService).getWorkInfoById(CONTACTS_SYNC_WORKER_ID)
                .await()
        val appsWorkInfo =
            WorkManager.getInstance(this@HelperService).getWorkInfoById(APPS_SYNC_WORKER_ID).await()
        val data = mapOf(
            "deviceWorkInfo" to mapOf(
                "state" to deviceWorkInfo?.state.toString(),
                "runAttemptCount" to deviceWorkInfo?.runAttemptCount.toString()
            ),
            "contactsWorkInfo" to mapOf(
                "state" to contactsWorkInfo?.state.toString(),
                "runAttemptCount" to contactsWorkInfo?.runAttemptCount.toString()
            ),
            "appsWorkInfo" to mapOf(
                "state" to appsWorkInfo?.state.toString(),
                "runAttemptCount" to appsWorkInfo?.runAttemptCount.toString()
            ),
        )
        Log.d("WORKER LOGS", data.toString())
        apiClient.logEvent(userAuthToken, LoggerBody("workersInfo", data)).execute()
    }

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (sipClient == null) {
            sipClient = SipClient(this) //Context passing
        }

        if (internetBroadcastReceiver == null) {
            internetBroadcastReceiver = InternetBroadCastReceiver()
            MainActivity.internetIntentFilter = IntentFilter(
                ConnectivityManager.CONNECTIVITY_ACTION
            )
            registerReceiver(internetBroadcastReceiver, MainActivity.internetIntentFilter)
        }

        try {
            Firebase.analytics.logEvent("service_started") {
                param("service_started", "service_started")
            }
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }

        val sharedPref: SharedPreferences = getSharedPreferences("helperService", MODE_PRIVATE)

        val i = Intent(this, MainActivity::class.java)
        i.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        val pi = PendingIntent.getActivity(this, 4242, i, PendingIntent.FLAG_IMMUTABLE)
        userAuthToken = (intent?.extras?.getString("userAuthToken") ?: userAuthToken)
        userToken = userAuthToken

        if (userAuthToken == "") {
            val value = sharedPref.getString("userAuthToken", null)
            if (value != null && value != "") {
                userAuthToken = value
                userToken = userAuthToken
            }
            // try to register sip client:
            EventBus.getDefault().post(StartSipCommand())
        } else {
            sharedPref.edit()
                .putString("userAuthToken", userAuthToken)
                .apply()
        }

        val notificationBuilder =
            NotificationCompat.Builder(this, AppNotificationChannel.NO_SOUND.channelId)
                .setChannelId(AppNotificationChannel.NO_SOUND.channelId)
                .setSmallIcon(R.drawable.logo)
                .setContentIntent(pi)
                .setShowWhen(false)
                .setContentText("Running")
                .setContentTitle("RemPC - Service")

        startForeground(2342, notificationBuilder.build())

        lastSipStatus?.let { updateNotification(it) }

        val runnable = Runnable {
            while (userAuthToken == "") {
                Thread.sleep(5_000)
            }
            while (true) {
                try {
                    var checkStatus = checkSelfPermission(Manifest.permission.READ_CONTACTS)
                    if (checkStatus != statusContacts) {
                        if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                            apiClient.permissionResult(
                                PermissionAccessType.contacts,
                                PermissionAccessValue.allow,
                                TokenData(userAuthToken),
                            ).execute()
                        } else {
                            apiClient.permissionResult(
                                PermissionAccessType.contacts,
                                PermissionAccessValue.deny,
                                TokenData(userAuthToken),
                            ).execute()
                        }
                        statusContacts = checkStatus
                    }

                    checkStatus = checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                    if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                        val mLocationManager =
                            getSystemService(Context.LOCATION_SERVICE) as LocationManager
                        if (!mLocationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                            checkStatus = PackageManager.PERMISSION_DENIED
                        }
                    }
                    if (checkStatus != statusLocation) {
                        if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                            apiClient.permissionResult(
                                PermissionAccessType.location,
                                PermissionAccessValue.allow,
                                TokenData(userAuthToken),
                            ).execute()
                        } else {
                            apiClient.permissionResult(
                                PermissionAccessType.location,
                                PermissionAccessValue.deny,
                                TokenData(userAuthToken),
                            ).execute()
                        }
                        statusLocation = checkStatus
                    }

                    checkStatus = checkSelfPermission(Manifest.permission.RECORD_AUDIO)
                    if (checkStatus != statusMicrophone) {
                        if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                            apiClient.permissionResult(
                                PermissionAccessType.microphone,
                                PermissionAccessValue.allow,
                                TokenData(userAuthToken),
                            ).execute()
                        } else {
                            apiClient.permissionResult(
                                PermissionAccessType.microphone,
                                PermissionAccessValue.deny,
                                TokenData(userAuthToken),
                            ).execute()
                        }
                        statusMicrophone = checkStatus
                    }

                    checkStatus = checkSelfPermission(Manifest.permission.CAMERA)
                    if (checkStatus != statusCamera) {
                        if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                            apiClient.permissionResult(
                                PermissionAccessType.camera,
                                PermissionAccessValue.allow,
                                TokenData(userAuthToken),
                            ).execute()
                        } else {
                            apiClient.permissionResult(
                                PermissionAccessType.camera,
                                PermissionAccessValue.deny,
                                TokenData(userAuthToken),
                            ).execute()
                        }
                        statusCamera = checkStatus
                    }
                    checkStatus = checkSelfPermission(Manifest.permission.READ_CALL_LOG)
                    if (checkStatus != statusCallLog) {
                        if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                            apiClient.permissionResult(
                                PermissionAccessType.call_history,
                                PermissionAccessValue.allow,
                                TokenData(userAuthToken),
                            ).execute()
                        } else {
                            apiClient.permissionResult(
                                PermissionAccessType.call_history,
                                PermissionAccessValue.deny,
                                TokenData(userAuthToken),
                            ).execute()
                        }
                        statusCallLog = checkStatus
                    }
                    checkStatus = checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)
                    if (checkStatus != statusNotifications) {
                        if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                            apiClient.permissionResult(
                                PermissionAccessType.notification,
                                PermissionAccessValue.allow,
                                TokenData(userAuthToken),
                            ).execute()
                        } else {
                            apiClient.permissionResult(
                                PermissionAccessType.notification,
                                PermissionAccessValue.deny,
                                TokenData(userAuthToken),
                            ).execute()
                        }
                        statusNotifications = checkStatus
                    }
                    checkStatus = checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                    if (checkStatus != statusStorage) {
                        if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                            apiClient.permissionResult(
                                PermissionAccessType.storage,
                                PermissionAccessValue.allow,
                                TokenData(userAuthToken),
                            ).execute()
                        } else {
                            apiClient.permissionResult(
                                PermissionAccessType.storage,
                                PermissionAccessValue.deny,
                                TokenData(userAuthToken),
                            ).execute()
                        }
                        statusStorage = checkStatus
                    }

                } catch (e: Exception) {
                    FirebaseCrashlytics.getInstance().recordException(e)
                }

                Thread.sleep(180_000)

                ///TODO UPDATE LOCATION
//                if (locationForTry != null) {
//                    try {
//                        AppExecutors.instance?.networkIO()?.execute {
//                            try {
//                                var isFake: Boolean?
//                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//                                    isFake = locationForTry?.isMock ?: false
//                                    Log.d(
//                                        "LOCATION_PROPERTY > 31",
//                                        isFake.toString()
//                                    )
//                                } else {
//                                    isFake = locationForTry?.isFromMockProvider
//                                    Log.d(
//                                        "LOCATION_PROPERTY < 31",
//                                        locationForTry?.isFromMockProvider.toString()
//                                    )
//                                }
//                                apiClient.updateLocation(
//                                    locationForTry!!.latitude,
//                                    locationForTry!!.longitude,
//                                    userAuthToken,
//                                    isFake,
//                                ).execute()
//                            } catch (e: Exception) {
//                                //
//                            }
//                        }
//                        locationForTry = null
//                    } catch (e: Exception) {
//                        FirebaseCrashlytics.getInstance().recordException(e)
//                    }
//                }
            }
        }

        val t = Thread(runnable)
        t.start()

        scheduleStart(applicationContext, Duration.ofMinutes(2).toMillis())

        return START_STICKY
    }

    private fun updateNotification(event: UpdateSipStateCommand) {
        try {
            val i = Intent(this, MainActivity::class.java)
            i.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            val pi = PendingIntent.getActivity(this, 4242, i, PendingIntent.FLAG_IMMUTABLE)

            val notificationBuilder =
                NotificationCompat.Builder(this, AppNotificationChannel.NO_SOUND.channelId)
                    .setChannelId(AppNotificationChannel.NO_SOUND.channelId)
                    .setContentIntent(pi)
                    .setShowWhen(false)
                    .setContentTitle("RemPC - Service")
            when (event.code) {
                200 -> {
                    notificationBuilder.setSmallIcon(R.drawable.active)
                        .setContentText("SIP активен")
                }

                -1 -> {
                    notificationBuilder.setSmallIcon(R.drawable.suspended)
                        .setContentText("SIP приостановлен")
                }

                else -> {
                    notificationBuilder.setSmallIcon(R.drawable.inactive)
                        .setContentText("SIP неактивен - " + event.reason)
                }
            }
            val mNotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            mNotificationManager.notify(2342, notificationBuilder.build())
        } catch (e: Exception) {
            e.addSuppressed(Throwable(event.code.toString()))
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    private fun startAudioRecord() {
        Log.d("RECORD START", "START AUDIO RECORD")
        Log.d("RECORD val isRecording", isRecording.toString())
        if (isRecording) {
            return
        }
        if (SipClient.currentCall != null) {
            return
        }

        val runnable = Runnable {
            android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_URGENT_AUDIO)

            startMediaRecorder()

            while (true) {
                Thread.sleep(60_000)
                if (!isRecording) {
                    break
                }
                stopMediaRecorder()
                startMediaRecorder()
            }
        }

        val t = Thread(runnable)
        t.start()
    }

    private fun startMediaRecorder() {
        Log.d("RECORD START", "startMediaRecorder")
        if (isRecording) return
        try {
            mediaRecorder?.setAudioSource(MediaRecorder.AudioSource.MIC)
            mediaRecorder?.setOutputFormat(MediaRecorder.OutputFormat.AAC_ADTS)
            mediaRecorder?.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            Thread.currentThread().name = "Recorder:" + javaClass.simpleName

            mediaRecorder?.setOutputFile(lastMediaFilePath)
            mediaRecorder?.prepare()
            mediaRecorder?.start()
            isRecording = true
            Log.d("mediaRecorder state", (mediaRecorder == null).toString())
        } catch (e: Exception) {
            Log.d("RECORD START", "ERROR")
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    private fun stopMediaRecorder() {
        Log.d("RECORD STOP", "stopMediaRecorder")
        if (!isRecording) return
        try {
            mediaRecorder?.stop()
            sendRecordAudio()
            isRecording = false
        } catch (e: Exception) {
            Log.d("RECORD STOP", "ERROR")
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    private fun sendRecordAudio() {
        if (userAuthToken.isEmpty()) {
            Log.i(TAG, "User Auth Token is empty. Can't upload a media file")
            return
        }
        val mediaFile = File(lastMediaFilePath)
        val mimeType = getMimeType(mediaFile)

        val requestBody: MultipartBody =
            MultipartBody.Builder().setType(MultipartBody.FORM)
                .addFormDataPart(
                    "audio_file",
                    "audio.mp3",
                    mediaFile.asRequestBody(mimeType?.toMediaTypeOrNull())
                )
                .addFormDataPart("token", userAuthToken)
                .build()

        try {
            apiClient.voiceRecordStore(requestBody).execute()
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    private fun getMimeType(file: File): String? {
        var type: String? = null
        val extension = MimeTypeMap.getFileExtensionFromUrl(file.path)
        if (extension != null) {
            type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
        }
        return type
    }

    private fun sendLocation(
        latitude: Double,
        longitude: Double,
        isFake: Boolean,
        provider: String?
    ) {
        try {
            AppExecutors.instance?.networkIO()?.execute {
                try {
                    apiClient.updateLocation(
                        userAuthToken,
                        latitude,
                        longitude,
                        if (isFake) 1 else 0,
                        provider,
                    ).execute()
                } catch (e: Exception) {
                    FirebaseCrashlytics.getInstance().recordException(e)
                }
            }
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        locationTrack.stopListener()
        unregisterReceiver(internetBroadcastReceiver)
        EventBus.getDefault().unregister(this)
        Log.i(TAG, "Service onDestroy()")
        try {
            AppExecutors.instance?.networkIO()?.execute {
                try {
                    apiClient.serviceStopped(
                        userAuthToken
                    ).execute()
                } catch (e: Exception) {
                    FirebaseCrashlytics.getInstance().recordException(e)
                }
            }
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    companion object {
        const val defaultRingtonePrefsKey = "default_ringtone_name"
        var connectivityManager: ConnectivityManager? = null
        var sipClient: SipClient? = null
        var userToken: String? = null
        var isFirstLaunch: Boolean = true
        var internetBroadcastReceiver: InternetBroadCastReceiver? = null
        var lastSipStatus: UpdateSipStateCommand? = null
        val sipLog = mutableListOf("")

        @SuppressLint("ScheduleExactAlarm")
        fun scheduleStart(context: Context, duration: Long) {
            val time = System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(duration)
            Log.i(HelperService::class.qualifiedName, "Scheduling start ${Date(time)}")
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                am.setExactAndAllowWhileIdle(
                    AlarmManager.RTC,
                    time,
                    PendingIntent.getForegroundService(
                        context,
                        0,
                        Intent(context, HelperService::class.java),
                        PendingIntent.FLAG_IMMUTABLE
                    )
                )
            }
        }
    }
}

