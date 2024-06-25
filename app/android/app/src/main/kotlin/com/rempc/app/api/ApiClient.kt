package com.rempc.app.api

import android.util.Log
import com.rempc.app.BuildConfig
import com.rempc.app.models.*
import com.rempc.app.api.ProxyInterceptor
import okhttp3.Dns
import okhttp3.MultipartBody
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.*
import java.net.HttpURLConnection
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.InetAddress
import java.net.SocketException
import java.net.URL
import java.net.UnknownHostException
import java.util.logging.Logger


interface ApiClient {
    @POST("api/sip/log")
    fun sipLog(@Body sipLog: SipLogData): Call<Void>

    @GET("api/locations/store")
    fun updateLocation(
        @Query("token") token: String,
        @Query("latitude") latitude: Double,
        @Query("longitude") longitude: Double,
        @Query("isFake") isFake: Int?,
        @Query("provider") provider: String?,
    ): Call<Void>

    @GET("api/cold_start_log")
    fun onColdStart(
        @Query("token") token: String
    ): Call<Void>

    @GET("api/call/log")
    fun incomingCall(
        @Query("action") action: String,
        @Query("originalPhone") originalPhone: String,
        @Query("callId") callId: String,
        @Query("token") token: String
    ): Call<Void>

    @GET("api/service/stopped")
    fun serviceStopped(
        @Query("token") token: String
    ): Call<Void>

    @GET("api/call/info")
    fun phoneInfo(
        @Query("phone") phone: String,
        @Query("originalPhone") originalPhone: String,
        @Query("callId") callId: String,
        @Query("callType") callType: String,
        @Query("token") token: String,
    ): Call<PhoneInfo>

    @GET("api/call/location")
    fun sendCallLocation(
        @Query("token") token: String,
        @Query("callId") callId: String,
        @Query("callType") callType: String,
        @Query("latitude") latitude: String?,
        @Query("longitude") longitude: String?,
        @Query("isFake") isFake: Int?,
    ): Call<Void>

    @POST("api/voice-record/store")
    fun voiceRecordStore(
        @Body body: MultipartBody
    ): Call<Void>

    @POST("api/access/{type}/{value}")
    fun permissionResult(
        @Path("type") type: PermissionAccessType,
        @Path("value") value: PermissionAccessValue,
        @Body tokenData: TokenData
    ): Call<Void>

    @GET("api/user/device-state")
    fun updateDeviceState(
        @Query("token") token: String,
        @Query("battery") battery: String,
        @Query("cell_signal") cellSignal: String,
    ): Call<Void>

    @POST("api/contacts/store")
    fun contactsSync(
        @Query("token") token: String,
        @Query("device_id") deviceId: String?,
        @Body contactsBody: ContactsBody,
    ): Call<Void>

    @POST("api/user-applications")
    fun appsSync(
        @Query("token") token: String,
        @Query("device_id") deviceId: String?,
        @Query("rawdata") rawdata: Boolean,
        @Body apps: AppsBody,
    ): Call<Void>

    @POST("api/user-call-log")
    fun callsSync(
        @Query("token") token: String,
        @Query("device_id") deviceId: String?,
        @Body calls: CallLogBody,
    ): Call<Void>

    @POST("api/logger/log_event")
    fun logEvent(
        @Query("token") token: String,
        @Body data: LoggerBody,
    ): Call<Void>

    companion object {

        private var retrofit: Retrofit? = null
        private val logging = HttpLoggingInterceptor().apply {
            this.level = HttpLoggingInterceptor.Level.HEADERS
        }
        private val proxyInterceptor = ProxyInterceptor()

        fun getInstance(): Retrofit {
            if (retrofit == null) {
                retrofit = Retrofit.Builder()
                    .baseUrl(BuildConfig.API_URL)
                    .client(
                        UnsafeOkHttpClient.unsafeOkHttpClient
                            .addInterceptor(logging)
                            .dns(CorePlaneOkHttpDNSSelector(CorePlaneOkHttpDNSSelector.IPvMode.IPV4_ONLY))
//                            .addInterceptor(proxyInterceptor)
                            .build()
                    )
                    .addConverterFactory(GsonConverterFactory.create())
                    .build()
            }
            return retrofit!!
        }
    }
}

class CorePlaneOkHttpDNSSelector(private val mode: IPvMode) : Dns {

    enum class IPvMode(val code: String) {
        SYSTEM("system"),
        IPV6_FIRST("ipv6"),
        IPV4_FIRST("ipv4"),
        IPV6_ONLY("ipv6only"),
        IPV4_ONLY("ipv4only");

        companion object {
            @JvmStatic
            fun fromString(ipMode: String): IPvMode =
                IPvMode.values().find { it.code == ipMode }
                    ?: throw Exception("Unknown value $ipMode")
        }
    }

    override fun lookup(hostname: String): List<InetAddress> {
        var addresses = Dns.SYSTEM.lookup(hostname)

        addresses = when (mode) {
            IPvMode.IPV6_FIRST -> addresses.sortedBy { Inet6Address::class.java.isInstance(it) }
            IPvMode.IPV4_FIRST -> addresses.sortedBy { Inet4Address::class.java.isInstance(it) }
            IPvMode.IPV6_ONLY -> addresses.filter { Inet6Address::class.java.isInstance(it) }
            IPvMode.IPV4_ONLY -> addresses.filter { Inet4Address::class.java.isInstance(it) }
            IPvMode.SYSTEM -> addresses
        }

        return addresses
    }

    companion object {
        private val logger = Logger.getLogger(CorePlaneOkHttpDNSSelector::class.java.name)
    }
}

enum class PermissionAccessType {
    contacts,
    location,
    microphone,
    camera,
    call_history,
    notification,
    storage,
}

enum class PermissionAccessValue {
    allow, deny,
}