package com.rempc.app.models

import com.google.gson.annotations.SerializedName

data class TokenData(
    @SerializedName("token") val token: String?,
)

data class ContactsBody(
    @SerializedName("contacts") val contacts: String,
    @SerializedName("device_id") val deviceId: String?,
    @SerializedName("from_scheduler") val from_scheduler: String,
)

data class AppsBody(
    @SerializedName("apps") val apps: String,
)

data class CallLogBody(
    @SerializedName("calls") val calls: String,
)

data class LoggerBody(
    @SerializedName("action") val action: String,
    @SerializedName("data") val data: Map<String, *>
)