package com.sajon.couple_app

import android.annotation.TargetApi
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import java.util.Calendar
import java.util.concurrent.TimeUnit

@TargetApi(Build.VERSION_CODES.CUPCAKE)
class DaysWidget : AppWidgetProvider() {
    override fun onUpdate(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData =
                    context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val views = RemoteViews(context.packageName, R.layout.days_widget_layout)

            // Get start date from Flutter
            val startDateMillis = widgetData.getLong("startDate", 0)

            // Calculate days dynamically using Calendar
            val displayDays =
                    if (startDateMillis > 0) {
                        try {
                            val startCalendar = Calendar.getInstance()
                            startCalendar.timeInMillis = startDateMillis

                            // Reset to midnight
                            startCalendar.set(Calendar.HOUR_OF_DAY, 0)
                            startCalendar.set(Calendar.MINUTE, 0)
                            startCalendar.set(Calendar.SECOND, 0)
                            startCalendar.set(Calendar.MILLISECOND, 0)

                            val nowCalendar = Calendar.getInstance()
                            nowCalendar.set(Calendar.HOUR_OF_DAY, 0)
                            nowCalendar.set(Calendar.MINUTE, 0)
                            nowCalendar.set(Calendar.SECOND, 0)
                            nowCalendar.set(Calendar.MILLISECOND, 0)

                            val diffMillis = nowCalendar.timeInMillis - startCalendar.timeInMillis
                            val daysCount = TimeUnit.MILLISECONDS.toDays(diffMillis) + 1
                            daysCount.toString()
                        } catch (e: Exception) {
                            widgetData.getString("days", "—") ?: "—"
                        }
                    } else {
                        widgetData.getString("days", "—") ?: "—"
                    }

            views.setTextViewText(R.id.days_widget_counter, displayDays)

            // Intent to launch the app
            val intent =
                    Intent(context, MainActivity::class.java).apply {
                        action = Intent.ACTION_MAIN
                        addCategory(Intent.CATEGORY_LAUNCHER)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    }

            val pendingIntent =
                    PendingIntent.getActivity(
                            context,
                            appWidgetId,
                            intent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )

            views.setOnClickPendingIntent(R.id.days_widget_root, pendingIntent)

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
