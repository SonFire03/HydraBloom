package com.example.hydra_bloom

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import org.json.JSONObject

class HydraBloomWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { appWidgetId ->
            appWidgetManager.updateAppWidget(appWidgetId, buildViews(context))
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        if (intent.action == ACTION_ADD_GLASS) {
            val queuePrefs = context.getSharedPreferences("hydrabloom_widget", Context.MODE_PRIVATE)
            val pending = queuePrefs.getInt("pending_add_count", 0) + 1
            val widgetCount = queuePrefs.getInt("widget_count", 0) + 1
            queuePrefs.edit()
                .putInt("pending_add_count", pending)
                .putInt("widget_count", widgetCount)
                .apply()

            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, HydraBloomWidgetProvider::class.java))
            ids.forEach { id -> manager.updateAppWidget(id, buildViews(context)) }
        }
    }

    private fun buildViews(context: Context): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.hydrabloom_widget)
        val prefs: SharedPreferences =
            context.getSharedPreferences("hydrabloom_widget", Context.MODE_PRIVATE)
        val glasses = prefs.getInt("widget_count", 0)
        val flutterPrefs =
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        var goalMl = 2000
        var glassSizeMl = 250
        val rawSettings = flutterPrefs.getString("flutter.settings", null)
        if (!rawSettings.isNullOrBlank()) {
            try {
                val json = JSONObject(rawSettings)
                goalMl = json.optInt("dailyGoalMl", 2000)
                glassSizeMl = json.optInt("glassSizeMl", 250)
            } catch (_: Exception) {
            }
        }

        val intakeMl = glasses * glassSizeMl
        val percent = if (goalMl <= 0) 0 else ((intakeMl * 100) / goalMl).coerceIn(0, 100)

        views.setTextViewText(R.id.widget_counter, "Aujourd'hui: $glasses verre(s)")
        views.setTextViewText(
            R.id.widget_progress_text,
            "$intakeMl ml / $goalMl ml ($percent%)",
        )
        views.setProgressBar(R.id.widget_progress_bar, 100, percent, false)

        val addIntent = Intent(context, HydraBloomWidgetProvider::class.java).apply {
            action = ACTION_ADD_GLASS
        }
        val addPendingIntent = PendingIntent.getBroadcast(
            context,
            1001,
            addIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPendingIntent = PendingIntent.getActivity(
            context,
            1002,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        views.setOnClickPendingIntent(R.id.widget_root, openPendingIntent)
        views.setOnClickPendingIntent(R.id.widget_add_button, addPendingIntent)

        return views
    }

    companion object {
        const val ACTION_ADD_GLASS = "com.example.hydra_bloom.widget.ADD_GLASS"
        const val ACTION_ADD_GLASS_APP = "com.example.hydra_bloom.ADD_GLASS"

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, HydraBloomWidgetProvider::class.java))
            ids.forEach { id ->
                val provider = HydraBloomWidgetProvider()
                manager.updateAppWidget(id, provider.buildViews(context))
            }
        }
    }
}
