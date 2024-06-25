package com.rempc.app.eventBus.commands

class RegisterSipClientCommand(var host: String, var user: String, var password: String, var filesDir: String, var microphoneVolume: Float, var speakerVolume: Float) {
}
