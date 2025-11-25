package com.example.checkkawkaw

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    private val CALL_STATE_CHANNEL = "checkkawkaw/call_state"
    private var handler: CallStateHandler? = null

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        EventChannel(
            engine.dartExecutor.binaryMessenger,
            CALL_STATE_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {

            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                handler = CallStateHandler(this@MainActivity, events)
                handler?.start()
            }

            override fun onCancel(arguments: Any?) {
                handler?.stop()
            }
        })
    }
}

