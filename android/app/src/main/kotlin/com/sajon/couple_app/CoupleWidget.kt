package com.sajon.couple_app

import android.annotation.TargetApi
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.media.ExifInterface
import android.os.Build
import android.widget.RemoteViews
import java.util.Calendar
import java.util.concurrent.TimeUnit
import kotlin.math.max

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

                        // Get data
                        val name1 = widgetData.getString("name1", "") ?: ""
                        val name2 = widgetData.getString("name2", "") ?: ""
                        val startDateMillis = widgetData.getLong("startDate", 0)
                        val avatar1Path = widgetData.getString("avatar1Path", "") ?: ""
                        val avatar2Path = widgetData.getString("avatar2Path", "") ?: ""

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

                                                val diffMillis =
                                                        nowCalendar.timeInMillis -
                                                                startCalendar.timeInMillis
                                                val daysCount =
                                                        TimeUnit.MILLISECONDS.toDays(diffMillis) + 1
                                                daysCount.toString()
                                        } catch (e: Exception) {
                                                widgetData.getString("days", "—") ?: "—"
                                        }
                                } else {
                                        widgetData.getString("days", "—") ?: "—"
                                }

                        // Initials
                        val initial1 =
                                name1.takeIf { it.isNotEmpty() }?.substring(0, 1)?.uppercase()
                                        ?: "?"
                        val initial2 =
                                name2.takeIf { it.isNotEmpty() }?.substring(0, 1)?.uppercase()
                                        ?: "?"

                        // Avatar 1
                        val bitmap1 = loadCorrectlyOrientedBitmap(context, avatar1Path)
                        if (bitmap1 != null) {
                                views.setImageViewBitmap(R.id.widget_avatar1, bitmap1)
                                views.setViewVisibility(
                                        R.id.widget_avatar1,
                                        android.view.View.VISIBLE
                                )
                                views.setViewVisibility(
                                        R.id.widget_initial1,
                                        android.view.View.GONE
                                )
                        } else {
                                views.setTextViewText(R.id.widget_initial1, initial1)
                                views.setViewVisibility(R.id.widget_avatar1, android.view.View.GONE)
                                views.setViewVisibility(
                                        R.id.widget_initial1,
                                        android.view.View.VISIBLE
                                )
                        }

                        // Avatar 2
                        val bitmap2 = loadCorrectlyOrientedBitmap(context, avatar2Path)
                        if (bitmap2 != null) {
                                views.setImageViewBitmap(R.id.widget_avatar2, bitmap2)
                                views.setViewVisibility(
                                        R.id.widget_avatar2,
                                        android.view.View.VISIBLE
                                )
                                views.setViewVisibility(
                                        R.id.widget_initial2,
                                        android.view.View.GONE
                                )
                        } else {
                                views.setTextViewText(R.id.widget_initial2, initial2)
                                views.setViewVisibility(R.id.widget_avatar2, android.view.View.GONE)
                                views.setViewVisibility(
                                        R.id.widget_initial2,
                                        android.view.View.VISIBLE
                                )
                        }

                        val nameDisplay =
                                if (name1.isEmpty() && name2.isEmpty()) "Tap to Setup"
                                else "$name1 & $name2"
                        views.setTextViewText(R.id.widget_names, nameDisplay)
                        views.setTextViewText(R.id.widget_days, displayDays)

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
                onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
                super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        }

        private fun loadCorrectlyOrientedBitmap(context: Context, path: String): Bitmap? {
                if (path.isEmpty()) return null
                val file = java.io.File(path)
                if (!file.exists()) return null

                try {
                        // 1. Get Orientation
                        val exifInterface = ExifInterface(path)
                        val orientation =
                                exifInterface.getAttributeInt(
                                        ExifInterface.TAG_ORIENTATION,
                                        ExifInterface.ORIENTATION_NORMAL
                                )
                        val rotationInDegrees =
                                when (orientation) {
                                        ExifInterface.ORIENTATION_ROTATE_90 -> 90
                                        ExifInterface.ORIENTATION_ROTATE_180 -> 180
                                        ExifInterface.ORIENTATION_ROTATE_270 -> 270
                                        else -> 0
                                }

                        // 2. Load Bitmap (Downsampled)
                        val targetSizeDp = 67
                        val targetSizePx =
                                (targetSizeDp * context.resources.displayMetrics.density).toInt()

                        val options = BitmapFactory.Options()
                        options.inJustDecodeBounds = true
                        BitmapFactory.decodeFile(path, options)

                        options.inSampleSize =
                                calculateInSampleSize(options, targetSizePx, targetSizePx)
                        options.inJustDecodeBounds = false

                        var bitmap = BitmapFactory.decodeFile(path, options) ?: return null

                        // 3. Rotate if needed
                        if (rotationInDegrees != 0) {
                                val matrix = Matrix()
                                matrix.preRotate(rotationInDegrees.toFloat())
                                val rotatedBitmap =
                                        Bitmap.createBitmap(
                                                bitmap,
                                                0,
                                                0,
                                                bitmap.width,
                                                bitmap.height,
                                                matrix,
                                                true
                                        )
                                if (rotatedBitmap != bitmap) {
                                        bitmap.recycle()
                                }
                                bitmap = rotatedBitmap
                        }

                        // 4. Scale (Center Crop)
                        val scale =
                                max(
                                        targetSizePx.toFloat() / bitmap.width,
                                        targetSizePx.toFloat() / bitmap.height
                                )
                        val matrix = Matrix()
                        matrix.postScale(scale, scale)

                        // Center logic
                        val scaledWidth = bitmap.width * scale
                        val scaledHeight = bitmap.height * scale
                        val dx = (targetSizePx - scaledWidth) / 2f
                        val dy = (targetSizePx - scaledHeight) / 2f
                        matrix.postTranslate(dx, dy)

                        // 5. Draw Circular Mask
                        val output =
                                Bitmap.createBitmap(
                                        targetSizePx,
                                        targetSizePx,
                                        Bitmap.Config.ARGB_8888
                                )
                        val canvas = Canvas(output)
                        val paint = Paint()
                        paint.isAntiAlias = true

                        val radius = targetSizePx / 2f
                        canvas.drawCircle(radius, radius, radius, paint)

                        paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
                        canvas.drawBitmap(bitmap, matrix, paint)

                        bitmap.recycle() // Recycle the intermediate correctly oriented bitmap
                        return output
                } catch (e: Exception) {
                        return null
                }
        }

        private fun calculateInSampleSize(
                options: BitmapFactory.Options,
                reqWidth: Int,
                reqHeight: Int
        ): Int {
                val height = options.outHeight
                val width = options.outWidth
                var inSampleSize = 1
                if (height > reqHeight || width > reqWidth) {
                        val halfHeight = height / 2
                        val halfWidth = width / 2
                        while (halfHeight / inSampleSize >= reqHeight &&
                                halfWidth / inSampleSize >= reqWidth) {
                                inSampleSize *= 2
                        }
                }
                return inSampleSize
        }
}
