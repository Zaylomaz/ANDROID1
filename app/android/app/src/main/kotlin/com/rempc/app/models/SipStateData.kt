package com.rempc.app.models

import com.google.gson.annotations.SerializedName

data class SipStateData(
    @SerializedName("code") val code: Int?,
    @SerializedName("reason") val reason: String?,
    @SerializedName("expiration") val expiration: Long?,
    @SerializedName("token") val token: String?,
)
