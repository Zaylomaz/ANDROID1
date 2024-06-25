package com.rempc.app.callkit

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.PowerManager
import androidx.annotation.RequiresApi
import javax.inject.Inject

@RequiresApi(Build.VERSION_CODES.M)
class CallProximityManager @Inject constructor(
    context: Context
) : SensorEventListener {

    companion object {
        private const val PROXIMITY_WAKE_LOCK_TAG = "PROXIMITY_WAKE_LOCK_TAG"

        // 1 hour
        private const val WAKE_LOCK_TIMEOUT_MILLIS = 3_600_000L
    }

    private val powerManager = context.getSystemService(PowerManager::class.java)
    private val sensorManager = context.getSystemService(SensorManager::class.java)

    private var wakeLock: PowerManager.WakeLock? = null
    private val sensor: Sensor? = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY)

    private val isSupported = sensor != null && powerManager.isWakeLockLevelSupported(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK)

    fun start() {
        if (isSupported) {
            sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)
        }
    }

    fun stop() {
        if (isSupported) {
            sensorManager.unregisterListener(this)
            wakeLock
                ?.takeIf { it.isHeld }
                ?.release()
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // NOOP
    }

    override fun onSensorChanged(event: SensorEvent) {
        val distanceInCentimeters = event.values[0]
        if (distanceInCentimeters < (sensor?.maximumRange ?: 20f)) {
            onProximityNear()
        } else {
            onProximityFar()
        }
    }

    private fun generateWakeLockTag() = "RemPC:$PROXIMITY_WAKE_LOCK_TAG"

    private fun onProximityNear() {
        if (wakeLock == null) {
            wakeLock = powerManager.newWakeLock(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK, generateWakeLockTag())
        }
        wakeLock
            ?.takeIf { !it.isHeld }
            ?.acquire(WAKE_LOCK_TIMEOUT_MILLIS)
    }

    private fun onProximityFar() {
        wakeLock
            ?.takeIf { it.isHeld }
            ?.release()
    }
}
