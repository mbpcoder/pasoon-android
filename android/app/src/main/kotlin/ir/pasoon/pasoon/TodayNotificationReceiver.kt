package ir.pasoon.pasoon

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Refreshes the today notification at midnight, after each prayer time, on boot and on clock changes. */
class TodayNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        TodayNotification.show(context)
    }
}
