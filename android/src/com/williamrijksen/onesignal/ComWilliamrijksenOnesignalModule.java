package com.williamrijksen.onesignal;

import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import com.onesignal.OSNotificationOpenedResult;
import com.onesignal.OneSignal;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiConfig;
import org.appcelerator.titanium.TiApplication;
import org.json.JSONObject;

import java.util.HashMap;

@Kroll.module(name = "ComWilliamrijksenOnesignal", id = "com.williamrijksen.onesignal")
public class ComWilliamrijksenOnesignalModule extends KrollModule {
    public static final OneSignal.LOG_LEVEL LOG_LEVEL_NONE = OneSignal.LOG_LEVEL.NONE;
    public static final OneSignal.LOG_LEVEL LOG_LEVEL_DEBUG = OneSignal.LOG_LEVEL.DEBUG;
    public static final OneSignal.LOG_LEVEL LOG_LEVEL_INFO = OneSignal.LOG_LEVEL.INFO;
    public static final OneSignal.LOG_LEVEL LOG_LEVEL_WARN = OneSignal.LOG_LEVEL.WARN;
    public static final OneSignal.LOG_LEVEL LOG_LEVEL_ERROR = OneSignal.LOG_LEVEL.ERROR;
    public static final OneSignal.LOG_LEVEL LOG_LEVEL_FATAL = OneSignal.LOG_LEVEL.FATAL;
    public static final OneSignal.LOG_LEVEL LOG_LEVEL_VERBOSE = OneSignal.LOG_LEVEL.VERBOSE;
    private static final String LCAT = "ComWilliamrijksenOnesignalModule";
    private static final boolean DBG = TiConfig.LOGD;
    private static ComWilliamrijksenOnesignalModule module;
    private static OSNotificationOpenedResult openNotification;
    private final KrollFunction idsAvailableCallback = null;
    private KrollFunction getTagsCallback = null;

    public ComWilliamrijksenOnesignalModule() {
        super();
        module = this;
    }

    public static ComWilliamrijksenOnesignalModule getModuleInstance() {
        return module;
    }

    @Kroll.onAppCreate
    public static void onAppCreate(TiApplication app) {
        Log.d(LCAT, "inside onAppCreate");

        OneSignal.initWithContext(TiApplication.getInstance());
        OneSignal.setAppId(getAppId());
        OneSignal.setNotificationOpenedHandler(new NotificationOpenedHandler());
    }

    private static String getAppId() {
        try {
            ApplicationInfo app = TiApplication.getInstance().getPackageManager().getApplicationInfo(TiApplication.getInstance().getPackageName(), PackageManager.GET_META_DATA);
            return app.metaData.getString("onesignal_app_id");
        } catch (Exception e) {
            return null;
        }
    }

    public void listenerAdded(String type, int count, KrollProxy proxy) {
        Log.d(LCAT, "added listener " + type);
        if (type.equals("notificationOpened") && count == 1 && openNotification instanceof OSNotificationOpenedResult) {
            Log.d(LCAT, "fire delayed event");
            try {
                if (openNotification.getNotification().getRawPayload() != null) {
                    JSONObject payload = openNotification.getNotification().toJSONObject();
                    proxy.fireEvent("notificationOpened", payload);
                }
            } catch (Throwable t) {
                Log.d(LCAT, "OSNotificationOpenResult could not be converted to JSON");
            }
            openNotification = null;
        }
    }

    @Kroll.method
    public boolean isRooted() {
        String[] places = {"/sbin/", "/system/bin/", "/system/xbin/",
                "/data/local/xbin/", "/data/local/bin/",
                "/system/sd/xbin/", "/system/bin/failsafe/",
                "/data/local/"};

        try {
            for (String where : places) {
                if (new java.io.File(where + "su").exists())
                    return true;
            }
        } catch (Throwable ignore) {
            // workaround crash issue in Lenovo devices
            // issues #857
        }
        return false;
    }

