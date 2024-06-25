package com.rempc.app.callkit

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.rempc.app.eventBus.commands.HangupCallCommand
import org.greenrobot.eventbus.EventBus

class HeadsUpNotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.extras != null) {
            performClickAction(context)

            context.stopService(Intent(context, HeadsUpNotificationService::class.java))
        }
    }

    private fun performClickAction(context: Context) {
        EventBus.getDefault().post(HangupCallCommand())
    }
}