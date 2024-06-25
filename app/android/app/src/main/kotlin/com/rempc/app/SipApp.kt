package com.rempc.app

import android.util.Log
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.rempc.app.eventBus.commands.SipLog
import org.greenrobot.eventbus.EventBus
import org.pjsip.pjsua2.*

interface SipAppObserver {
    fun notifyRegState(code: Int, reason: String?, expiration: Long)
    fun notifyIncomingCall(call: SipCall?)
    fun notifyCallState(call: SipCall?)
    fun notifyCallMediaState(call: SipCall?)
    fun notifyBuddyState(buddy: SipBuddy?)
    fun notifyChangeNetwork()
}

internal class SipLogWriter : LogWriter() {
    override fun write(entry: LogEntry) {
//        EventBus.getDefault().post(SipLog(entry.msg))
//        println(entry.msg)
    }
}

class SipCall(acc: SipAccount?, call_id: Int) : Call(acc, call_id) {
    var vidWin: VideoWindow? = null
    var vidPrev: VideoPreview? = null

    val callId
        get(): Int {
            return this.id
        }

    override fun onCallState(prm: OnCallStateParam) {
        try {
            val ci = info
            if (ci.state ==
                pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED
            ) {
                SipApp.endpoint?.utilLogWrite(3, "SipCall", dump(true, ""))
            }
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }

        SipApp.observer?.notifyCallState(this)
    }

    override fun onCallMediaState(prm: OnCallMediaStateParam) {
        val ci: CallInfo
        ci = try {
            info
        } catch (e: Exception) {
            return
        }
        val cmiv = ci.media
        for (i in cmiv.indices) {
            val cmi = cmiv[i]
            if (cmi.type == pjmedia_type.PJMEDIA_TYPE_AUDIO &&
                (cmi.status ==
                        pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE ||
                        cmi.status ==
                        pjsua_call_media_status.PJSUA_CALL_MEDIA_REMOTE_HOLD)
            ) {
                val media = getMedia(i.toLong())
                val audioMedia = AudioMedia.typecastFromMedia(media)
                audioMedia.adjustRxLevel(SipApp.microphoneVolume)
                audioMedia.adjustTxLevel(SipApp.speakerVolume)

                try {
                    SipApp.endpoint?.audDevManager()?.captureDevMedia?.startTransmit(audioMedia)
                    audioMedia.startTransmit(SipApp.endpoint?.audDevManager()?.playbackDevMedia)
                } catch (e: Exception) {
                    continue
                }
            } else if (cmi.type == pjmedia_type.PJMEDIA_TYPE_VIDEO && cmi.status ==
                pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE && cmi.videoIncomingWindowId != pjsua2.INVALID_ID
            ) {
                vidWin = VideoWindow(cmi.videoIncomingWindowId)
                vidPrev = VideoPreview(cmi.videoCapDev)
            }
        }
        SipApp.observer?.notifyCallMediaState(this)
    }
}

class SipAccount(var cfg: AccountConfig) : Account() {
    @JvmField
    var buddyList = ArrayList<SipBuddy>()
    fun addBuddy(bud_cfg: BuddyConfig): SipBuddy? {
        var bud: SipBuddy? = SipBuddy(bud_cfg)
        try {
            bud?.create(this, bud_cfg)
        } catch (e: Exception) {
            bud?.delete()
            bud = null
        }
        if (bud != null) {
            buddyList.add(bud)
            if (bud_cfg.subscribe) try {
                bud.subscribePresence(true)
            } catch (e: Exception) {
            }
        }
        return bud
    }

    fun delBuddy(buddy: SipBuddy) {
        buddyList.remove(buddy)
        buddy.delete()
    }

    fun delBuddy(index: Int) {
        val bud = buddyList[index]
        buddyList.removeAt(index)
        bud.delete()
    }

    override fun onRegState(prm: OnRegStateParam) {
        SipApp.observer?.notifyRegState(
            prm.code, prm.reason,
            prm.expiration
        )
    }

    override fun onIncomingCall(prm: OnIncomingCallParam) {
        println("======== Incoming call ======== ")
        val call = SipCall(this, prm.callId)
        SipApp.observer?.notifyIncomingCall(call)
    }

    override fun onInstantMessage(prm: OnInstantMessageParam) {
        println("======== Incoming pager ======== ")
        println("From     : " + prm.fromUri)
        println("To       : " + prm.toUri)
        println("Contact  : " + prm.contactUri)
        println("Mimetype : " + prm.contentType)
        println("Body     : " + prm.msgBody)
    }
}

