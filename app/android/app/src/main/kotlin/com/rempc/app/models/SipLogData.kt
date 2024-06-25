package com.rempc.app.models

import com.google.gson.annotations.SerializedName

data class SipLogData (
    @SerializedName("log") val reason: String?,
    @SerializedName("token") val token: String?,
)