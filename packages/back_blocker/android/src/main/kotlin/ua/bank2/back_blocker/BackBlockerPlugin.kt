package ua.bank2.back_blocker

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class BackBlockerPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    private val channelName = "back_blocker"

    private val enableBackButtonMethodName = "$channelName.enableBackButton"
    private val disableBackButtonMethodName = "$channelName.disableBackButton"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            enableBackButtonMethodName -> {
                enableBackButton(result)
            }
            disableBackButtonMethodName -> {
                disableBackButton(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun enableBackButton(result: MethodChannel.Result) {
        BackBlocker.canGoBack = true;
        result.success(null)
    }

    private fun disableBackButton(result: MethodChannel.Result) {
        BackBlocker.canGoBack = false;
        result.success(null)
    }
}
