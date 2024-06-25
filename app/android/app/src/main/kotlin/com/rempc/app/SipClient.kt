package com.rempc.app

import android.content.Context
import android.content.IntentFilter
import android.os.Handler
import android.os.Message
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.hiennv.flutter_callkit_incoming.Data
import com.rempc.app.eventBus.commands.*
import com.rempc.app.eventBus.commands.OutgoingCallCommand
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.pjsip.pjsua2.*
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import androidx.core.app.ActivityCompat
import android.Manifest
import android.util.Log

class SipClient(private val context: Context) : SipAppObserver, Handler.Callback {
    object MSG_TYPE {
        const val INCOMING_CALL = 1
        const val CALL_STATE = 2
        const val REG_STATE = 3
        const val BUDDY_STATE = 4
        const val CALL_MEDIA_STATE = 5
        const val CHANGE_NETWORK = 6
    }

    private val handler = Handler(this)

    fun deinit() {
        app?.deinit()
        app = null
        EventBus.getDefault()
            .post(UpdateSipStateCommand(code = -1, reason = "-", expiration = 0))
        EventBus.getDefault().unregister(this)
    }

    fun init(event: RegisterSipClientCommand) {
        if (app != null) {
            return
        }
        app = SipApp()
        app!!.init(
            this,
            event.filesDir,
            microphoneVolume = event.microphoneVolume,
            speakerVolume = event.speakerVolume
        )

        EventBus.getDefault().register(this)

        accCfg = AccountConfig()
        accCfg!!.idUri = "sip:" + event.user + "@" + event.host
        accCfg!!.regConfig.registrarUri = "sip:" + event.host
        val creds = accCfg!!.sipConfig.authCreds
        creds.clear()
        creds.add(
            AuthCredInfo(
                "Digest", "*", event.user, 0,
                event.password
            )
        )
        accCfg!!.natConfig.iceEnabled = true
        accCfg!!.natConfig.viaRewriteUse = 0
        accCfg!!.natConfig.sdpNatRewriteUse = 1
        accCfg!!.videoConfig.autoTransmitOutgoing = false
        accCfg!!.videoConfig.autoShowIncoming = false
        accCfg!!.regConfig.timeoutSec = 300
        accCfg!!.regConfig.retryIntervalSec = 300
        accCfg!!.mediaConfig.srtpUse = 0
        account = app!!.addAcc(accCfg!!)
    }

    fun updateConfig(event: UpdateSipVolumeConfigCommand) {
        app!!.setVolume(
            microphoneVolume = event.microphoneVolume,
            speakerVolume = event.speakerVolume
        )
    }

