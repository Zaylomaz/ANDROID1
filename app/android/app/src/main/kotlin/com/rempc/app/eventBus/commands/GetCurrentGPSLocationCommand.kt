package com.rempc.app.eventBus.commands

class GetCurrentGPSLocationCommand(
    val latitude: Double,
    val longitude: Double,
    val isFake: Boolean,
    val provider: String
) {}