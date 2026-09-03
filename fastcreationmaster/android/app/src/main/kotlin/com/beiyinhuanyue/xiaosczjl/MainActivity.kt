package com.beiyinhuanyue.aixiaosczjl

import android.os.Bundle
import android.view.Window
import com.beiyinhuanyue.aixiaosczjl.common.GlobalConstant
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.ByPlugin
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            GlobalConstant.FLUTTER_CHANNEL_NAME
        ).setMethodCallHandler(this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            GlobalConstant.APP_INIT -> {
                val appId = call.argument<String>("appid")
                val channel = call.argument<String>("channel")
                ByPlugin.iniBDConvert(applicationContext, this, appId, channel)
                result.success(ByPlugin.baserResult(GlobalConstant.SUCCESS))
            }
            GlobalConstant.OCEANENGINE_EVENT -> {
                val params = call.argument<String>("params")
                ByPlugin.oceanengineEvent(params)
                result.success(ByPlugin.baserResult(GlobalConstant.SUCCESS))
            }
            GlobalConstant.APP_DEVICE_INFO -> {
                ByPlugin.getAndroidDeviceInfo(this) { oId, androidId ->
                    result.success(
                        ByPlugin.baserResult(
                            GlobalConstant.SUCCESS, mapOf(
                                "oId" to oId,
                                "androidId" to androidId
                            )
                        )
                    )
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
