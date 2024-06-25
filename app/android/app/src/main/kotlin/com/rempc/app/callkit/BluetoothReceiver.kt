package com.rempc.app.callkit

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.rempc.app.eventBus.commands.*
import org.greenrobot.eventbus.EventBus
import android.media.AudioManager
import android.util.Log


class BluetoothReceiver : BroadcastReceiver() {
    private var localAudioManager: AudioManager? = null
    override fun onReceive(context: Context, intent: Intent) {
        Log.i(TAG, "onReceive - BluetoothBroadcast")
        localAudioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val action = intent.action ?: return
        when (action) {
            ACTION_BT_HEADSET_STATE_CHANGED -> {
                val extraData = intent.getIntExtra(EXTRA_STATE, STATE_DISCONNECTED)
                if (extraData == STATE_DISCONNECTED) {
                    Log.i(TAG, "Bluetooth Headset Off " + localAudioManager!!.mode)
                    Log.i(
                        TAG,
                        "A2DP: " + localAudioManager!!.isBluetoothA2dpOn + ". SCO: " + localAudioManager!!.isBluetoothScoAvailableOffCall
                    )
                    localAudioManager!!.isBluetoothScoOn = false
                    localAudioManager!!.stopBluetoothSco()
                    localAudioManager!!.mode = AudioManager.MODE_NORMAL
                    EventBus.getDefault().post(BluetoothHeadsetState(AudioManager.MODE_NORMAL))
                } else {
                    Log.i(TAG, "Bluetooth Headset On " + localAudioManager!!.mode)
                    Log.i(
                        TAG,
                        "A2DP: " + localAudioManager!!.isBluetoothA2dpOn + ". SCO: " + localAudioManager!!.isBluetoothScoAvailableOffCall
                    )
                    localAudioManager!!.mode = AudioManager.MODE_NORMAL
                    localAudioManager!!.isBluetoothScoOn = true
                    localAudioManager!!.startBluetoothSco()
                    localAudioManager!!.mode = AudioManager.MODE_COMMUNICATION_REDIRECT
                    EventBus.getDefault()
                        .post(BluetoothHeadsetState(AudioManager.MODE_COMMUNICATION_REDIRECT))
                }
            }

            ACTION_BT_HEADSET_FORCE_ON -> {
                Log.i(TAG, "Bluetooth Headset On " + localAudioManager!!.mode)
                Log.i(
                    TAG,
                    "A2DP: " + localAudioManager!!.isBluetoothA2dpOn + ". SCO: " + localAudioManager!!.isBluetoothScoAvailableOffCall
                )
                localAudioManager!!.mode = AudioManager.MODE_NORMAL
                localAudioManager!!.isBluetoothScoOn = true
                localAudioManager!!.startBluetoothSco()
                localAudioManager!!.mode = AudioManager.MODE_COMMUNICATION_REDIRECT
                EventBus.getDefault()
                    .post(BluetoothHeadsetState(AudioManager.MODE_COMMUNICATION_REDIRECT))
            }

            ACTION_BT_HEADSET_FORCE_OFF -> {
                localAudioManager!!.isBluetoothScoOn = false
                localAudioManager!!.stopBluetoothSco()
                localAudioManager!!.mode = AudioManager.MODE_NORMAL
                EventBus.getDefault().post(BluetoothHeadsetState(AudioManager.MODE_NORMAL))
                Log.i(TAG, "Bluetooth Headset Off " + localAudioManager!!.mode)
                Log.i(
                    TAG,
                    "A2DP: " + localAudioManager!!.isBluetoothA2dpOn + ". SCO: " + localAudioManager!!.isBluetoothScoAvailableOffCall
                )
            }

            ACTION_CONNECTION_STATE_CHANGED -> {
                Log.i(TAG, "Bluetooth Headset CHANGED " + localAudioManager!!.mode)
            }
        }
    }

    companion object {
        private const val STATE_DISCONNECTED = 0x00000000
        const val EXTRA_STATE = "android.bluetooth.headset.extra.STATE"
        private const val TAG = "BluetoothReceiver"
        const val ACTION_BT_HEADSET_STATE_CHANGED =
            "android.bluetooth.headset.action.STATE_CHANGED"
        const val ACTION_BT_HEADSET_FORCE_ON =
            "android.bluetooth.headset.action.FORCE_ON"
        const val ACTION_BT_HEADSET_FORCE_OFF =
            "android.bluetooth.headset.action.FORCE_OFF"
        const val ACTION_CONNECTION_STATE_CHANGED =
            "android.bluetooth.headset.action.ACTION_CONNECTION_STATE_CHANGED"
    }
}