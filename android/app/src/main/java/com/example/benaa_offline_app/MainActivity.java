package com.example.benaa_offline_app;

import android.content.Context;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    @Override
    public FlutterEngine provideFlutterEngine(Context context) {
        try {
            FlutterEngine engine = BenaaApplication.getCachedEngine();
            if (engine != null) {
                return engine;
            }
            return BenaaApplication.warmUpMainEngine(context.getApplicationContext());
        } catch (Throwable ignored) {
            return super.provideFlutterEngine(context);
        }
    }

    @Override
    public boolean shouldDestroyEngineWithHost() {
        return false;
    }
}
