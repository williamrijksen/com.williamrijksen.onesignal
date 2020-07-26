package com.williamrijksen.onesignal;

import org.json.JSONObject;
import java.util.HashMap;

import com.onesignal.OneSignal;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationOpenResult;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiConfig;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.util.TiConvert;

@Kroll.module(name="ComWilliamrijksenOnesignal", id="com.williamrijksen.onesignal")
public class ComWilliamrijksenOnesignalModule extends KrollModule
{
	private static final String LCAT = "com.williamrijksen.onesignal";
	private static ComWilliamrijksenOnesignalModule module;
	private static OSNotificationOpenResult openNotification;

	public static final OneSignal.LOG_LEVEL LOG_LEVEL_NONE = OneSignal.LOG_LEVEL.NONE;
	public static final OneSignal.LOG_LEVEL LOG_LEVEL_DEBUG = OneSignal.LOG_LEVEL.DEBUG;
	public static final OneSignal.LOG_LEVEL LOG_LEVEL_INFO = OneSignal.LOG_LEVEL.INFO;
	public static final OneSignal.LOG_LEVEL LOG_LEVEL_WARN = OneSignal.LOG_LEVEL.WARN;
	public static final OneSignal.LOG_LEVEL LOG_LEVEL_ERROR = OneSignal.LOG_LEVEL.ERROR;
	public static final OneSignal.LOG_LEVEL LOG_LEVEL_FATAL = OneSignal.LOG_LEVEL.FATAL;
	public static final OneSignal.LOG_LEVEL LOG_LEVEL_VERBOSE = OneSignal.LOG_LEVEL.VERBOSE;

	public ComWilliamrijksenOnesignalModule()
	{
		super();
		module = this;
	}

	public static ComWilliamrijksenOnesignalModule getModuleInstance()
	{
		return module;
	}

	private KrollFunction getTagsCallback = null;
	private KrollFunction idsAvailableCallback = null;

	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app)
	{
		Log.d(LCAT, "inside onAppCreate");

		OneSignal
				.startInit(TiApplication.getInstance())
				.setNotificationReceivedHandler(new NotificationReceivedHandler())
				.setNotificationOpenedHandler(new NotificationOpenedHandler())
				.unsubscribeWhenNotificationsAreDisabled(true)
				.inFocusDisplaying(OneSignal.OSInFocusDisplayOption.None)
				.init();
	}

	public void listenerAdded(String type, int count, KrollProxy proxy)
	{
		Log.d(LCAT,"added listener " + type);
		if (type.equals("notificationOpened") && count == 1 && openNotification instanceof OSNotificationOpenResult) {
			Log.d(LCAT,"fire delayed event");
			try {
				if (openNotification.notification.payload != null) {
					JSONObject payload = openNotification.notification.payload.toJSONObject();
					payload.put("foreground", openNotification.notification.isAppInFocus);
					proxy.fireEvent("notificationOpened", payload);
				}
			} catch (Throwable t) {
				Log.d(LCAT, "OSNotificationOpenResult could not be converted to JSON");
			}
			openNotification = null;
		}
	}

	@Kroll.method
	public void sendTag(KrollDict tag)
	{
		String key = TiConvert.toString(tag, "key");
		String value = TiConvert.toString(tag, "value");

		OneSignal.sendTag(key, value);
	}

	@Kroll.method
	public void deleteTag(KrollDict tag)
	{
		String key = TiConvert.toString(tag, "key");
		OneSignal.deleteTag(key);
	}

	@Kroll.method
	public boolean retrieveSubscribed(){
		return OneSignal.getPermissionSubscriptionState().getSubscriptionStatus().getSubscribed();
	}

	@Kroll.method
	public String retrievePlayerId(){
		return OneSignal.getPermissionSubscriptionState().getSubscriptionStatus().getUserId();
	}

	@Kroll.method
	public String retrieveToken(){
		return OneSignal.getPermissionSubscriptionState().getSubscriptionStatus().getPushToken();
	}

	@Kroll.method
	public void setExternalUserId(String id)
	{
		OneSignal.setExternalUserId(id, new OneSignal.OSExternalUserIdUpdateCompletionHandler() {
			@Override
			public void onComplete(JSONObject results) {
				Log.d(LCAT, "Set external user id done with results: " + results.toString());
			}
		});
	}

	@Kroll.method
	public void removeExternalUserId()
	{
		OneSignal.removeExternalUserId(new OneSignal.OSExternalUserIdUpdateCompletionHandler() {
			@Override
			public void onComplete(JSONObject results) {
				Log.d(LCAT, "Remove external user id done with results: " + results.toString());
			}
		});
	}

	@Kroll.method
	public void setSubscription(boolean enable)
	{
		OneSignal.setSubscription(enable);
	}

	@Kroll.method
	public void getTags(KrollFunction handler)
	{
		getTagsCallback = handler;
		OneSignal.getTags(new GetTagsHandler());
	}

	@Kroll.method
	public void setLogLevel(KrollDict args)
	{
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

	private class GetTagsHandler implements OneSignal.GetTagsHandler
	{
		@Override
		public void tagsAvailable(JSONObject tags)
		{
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

	private class IdsAvailableHandler implements OneSignal.IdsAvailableHandler
	{
		@Override
		public void idsAvailable(String userId, String registrationId)
		{
			HashMap<String, Object> dict = new HashMap<String, Object>();
			try {
				dict.put("userId", userId);
				dict.put("pushToken", registrationId);
			} catch (Exception e) {
				Log.d("error:", e.toString());
			}

			idsAvailableCallback.call(getKrollObject(), dict);
		}
	}

	private static class NotificationOpenedHandler implements OneSignal.NotificationOpenedHandler
	{
		// This fires when a notification is opened by tapping on it.
		@Override
		public void notificationOpened(OSNotificationOpenResult result)
		{
			Log.d(LCAT, "Notification opened handler");
			if (TiApplication.getAppCurrentActivity() != null && getModuleInstance() != null) {
				try {
					if (result.notification.payload != null) {
						JSONObject payload = result.notification.payload.toJSONObject();
						payload.put("foreground", result.notification.isAppInFocus);

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

	private static class NotificationReceivedHandler implements OneSignal.NotificationReceivedHandler
	{
		@Override
		public void notificationReceived(OSNotification notification)
		{
			Log.d(LCAT, "Notification received handler");
			if (TiApplication.getAppCurrentActivity() != null && getModuleInstance() != null) {
				try {
					if (notification.payload != null) {
						JSONObject payload = notification.payload.toJSONObject();
						payload.put("foreground", notification.isAppInFocus);

						if (getModuleInstance().hasListeners("notificationReceived")) {
							getModuleInstance().fireEvent("notificationReceived", payload);
						}
					}
				} catch (Throwable t) {
					Log.d(LCAT, "OSNotification could not be converted to JSON");
				}
			}
		}
	}
}
