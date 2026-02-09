package com.example.couple_app

import android.annotation.TargetApi
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews

@TargetApi(Build.VERSION_CODES.CUPCAKE)
class CoupleWidget : AppWidgetProvider() {
        override fun onUpdate(
                context: Context,
                appWidgetManager: AppWidgetManager,
                appWidgetIds: IntArray
        ) {
                for (appWidgetId in appWidgetIds) {
                        val widgetData =
                                context.getSharedPreferences(
                                        "HomeWidgetPreferences",
                                        Context.MODE_PRIVATE
                                )

                        // Check Widget Size
                        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
                        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
                        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)

                        // Layout Selection Logic
                        // 1. If width is narrow (e.g. 2x3), use small layout
                        val isSmall = minWidth < 150

                        val layoutId =
                                if (isSmall) R.layout.couple_widget_layout_small
                                else R.layout.couple_widget_layout

                        val views = RemoteViews(context.packageName, layoutId)

                        // Get data from Flutter
                        val name1 = widgetData.getString("name1", "") ?: ""
                        val name2 = widgetData.getString("name2", "") ?: ""
                        val startDate = widgetData.getLong("startDate", 0)

                        // Calculate days dynamically if startDate is available
                        val displayDays =
                                if (startDate > 0) {
                                        val now = System.currentTimeMillis()
                                        val diff = now - startDate
                                        val daysCount = (diff / (1000 * 60 * 60 * 24)) + 1
                                        daysCount.toString()
                                } else {
                                        // Fallback to static data if new app hasn't run yet
                                        widgetData.getString("days", "—") ?: "—"
                                }

                        // Extract Initials with safe null handling
                        val initial1 =
                                name1?.takeIf { it.isNotEmpty() }?.substring(0, 1)?.uppercase()
                                        ?: "?"
                        val initial2 =
                                name2?.takeIf { it.isNotEmpty() }?.substring(0, 1)?.uppercase()
                                        ?: "?"

                        if (!isSmall) {
                                views.setTextViewText(R.id.widget_initial1, initial1)
                                views.setTextViewText(R.id.widget_initial2, initial2)
                        }

                        val nameDisplay =
                                if (name1.isEmpty() && name2.isEmpty()) {
                                        "Tap to Setup"
                                } else {
                                        "$name1 & $name2"
                                }
                        views.setTextViewText(R.id.widget_names, nameDisplay)
                        views.setTextViewText(R.id.widget_days, displayDays)

                        // Intent to launch the app
                        val intent =
                                Intent(context, MainActivity::class.java).apply {
                                        action = Intent.ACTION_MAIN
                                        addCategory(Intent.CATEGORY_LAUNCHER)
                                        addFlags(
                                                Intent.FLAG_ACTIVITY_NEW_TASK or
                                                        Intent.FLAG_ACTIVITY_CLEAR_TOP
                                        )
                                }

                        val pendingIntent =
                                PendingIntent.getActivity(
                                        context,
                                        appWidgetId,
                                        intent,
                                        PendingIntent.FLAG_UPDATE_CURRENT or
                                                PendingIntent.FLAG_IMMUTABLE
                                )

                        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                        appWidgetManager.updateAppWidget(appWidgetId, views)
                }
        }

        override fun onAppWidgetOptionsChanged(
                context: Context,
                appWidgetManager: AppWidgetManager,
                appWidgetId: Int,
                newOptions: android.os.Bundle
        ) {

                // Trigger an update to refresh the layout
                onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
                super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        }
}
