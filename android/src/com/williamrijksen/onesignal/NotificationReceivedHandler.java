package com.williamrijksen.onesignal;

import android.content.Context;
import org.json.JSONObject;
import org.appcelerator.titanium.TiApplication;
import com.onesignal.OneSignal;
import org.appcelerator.kroll.common.Log;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationReceivedEvent;
import com.onesignal.OSNotificationOpenedResult;
import com.onesignal.OSNotificationAction;

public class NotificationReceivedHandler implements OneSignal.OSRemoteNotificationReceivedHandler {

    private static final String LCAT = "ComWilliamrijksenOnesignalModule";


    @Override
    public void remoteNotificationReceived(Context context, OSNotificationReceivedEvent notificationReceivedEvent) {
        Log.d(LCAT, "com.williamrijksen.onesignal Notification received handler");
        if (TiApplication.getAppCurrentActivity() != null && ComWilliamrijksenOnesignalModule.getModuleInstance() != null) {
            try {
                if (notificationReceivedEvent.getNotification().getRawPayload() != null) {
                    JSONObject payload = notificationReceivedEvent.getNotification().toJSONObject();

                    if (ComWilliamrijksenOnesignalModule.getModuleInstance().hasListeners("notificationReceived")) {
                        ComWilliamrijksenOnesignalModule.getModuleInstance().fireEvent("notificationReceived", payload);
                    }
                }
            } catch (Throwable t) {
                Log.d(LCAT, "com.williamrijksen.onesignal OSNotification could not be converted to JSON");
            }
        }
    }
}