package com.example.hydra_bloom

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channelName = "hydrabloom/widget"
    private var pendingAction: String? = null
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getLaunchAction" -> {
                    result.success(pendingAction)
                    pendingAction = null
                }
                "refreshWidget" -> {
                    HydraBloomWidgetProvider.refreshAll(this)
                    result.success(true)
                }
                "consumePendingAddCount" -> {
                    val prefs = getSharedPreferences("hydrabloom_widget", MODE_PRIVATE)
                    val count = prefs.getInt("pending_add_count", 0)
                    prefs.edit().putInt("pending_add_count", 0).apply()
                    result.success(count)
                }
                "syncWidgetCountFromApp" -> {
                    val count = call.arguments as? Int ?: 0
                    val prefs = getSharedPreferences("hydrabloom_widget", MODE_PRIVATE)
                    prefs.edit().putInt("widget_count", count).apply()
                    HydraBloomWidgetProvider.refreshAll(this)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        handleIntentAction(intent?.action)
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntentAction(intent.action)
    }

    private fun handleIntentAction(action: String?) {
        if (action == "com.example.hydra_bloom.ADD_GLASS") {
            pendingAction = "add_glass"
            channel?.invokeMethod("widgetAction", "add_glass")
        }
    }
}
