package com.williamrijksen.onesignal;

import android.content.Context;

import com.onesignal.OneSignal;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationAction;
import com.onesignal.OSNotificationOpenResult;

import java.util.HashMap;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
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

	public ComWilliamrijksenOnesignalModule()
	{
		super();
		TiApplication appContext = TiApplication.getInstance();
		OneSignal
		.startInit(appContext)
		.setNotificationReceivedHandler(new NotificationReceivedHandler())
		.setNotificationOpenedHandler(new NotificationOpenedHandler())
		.inFocusDisplaying(OneSignal.OSInFocusDisplayOption.None)
		.init();
	}
	//TODO inFocusDisplaying should be configurable from Titanium App module initialization

	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app)
	{
		Log.d(LCAT, "inside onAppCreate");
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

	private class NotificationOpenedHandler implements OneSignal.NotificationOpenedHandler {
		// This fires when a notification is opened by tapping on it.
		@Override
		public void notificationOpened(OSNotificationOpenResult result) {
			String title = result.notification.payload.title;
			String body = result.notification.payload.body;
			JSONObject additionalData = result.notification.payload.additionalData;

			HashMap<String, Object> kd = new HashMap<String, Object>();
			if(title != null){
				kd.put("title", title);
			}

			if(body != null){
				kd.put("body", body);
			}

			if(additionalData != null){
				String payload = additionalData.toString();
				kd.put("additionalData", payload);
			}
			fireEvent("OneSignalNotificationOpened", kd);
		}
	}

	private class NotificationReceivedHandler implements OneSignal.NotificationReceivedHandler {
		@Override
		public void notificationReceived(OSNotification notification) {
			JSONObject additionalData = notification.payload.additionalData;
			if(additionalData != null){
				String payload = additionalData.toString();
				HashMap<String, Object> kd = new HashMap<String, Object>();
				kd.put("additionalData", payload);
				fireEvent("OneSignalNotificationReceived", kd);
			}else{
				Log.d(LCAT, "No additionalData on notification payload =/");
			}
		}
	}
}
