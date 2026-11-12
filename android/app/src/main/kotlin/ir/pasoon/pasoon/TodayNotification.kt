package ir.pasoon.pasoon

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.drawable.Icon
import android.os.Build
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * Ongoing notification with today's Jalali date in the status bar and today's owghat.
 * The data for the coming days is calculated in Dart and stored here, so the notification
 * keeps working while the app is closed.
 */
object TodayNotification {
    private const val PREFS = "today_notification"
    private const val KEY_DAYS = "days"
    private const val CHANNEL_ID = "today"
    private const val NOTIFICATION_ID = 1
    private const val ACCENT = 0xFF0F7A6C.toInt()

    private val labelIds = intArrayOf(R.id.label_0, R.id.label_1, R.id.label_2, R.id.label_3, R.id.label_4)
    private val timeIds = intArrayOf(R.id.time_0, R.id.time_1, R.id.time_2, R.id.time_3, R.id.time_4)

    fun save(context: Context, json: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString(KEY_DAYS, json).apply()
    }

    fun show(context: Context) {
        val manager = context.getSystemService(NotificationManager::class.java)
        val today = findToday(context)
        if (today == null) {
            manager.cancel(NOTIFICATION_ID)
            return
        }
        createChannel(manager)

        val now = System.currentTimeMillis()
        val times = today.getJSONArray("times")
        var next = -1
        for (i in 0 until times.length()) {
            if (times.getJSONObject(i).getLong("at") > now) {
                next = i
                break
            }
        }

        val notification = builder(context)
            .setSmallIcon(dayIcon(today.getInt("day")))
            .setContentTitle(today.getString("title"))
            .setContentText(today.getString("subtitle"))
            .setSubText(today.getString("city"))
            .setCustomContentView(content(context, today, times, next))
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setContentIntent(openApp(context))
            .setOngoing(true)
            .setShowWhen(false)
            .setOnlyAlertOnce(true)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setCategory(Notification.CATEGORY_STATUS)
            .build()

        try {
            manager.notify(NOTIFICATION_ID, notification)
        } catch (_: SecurityException) {
            // Notification permission not granted.
        }

        val nextRefresh = if (next >= 0) times.getJSONObject(next).getLong("at") + 1000 else nextMidnight()
        scheduleRefresh(context, minOf(nextRefresh, nextMidnight()))
    }

    private fun content(context: Context, today: JSONObject, times: JSONArray, next: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.notification_today)
        views.setTextViewText(R.id.title, today.getString("title"))
        views.setTextViewText(R.id.subtitle, today.getString("subtitle"))
        for (i in labelIds.indices) {
            if (i >= times.length()) continue
            val t = times.getJSONObject(i)
            views.setTextViewText(labelIds[i], t.getString("label"))
            views.setTextViewText(timeIds[i], t.getString("text"))
            if (i == next) {
                views.setTextColor(labelIds[i], ACCENT)
                views.setTextColor(timeIds[i], ACCENT)
            }
        }
        return views
    }

    private fun findToday(context: Context): JSONObject? {
        val json = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY_DAYS, null) ?: return null
        val key = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Calendar.getInstance().time)
        return try {
            val days = JSONArray(json)
            (0 until days.length()).map { days.getJSONObject(it) }.firstOrNull { it.getString("date") == key }
        } catch (_: Exception) {
            null
        }
    }

    /** Draws the Jalali day of month as the status bar icon. */
    private fun dayIcon(day: Int): Icon {
        val size = 96
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val text = day.toString().map { "۰۱۲۳۴۵۶۷۸۹"[it - '0'] }.joinToString("")
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textAlign = Paint.Align.CENTER
            typeface = Typeface.DEFAULT_BOLD
            textSize = size * 0.8f
        }
        val width = paint.measureText(text)
        if (width > size) paint.textSize *= size / width
        val y = size / 2f - (paint.descent() + paint.ascent()) / 2f
        Canvas(bitmap).drawText(text, size / 2f, y, paint)
        return Icon.createWithBitmap(bitmap)
    }

    private fun builder(context: Context): Notification.Builder =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context).setPriority(Notification.PRIORITY_LOW)
        }

    private fun createChannel(manager: NotificationManager) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(CHANNEL_ID, "تاریخ و اوقات امروز", NotificationManager.IMPORTANCE_LOW).apply {
            setShowBadge(false)
            enableVibration(false)
            setSound(null, null)
        }
        manager.createNotificationChannel(channel)
    }

    private fun openApp(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun nextMidnight(): Long = Calendar.getInstance().apply {
        add(Calendar.DAY_OF_YEAR, 1)
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 5)
        set(Calendar.MILLISECOND, 0)
    }.timeInMillis

    private fun scheduleRefresh(context: Context, at: Long) {
        val intent = Intent(context, TodayNotificationReceiver::class.java)
        val pending = PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        // Non-wakeup alarm: fires on time while the screen is on, or as soon as the device wakes.
        context.getSystemService(AlarmManager::class.java).set(AlarmManager.RTC, at, pending)
    }
}
