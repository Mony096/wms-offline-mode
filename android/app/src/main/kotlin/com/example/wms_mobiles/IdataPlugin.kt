// package com.example.wmsmobiles

// import io.flutter.embedding.engine.plugins.FlutterPlugin
// import io.flutter.plugin.common.MethodCall
// import io.flutter.plugin.common.MethodChannel
// import io.flutter.plugin.common.MethodChannel.MethodCallHandler
// import io.flutter.plugin.common.MethodChannel.Result

// class IdataPlugin : FlutterPlugin, MethodCallHandler {
//     private lateinit var channel: MethodChannel

//     override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//         channel = MethodChannel(binding.binaryMessenger, "idata_plugin")
//         channel.setMethodCallHandler(this)
//     }

//     override fun onMethodCall(call: MethodCall, result: Result) {
//         if (call.method == "yourMethod") {
//             // Implement your logic here
//             result.success("Response from IdataPlugin")
//         } else {
//             result.notImplemented()
//         }
//     }

//     override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//         channel.setMethodCallHandler(null)
//     }
// }