    @Kroll.method
    public void sendTag(KrollDict dict) {
        String key = dict.getString("key");
        String value = dict.getString("value");
        OneSignal.sendTag(key, value);
    }

    @Kroll.method
    public void deleteTag(KrollDict dict) {
        String key = dict.getString("key");
        OneSignal.deleteTag(key);
    }

    @Kroll.method
    public boolean retrieveSubscribed() {
        return OneSignal.getDeviceState().isSubscribed();
    }

    @Kroll.method
    public String retrievePlayerId() {
        return OneSignal.getDeviceState().getUserId();
    }

    @Kroll.method
    public String retrieveToken() {
        return OneSignal.getDeviceState().getPushToken();
    }

    @Kroll.method
    public void setExternalUserId(String id) {
        OneSignal.setExternalUserId(id, new OneSignal.OSExternalUserIdUpdateCompletionHandler() {
            @Override
            public void onSuccess(JSONObject results) {
                Log.d(LCAT, "Remove external user id done with results: " + results.toString());
            }

            @Override
            public void onFailure(OneSignal.ExternalIdError error) {

            }
        });
    }

    @Kroll.method
    public void removeExternalUserId() {
        OneSignal.removeExternalUserId(new OneSignal.OSExternalUserIdUpdateCompletionHandler() {
            @Override
            public void onSuccess(JSONObject results) {
                Log.d(LCAT, "Remove external user id done with results: " + results.toString());
            }

            @Override
            public void onFailure(OneSignal.ExternalIdError error) {

            }
        });
    }

    @Kroll.method
    public void setSubscription(boolean enable) {
        OneSignal.disablePush(enable);
    }

    @Kroll.method
    public void getTags(KrollFunction handler) {
        getTagsCallback = handler;
        OneSignal.getTags(new GetTagsHandler());
    }

    @Kroll.method
    public void setLogLevel(KrollDict args) {
        OneSignal.LOG_LEVEL logLevel = LOG_LEVEL_NONE;
        OneSignal.LOG_LEVEL visualLevel = LOG_LEVEL_NONE;

        Object level = args.get("logLevel");
        if (level instanceof OneSignal.LOG_LEVEL) {
            logLevel = (OneSignal.LOG_LEVEL) level;
        }

        level = args.get("visualLevel");
        if (level instanceof OneSignal.LOG_LEVEL) {
            visualLevel = (OneSignal.LOG_LEVEL) level;
        }
        OneSignal.setLogLevel(logLevel, visualLevel);
    }

    private static class NotificationOpenedHandler implements OneSignal.OSNotificationOpenedHandler {
        // This fires when a notification is opened by tapping on it.
        @Override
        public void notificationOpened(OSNotificationOpenedResult result) {
            Log.d(LCAT, "Notification opened handler");
            if (TiApplication.getAppCurrentActivity() != null && getModuleInstance() != null) {
                try {
                    if (result.getNotification().getRawPayload() != null) {
                        JSONObject payload = result.getNotification().toJSONObject();

                        if (getModuleInstance().hasListeners("notificationOpened")) {
                            getModuleInstance().fireEvent("notificationOpened", payload);
                        } else {
                            // save the notification for later processing
                            openNotification = result;
                        }
                    }
                } catch (Throwable t) {
                    Log.d(LCAT, "OSNotificationOpenResult could not be converted to JSON");
                }
            } else {
                // save the notification for later processing
                openNotification = result;
            }
        }
    }

    private class GetTagsHandler implements OneSignal.OSGetTagsHandler {
        @Override
        public void tagsAvailable(JSONObject tags) {
            HashMap<String, Object> dict = new HashMap<String, Object>();
            try {
                dict.put("success", true);
                dict.put("error", false);
                dict.put("results", tags.toString());
            } catch (Exception e) {
                dict.put("success", false);
                dict.put("error", true);
                e.printStackTrace();
                Log.d("error:", e.toString());
            }

            getTagsCallback.call(getKrollObject(), dict);
        }
    }

}
