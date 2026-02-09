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
                        val views = RemoteViews(context.packageName, R.layout.couple_widget_layout)

                        // Get data from Flutter
                        val name1 = widgetData.getString("name1", "U")
                        val name2 = widgetData.getString("name2", "P")
                        val days = widgetData.getString("days", "0")

                        // Extract Initials with safe null handling
                        val initial1 =
                                name1?.takeIf { it.isNotEmpty() }?.substring(0, 1)?.uppercase()
                                        ?: "?"
                        val initial2 =
                                name2?.takeIf { it.isNotEmpty() }?.substring(0, 1)?.uppercase()
                                        ?: "?"

                        views.setTextViewText(R.id.widget_initial1, initial1)
                        views.setTextViewText(R.id.widget_initial2, initial2)
                        views.setTextViewText(R.id.widget_names, "$name1 & $name2")
                        views.setTextViewText(R.id.widget_days, days)

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
}