    fun makeCall(url: String) {
        if (app == null) {
            return
        }

        val call = SipCall(account, -1)
        val prm = CallOpParam(true)
        try {
            call.makeCall(url, prm)
        } catch (e: Exception) {
            call.delete()
        }
        currentCall = call

        EventBus.getDefault()
            .post(OutgoingCallCommand(currentCall?.id, currentCall?.info?.remoteUri))
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onOutgoingCallEvent(event: OutgoingCallCommand) {
        val callInfo: HashMap<String, Any?> = hashMapOf(
            "id" to event.callId.toString(),
            "nameCaller" to "test Name",
            "appName" to "RemPC",
            "handle" to "City Name",
            "type" to 1,
            "extra" to hashMapOf(
                "userId" to "1a2b3c4d",
            ),
            "ios" to hashMapOf(
                "handleType" to "generic"
            ),
        )
        val data = Data(callInfo)
        MainActivity.callkit?.startCall(data)

        EventBus.getDefault().post(SetAudioFocus(true))

        MainActivity.sendEvent(
            "OUTGOING_CALL",
            mapOf("callId" to event.callId.toString(), "remoteUrl" to event.remoteUrl.toString())
        )
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onSipCallStateEvent(event: SipCallStateCommand) {
        val ci = event.callState
        if (ci?.state == pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED) {
            MainActivity.callkit?.endAllCalls()
        }
        MainActivity.sendEvent(
            "CALL_STATE", mapOf(
                "callId" to (ci?.callIdString
                    ?: ""), "remoteUrl" to (ci?.remoteUri ?: ""), "state" to (ci?.state ?: 0)
            )
        )
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun hangUpCall(event: HangupCallCommand?) {
        if (currentCall == null) {
            EventBus.getDefault().post(EndCallCommand())
            return
        }
        val prm = CallOpParam()
        prm.statusCode = pjsip_status_code.PJSIP_SC_DECLINE
        try {
            currentCall?.hangup(prm)
            currentCall = null
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
            EventBus.getDefault().post(EndCallCommand())
        }
    }

    companion object {
        var app: SipApp? = null
        var currentCall: SipCall? = null
        var lastCallInfo: CallInfo? = null
        var account: SipAccount? = null
        var accCfg: AccountConfig? = null
        var intentFilter: IntentFilter? = null
        var lastRegisterStatus: Int? = null
        const val requestCode = 217
    }

    override fun notifyRegState(code: Int, reason: String?, expiration: Long) {
        lastRegisterStatus = code
        EventBus.getDefault()
            .post(UpdateSipStateCommand(code = code, reason = reason, expiration = expiration))
    }

    override fun notifyIncomingCall(call: SipCall?) {
        try {
            if (call == null) {
                return
            }

            val prm = CallOpParam()

            if (currentCall != null) {
                return
            }

            prm.statusCode = pjsip_status_code.PJSIP_SC_RINGING

            try {
                call.answer(prm)
            } catch (e: Exception) {
                FirebaseCrashlytics.getInstance().recordException(e)
            }
            currentCall = call
            lastCallInfo = call.info
            EventBus.getDefault()
                .post(IncomingCallCommand(lastCallInfo?.id.toString(), lastCallInfo?.remoteUri))

        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    override fun notifyCallState(call: SipCall?) {
        try {
            Log.d(
                SipClient::class.qualifiedName,
                "======== CALL INFO: " + call?.info?.state.toString() + " ======== "
            )
            if (currentCall == null || call!!.id != currentCall!!.id) return
            var ci: CallInfo? = null
            try {
                ci = call.info
            } catch (e: Exception) {
                FirebaseCrashlytics.getInstance().recordException(e)
            }
            lastCallInfo = call.info
            val m = Message.obtain(handler, MSG_TYPE.CALL_STATE, ci)
            m.sendToTarget()
            EventBus.getDefault().post(SipCallStateCommand(ci))
            if (lastCallInfo?.state == pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED) {
                EventBus.getDefault().post(ActiveCallNotificationCommand())
            }
            if (lastCallInfo?.state == pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED) {
                currentCall = null
                EventBus.getDefault().post(EndCallCommand())
            }
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    override fun notifyCallMediaState(call: SipCall?) {
        var i = 1
    }

    override fun notifyBuddyState(buddy: SipBuddy?) {
        var i = 1
    }

    override fun notifyChangeNetwork() {
        Log.d(SipClient::class.java.name, "notifyChangeNetwork")
        if (currentCall != null) {
            return
        }
        try {
            app?.handleNetworkChange()
        } catch (e: Throwable) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    override fun handleMessage(m: Message): Boolean {
        if (m.what == MSG_TYPE.CHANGE_NETWORK) {
            if (currentCall != null) {
                return true
            }
            app?.handleNetworkChange()
        }

        return true
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onAcceptCallEvent(event: AcceptCallCommand) {
        Log.d(
            SipClient::class.qualifiedName,
            "_LOG => onAcceptCallEvent"
        )
        val prm = CallOpParam()
        prm.statusCode = pjsip_status_code.PJSIP_SC_OK
        try {
            currentCall?.answer(prm)
            MainActivity.callkit?.endAllCalls()
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
        EventBus.getDefault().post(SetAudioFocus(true))
        EventBus.getDefault().post(AcceptedCallEvent(event.type))
    }
}

