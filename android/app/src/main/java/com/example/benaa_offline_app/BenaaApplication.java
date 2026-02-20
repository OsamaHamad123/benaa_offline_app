package com.example.benaa_offline_app;
import android.app.Application;
import android.content.Context;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class BenaaApplication extends Application {
    public static final String MAIN_ENGINE_ID = "benaa_main_engine";

    @Override
    public void onCreate() {
        super.onCreate();
        warmUpMainEngine(this);
    }

    public static synchronized FlutterEngine warmUpMainEngine(Context context) {
        Context appContext = context.getApplicationContext();
        FlutterEngineCache cache = FlutterEngineCache.getInstance();
        FlutterEngine cachedEngine = cache.get(MAIN_ENGINE_ID);
        if (cachedEngine != null) {
            return cachedEngine;
        }

        FlutterInjector.instance().flutterLoader().startInitialization(appContext);
        FlutterInjector.instance().flutterLoader().ensureInitializationComplete(appContext, null);

        FlutterEngine flutterEngine = new FlutterEngine(appContext);
        flutterEngine.getDartExecutor().executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault());
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        cache.put(MAIN_ENGINE_ID, flutterEngine);
        return flutterEngine;
    }

    public static FlutterEngine getCachedEngine() {
        return FlutterEngineCache.getInstance().get(MAIN_ENGINE_ID);
    }
}