class SipBuddy(var cfg: BuddyConfig) : Buddy() {
    val statusText: String?
        get() {
            val bi: BuddyInfo
            bi = try {
                info
            } catch (e: Exception) {
                return "?"
            }
            var status: String? = ""
            if (bi.subState == pjsip_evsub_state.PJSIP_EVSUB_STATE_ACTIVE) {
                if (bi.presStatus.status ==
                    pjsua_buddy_status.PJSUA_BUDDY_STATUS_ONLINE
                ) {
                    status = bi.presStatus.statusText
                    if (status == null || status.length == 0) {
                        status = "Online"
                    }
                } else if (bi.presStatus.status ==
                    pjsua_buddy_status.PJSUA_BUDDY_STATUS_OFFLINE
                ) {
                    status = "Offline"
                } else {
                    status = "Unknown"
                }
            }
            return status
        }

    override fun onBuddyState() {
        SipApp.observer?.notifyBuddyState(this)
    }
}

internal class SipAccountConfig {
    var accCfg = AccountConfig()
    var buddyCfgs = ArrayList<BuddyConfig>()
    fun readObject(node: ContainerNode) {
        try {
            val acc_node = node.readContainer("Account")
            accCfg.readObject(acc_node)
            val buddies_node = acc_node.readArray("buddies")
            buddyCfgs.clear()
            while (buddies_node.hasUnread()) {
                val bud_cfg = BuddyConfig()
                bud_cfg.readObject(buddies_node)
                buddyCfgs.add(bud_cfg)
            }
        } catch (e: Exception) {
        }
    }

    fun writeObject(node: ContainerNode) {
        try {
            val acc_node = node.writeNewContainer("Account")
            accCfg.writeObject(acc_node)
            val buddies_node = acc_node.writeNewArray("buddies")
            for (j in buddyCfgs.indices) {
                buddyCfgs[j].writeObject(buddies_node)
            }
        } catch (e: Exception) {
        }
    }
}

class SipApp {

    companion object {
        var endpoint: Endpoint? = Endpoint()
        var observer: SipAppObserver? = null
        var microphoneVolume: Float = 2.4f
        var speakerVolume: Float = 2.4f
    }

    @JvmField
    var accList = ArrayList<SipAccount?>()
    private val accCfgs = ArrayList<SipAccountConfig>()
    private val epConfig = EpConfig()
    private val sipTpConfig = TransportConfig()
    private var appDir: String? = null

    /* Maintain reference to log writer to avoid premature cleanup by GC */
    private var logWriter: SipLogWriter? = null
    private val configName = "pjsua2.json"
    private val SIP_PORT = 56900
    private val LOG_LEVEL = 4 // 4

    @JvmOverloads
    fun init(
        obs: SipAppObserver?, app_dir: String?,
        own_worker_thread: Boolean = false,
        microphoneVolume: Float = 2.4f,
        speakerVolume: Float = 2.4f,
    ) {
        observer = obs
        appDir = app_dir

        try {
            endpoint?.libCreate()
        } catch (e: Exception) {
            return
        }

        SipApp.microphoneVolume = microphoneVolume
        SipApp.speakerVolume = speakerVolume

        sipTpConfig.port = SIP_PORT.toLong()
        epConfig.logConfig.level = LOG_LEVEL.toLong()
        epConfig.logConfig.consoleLevel = LOG_LEVEL.toLong()

        val log_cfg = epConfig.logConfig
        logWriter = SipLogWriter()
        log_cfg.writer = logWriter
        log_cfg.decor = log_cfg.decor and
                (pj_log_decoration.PJ_LOG_HAS_CR or
                        pj_log_decoration.PJ_LOG_HAS_NEWLINE).inv().toLong()


        val ua_cfg = epConfig.uaConfig
        ua_cfg.userAgent = "Pjsua2 Android " + endpoint?.libVersion()?.full

        /* STUN server. */
        val stun_servers = StringVector()
//        stun_servers.add("stun.zoiper.com")
        stun_servers.add("stun.pjsip.org")
        ua_cfg.setStunServer(stun_servers)

        if (own_worker_thread) {
            ua_cfg.threadCnt = 0
            ua_cfg.mainThreadOnly = true
        }

        epConfig.medConfig.sndRecLatency = 30000
        epConfig.medConfig.ecOptions = 128
        epConfig.medConfig.ecTailLen = 200
        epConfig.medConfig.quality = 4
        epConfig.medConfig.audioFramePtime = 20
//        epConfig.uaConfig.stunTryIpv6 = false
//        epConfig.uaConfig.stunIgnoreFailure = true

        sipTpConfig.portRange = 200

        try {
            endpoint?.libInit(epConfig)
        } catch (e: Exception) {
            return
        }

        try {
            endpoint?.transportCreate(
                pjsip_transport_type_e.PJSIP_TRANSPORT_UDP,
                sipTpConfig
            )
        } catch (e: Exception) {
            println(e)
        }
//        try {
//            endpoint?.transportCreate(
//                    pjsip_transport_type_e.PJSIP_TRANSPORT_TCP,
//                    sipTpConfig
//            )
//        } catch (e: Exception) {
//            println(e)
//        }
//        try {
//            sipTpConfig.port = (SIP_PORT + 1).toLong()
//            endpoint?.transportCreate(
//                    pjsip_transport_type_e.PJSIP_TRANSPORT_TLS,
//                    sipTpConfig
//            )
//        } catch (e: Exception) {
//            println(e)
//        }

        sipTpConfig.port = SIP_PORT.toLong()

        for (i in accCfgs.indices) {
            val my_cfg = accCfgs[i]

            my_cfg.accCfg.natConfig.iceEnabled = true // Check ice
            my_cfg.accCfg.videoConfig.autoTransmitOutgoing = false
            my_cfg.accCfg.videoConfig.autoShowIncoming = false
            val acc = addAcc(my_cfg.accCfg) ?: continue

            for (j in my_cfg.buddyCfgs.indices) {
                val bud_cfg = my_cfg.buddyCfgs[j]
                acc.addBuddy(bud_cfg)
            }
        }

        var codecs = endpoint?.codecEnum2()
        if (codecs != null) {
            for (codec in codecs) {
                when (codec.codecId) {
                    "PCMA/8000/1" -> endpoint?.codecSetPriority(codec.codecId, 127)
//                    "GSM/8000/1" -> endpoint?.codecSetPriority(codec.codecId, 134)
//                    "opus/48000/2" -> endpoint?.codecSetPriority(codec.codecId, 135)
//                    "G722/16000/1" -> endpoint?.codecSetPriority(codec.codecId, 136)
                    else -> endpoint?.codecSetPriority(codec.codecId, 0)
                }
            }
        }

        try {
            endpoint?.libStart()
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
            return
        }
    }

