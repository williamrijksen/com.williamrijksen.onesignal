package com.williamrijksen.onesignal;

import android.app.Activity;

import com.onesignal.OneSignal;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationAction;
import com.onesignal.OSNotificationOpenResult;

import java.util.HashMap;

import org.appcelerator.kroll.KrollModule;
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
	private boolean oneSignalInitDone;

	public ComWilliamrijksenOnesignalModule()
	{
		super();
		initOneSignal(TiApplication.getInstance().getCurrentActivity());
	}

	private void initOneSignal(Activity activity)
	{
		if (activity == null || oneSignalInitDone) {
			return;
		}

		oneSignalInitDone = true;

		OneSignal
				.startInit(activity)
				.setNotificationReceivedHandler(new NotificationReceivedHandler())
				.setNotificationOpenedHandler(new NotificationOpenedHandler())
				.inFocusDisplaying(OneSignal.OSInFocusDisplayOption.None)
				.init();
	}
	//TODO inFocusDisplaying should be configurable from Titanium App module initialization

	//variable to store the received call back function for the getTags method call
	private KrollFunction getTagsCallback = null;

	private KrollFunction idsAvailableCallback = null;

	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app)
	{
		Log.d(LCAT, "inside onAppCreate");
	}

	@Override
	public void onResume(Activity activity)
	{
		super.onResume(activity);
		Log.d(LCAT, "Trying to initialize OneSignal if necessary");
		initOneSignal(activity);
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

	private class GetTagsHandler implements OneSignal.GetTagsHandler {
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

	private class IdsAvailableHandler implements OneSignal.IdsAvailableHandler {
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

	private class NotificationOpenedHandler implements OneSignal.NotificationOpenedHandler {
		// This fires when a notification is opened by tapping on it.
		@Override
		public void notificationOpened(OSNotificationOpenResult result) {
			try {
				JSONObject json = result.toJSONObject();
				HashMap<String, Object> kd = new HashMap<String, Object>();

				if (json.has("notification") && json.getJSONObject("notification").has("payload")) {
					JSONObject payload = json.getJSONObject("notification").getJSONObject("payload");

					if (payload.has("title")) {
						kd.put("title", payload.getString("title"));
					}

					if (payload.has("body")) {
						kd.put("body", payload.getString("body"));
					}

					if (payload.has("additionlData")) {
						String additional = payload.getJSONObject("additionalData").toString();
						kd.put("additionalData", additional);
					}
				}
				fireEvent("notificationOpened", kd);
			}
			catch (Throwable t) {
				Log.d(LCAT, "Notification result could not be converted to JSON");
			}
		}
	}

	private class NotificationReceivedHandler implements OneSignal.NotificationReceivedHandler {
		@Override
		public void notificationReceived(OSNotification notification) {
			HashMap<String, Object> kd = new HashMap<String, Object>();

			String title = notification.payload.title;
			if (title != null) {
				kd.put("title", title);
			}

			String body = notification.payload.body;
			if (body != null) {
				kd.put("body", body);
			}

			JSONObject additionalData = notification.payload.additionalData;
			if(additionalData != null){
				String additional = additionalData.toString();
				kd.put("additionalData", additional);
			}

			fireEvent("notificationReceived", kd);
		}
	}
}
