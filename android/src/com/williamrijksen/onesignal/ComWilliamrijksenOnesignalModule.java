package com.williamrijksen.onesignal;

import android.app.Activity;

import com.onesignal.OneSignal;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationAction;
import com.onesignal.OSNotificationOpenResult;
import com.onesignal.OSNotificationPayload;

import java.util.HashMap;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiConfig;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.util.TiConvert;
import org.json.JSONObject;

@Kroll.module(name="ComWilliamrijksenOnesignal", id="com.williamrijksen.onesignal")
public class ComWilliamrijksenOnesignalModule extends KrollModule
{
	private static final String LCAT = "ComWilliamrijksenOnesignalModule";
	private static final boolean DBG = TiConfig.LOGD;
	private static ComWilliamrijksenOnesignalModule module;
	private static OSNotificationOpenResult openNotification;

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
		Log.d(LCAT, "com.williamrijksen.onesignal inside onAppCreate");

		OneSignal
				.startInit(TiApplication.getInstance())
				.setNotificationReceivedHandler(new NotificationReceivedHandler())
				.setNotificationOpenedHandler(new NotificationOpenedHandler())
				.inFocusDisplaying(OneSignal.OSInFocusDisplayOption.None)
				.init();
	}

	public void listenerAdded(String type, int count, KrollProxy proxy)
	{
		Log.d(LCAT,"com.williamrijksen.onesignal added listener " + type);
		if (type.equals("notificationOpened") && count == 1 && openNotification instanceof OSNotificationOpenResult) {
			Log.d(LCAT,"com.williamrijksen.onesignal fire delayed event");
			try {
				OSNotificationPayload payload = openNotification.notification.payload;
				proxy.fireEvent("notificationOpened", payload.toJSONObject());
			} catch (Throwable t) {
				Log.d(LCAT, "com.williamrijksen.onesignal OSNotificationOpenResult could not be converted to JSON");
			}
			openNotification = null;
		}
	}

	@Kroll.method
	public void sendTag(Object tag)
	{
		HashMap <String, Object> dict = (HashMap <String, Object>) tag;
		String key = TiConvert.toString(dict, "key");
		String value = TiConvert.toString(dict, "value");
		OneSignal.sendTag(key, value);
	}

	@Kroll.method
	public void deleteTag(Object tag)
	{
		HashMap <String, Object> dict = (HashMap <String, Object>) tag;
		String key = TiConvert.toString(dict, "key");
		OneSignal.deleteTag(key);
	}

	@Kroll.method
	public void getTags(KrollFunction handler)
	{
		getTagsCallback = handler;
		OneSignal.getTags(new GetTagsHandler());
	}

	@Kroll.method
	public void idsAvailable(KrollFunction handler)
	{
		idsAvailableCallback = handler;
		OneSignal.idsAvailable(new IdsAvailableHandler());
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
			Log.d(LCAT, "com.williamrijksen.onesignal Notification opened handler");
			if (getModuleInstance() != null) {
				try {
					OSNotificationPayload payload = result.notification.payload;

					if (payload != null) {
						if (getModuleInstance().hasListeners("notificationOpened")) {
							getModuleInstance().fireEvent("notificationOpened", payload.toJSONObject());
						} else {
							// save the notification for later processing
							openNotification = result;
						}
					}
				} catch (Throwable t) {
					Log.d(LCAT, "com.williamrijksen.onesignal OSNotificationOpenResult could not be converted to JSON");
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
			Log.d(LCAT, "com.williamrijksen.onesignal Notification received handler");
			if (getModuleInstance() != null) {
				try {
					OSNotificationPayload payload = notification.payload;

					if (getModuleInstance().hasListeners("notificationReceived") && payload != null) {
						getModuleInstance().fireEvent("notificationReceived", payload.toJSONObject());
					}
				} catch (Throwable t) {
					Log.d(LCAT, "com.williamrijksen.onesignal OSNotification could not be converted to JSON");
				}
			}
		}
	}
}