    fun setVolume(
        microphoneVolume: Float = 2.4f,
        speakerVolume: Float = 2.4f
    ) {
        SipApp.microphoneVolume = microphoneVolume
        SipApp.speakerVolume = speakerVolume
    }

    fun addAcc(cfg: AccountConfig): SipAccount? {
        var acc: SipAccount? = SipAccount(cfg)
        try {
            acc?.create(cfg)
        } catch (e: Exception) {
            acc = null
            FirebaseCrashlytics.getInstance().recordException(e)
            return null
        }
        accList.add(acc)
        return acc
    }

    fun delAcc(acc: SipAccount?) {
        accList.remove(acc)
    }

    private fun loadConfig(filename: String) {
        val json = JsonDocument()
        try {
            /* Load file */
            json.loadFile(filename)
            val root = json.rootContainer

            /* Read endpoint config */epConfig.readObject(root)

            /* Read transport config */
            val tp_node = root.readContainer("SipTransport")
            sipTpConfig.readObject(tp_node)

            /* Read account configs */accCfgs.clear()
            val accs_node = root.readArray("accounts")
            while (accs_node.hasUnread()) {
                val acc_cfg = SipAccountConfig()
                acc_cfg.readObject(accs_node)
                accCfgs.add(acc_cfg)
            }
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }

        json.delete()
    }

    private fun buildAccConfigs() {
        accCfgs.clear()
        for (i in accList.indices) {
            val acc = accList[i]
            val my_acc_cfg = SipAccountConfig()
            acc?.let {
                my_acc_cfg.accCfg = it.cfg
            }
            my_acc_cfg.buddyCfgs.clear()
            acc?.let {
                for (j in it.buddyList.indices) {
                    val bud = it.buddyList[j]
                    my_acc_cfg.buddyCfgs.add(bud.cfg)
                }
            }

            accCfgs.add(my_acc_cfg)
        }
    }

    private fun saveConfig(filename: String) {
        val json = JsonDocument()
        try {
            json.writeObject(epConfig)

            val tp_node = json.writeNewContainer("SipTransport")
            sipTpConfig.writeObject(tp_node)

            buildAccConfigs()
            val accs_node = json.writeNewArray("accounts")
            for (i in accCfgs.indices) {
                accCfgs[i].writeObject(accs_node)
            }

            /* Save file */json.saveFile(filename)
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }

        json.delete()
    }

    fun handleNetworkChange() {
        try {
            println("Network change detected")
            val changeParam = IpChangeParam()
            endpoint?.handleIpChange(changeParam)
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }
    }

    fun deinit() {
//        val configPath = "$appDir/$configName"
//        saveConfig(configPath)

        try {
            endpoint?.libDestroy()
        } catch (e: Exception) {
            FirebaseCrashlytics.getInstance().recordException(e)
        }

        endpoint?.delete()
        endpoint = null
    }
}
