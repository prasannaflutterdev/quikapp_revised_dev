package com.example.app

import androidx.multidex.MultiDexApplication
import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant

class Application : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
    }

    override fun registerWith(registry: PluginRegistry?) {
        if (registry != null) {
            GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        }
    }
} 