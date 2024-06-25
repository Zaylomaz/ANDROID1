package com.rempc.app.models

import com.google.gson.annotations.SerializedName

data class LocationData(
    @SerializedName("latitude") val latitude: Double?,
    @SerializedName("longitude") val longitude: Double?,
    @SerializedName("token") val token: String?,
)
