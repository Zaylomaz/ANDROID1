package com.rempc.app.eventBus.commands

class NewLocationCommand(
    val latitude: Double,
    val longitude: Double,
    val isFake: Boolean,
    val provider: String?
) {}
