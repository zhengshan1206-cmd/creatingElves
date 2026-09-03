package com.beiyinhuanyue.aixiaosczjl
import android.view.Window
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.beiyinhuanyue.aixiaosczjl.common.GlobalConstant
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.ByPlugin
//import com.umeng.commonsdk.UMConfigure
import android.os.Bundle

class MainActivity: FlutterActivity(), MethodChannel.MethodCallHandler {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            GlobalConstant.FLUTTER_CHANNEL_NAME
        )
            .setMethodCallHandler(this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //设置LOG开关，默认为false
//        UMConfigure.setLogEnabled(true);
//        UMConfigure.preInit(this, "685dfc1379267e021095f628", "1938")
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            //toAppInit
            GlobalConstant.APP_INIT -> {
                val appId = call.argument<String>("appid")
                val channel = call.argument<String>("channel")
                ByPlugin.iniBDConvert(applicationContext, activity, appId, channel)
                result.success(ByPlugin.baserResult(GlobalConstant.SUCCESS))
            }
            //头条SDK回传
            GlobalConstant.OCEANENGINE_EVENT -> {
                val params = call.argument<String>("params");
                ByPlugin.oceanengineEvent(params)
            }
            //toAPP设备信息
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

            //user-agent
            //GlobalConstant.USER_AGENT -> {
            //    // Android获取User-Agent（使用系统WebView的默认值）
            //    val userAgent = System.getProperty("http.agent") // 系统默认User-Agent
            //   result.success(userAgent)
            //}

            else -> {
            }
        }
    }

}
