package com.rempc.app.callkit

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.rempc.app.eventBus.commands.*
import org.greenrobot.eventbus.EventBus

class CallkitIncomingBroadcastReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_CALL_INCOMING =
            "com.hiennv.flutter_callkit_incoming.ACTION_CALL_INCOMING"
        const val ACTION_CALL_ACCEPT =
            "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT"
        const val ACTION_CALL_DECLINE =
            "com.hiennv.flutter_callkit_incoming.ACTION_CALL_DECLINE"
    }

    @SuppressLint("MissingPermission")
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        when (action) {
            ACTION_CALL_ACCEPT -> {
                EventBus.getDefault().post(AcceptCallCommand("plugin"))
                EventBus.getDefault().post(SetAudioFocus(true))
            }

            ACTION_CALL_DECLINE -> {
                EventBus.getDefault().post(HangupCallCommand())
                EventBus.getDefault().post(SetAudioFocus(false))
            }
        }
    }
}
