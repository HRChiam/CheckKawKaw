package com.example.checkkawkaw

import android.content.Context
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import io.flutter.plugin.common.EventChannel

class CallStateHandler(
    private val context: Context,
    private val events: EventChannel.EventSink
) : PhoneStateListener() {

    private val telephonyManager =
        context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

    fun start() {
        telephonyManager.listen(
            this,
            PhoneStateListener.LISTEN_CALL_STATE
        )
    }

    fun stop() {
        telephonyManager.listen(this, PhoneStateListener.LISTEN_NONE)
    }

    override fun onCallStateChanged(state: Int, phoneNumber: String?) {
        val mappedState = when (state) {
            TelephonyManager.CALL_STATE_RINGING -> "RINGING"
            TelephonyManager.CALL_STATE_OFFHOOK -> "OFFHOOK"
            TelephonyManager.CALL_STATE_IDLE -> "IDLE"
            else -> "UNKNOWN"
        }

        events.success(
            mapOf(
                "state" to mappedState,
                "number" to phoneNumber
            )
        )
    }
}
