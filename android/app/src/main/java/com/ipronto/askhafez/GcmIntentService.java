package com.ipronto.askhafez;

import android.app.IntentService;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.google.android.gms.gcm.GoogleCloudMessaging;

import org.json.JSONException;
import org.json.JSONObject;


/**
 * Created by roozbeh on 3/11/15.
 */
public class GcmIntentService extends IntentService {
    public static final int NOTIFICATION_ID = 1;
    private NotificationManager mNotificationManager;
    NotificationCompat.Builder builder;

    private static final String TAG = "GcmIntentService";

    public GcmIntentService() {
        super("GcmIntentService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        Log.e("GGCMIntentService", "onHandleIntent");

        Bundle extras = intent.getExtras();
        GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(this);
        // The getMessageType() intent parameter must be the intent you received
        // in your BroadcastReceiver.
        String messageType = gcm.getMessageType(intent);

        if (!extras.isEmpty()) {  // has effect of unparcelling Bundle
            /*
             * Filter messages based on message type. Since it is likely that GCM
             * will be extended in the future with new message types, just ignore
             * any message types you're not interested in, or that you don't
             * recognize.
             */
            if (GoogleCloudMessaging.MESSAGE_TYPE_SEND_ERROR.equals(messageType)) {
                sendNotification("Error", "Send error: " + extras.toString(), "");

            } else if (GoogleCloudMessaging.MESSAGE_TYPE_DELETED.equals(messageType)) {
                sendNotification("Deleted", "Deleted messages on server: " +
                        extras.toString(), "");
                // If it's a regular GCM message, do some work.

            } else if (GoogleCloudMessaging.MESSAGE_TYPE_MESSAGE.equals(messageType)) {
                // This loop represents the service doing some work.

                String aps = extras.getString("aps");
                JSONObject apsObj = null;
                try {
                    apsObj = new JSONObject(aps);

                    sendNotification("AskHafez", apsObj.getString("alert"), apsObj.getString("link_url"));
                    Log.i(TAG, "Received: " + extras.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }
        // Release the wake lock provided by the WakefulBroadcastReceiver.
        GcmBroadcastReceiver.completeWakefulIntent(intent);
    }

    // Put the message into a notification and post it.
    // This is just one simple example of what you might choose to do with
    // a GCM message.
    private void sendNotification(String title, String msg, String link_url) {
        Log.e("GGCMIntentService", "sendNotification");

        mNotificationManager = (NotificationManager)
                this.getSystemService(Context.NOTIFICATION_SERVICE);

        Intent notificationIntent = new Intent(this, MainActivity.class);
        notificationIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        notificationIntent.putExtra("link_url", link_url);

        PendingIntent contentIntent = PendingIntent.getActivity(this, 0, notificationIntent,  PendingIntent.FLAG_CANCEL_CURRENT);


//        Uri soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);

        Bitmap largeIcon = BitmapFactory.decodeResource(getResources(), R.drawable.ic_launcher);

        NotificationCompat.Builder mBuilder =
                new NotificationCompat.Builder(this)
                        .setLargeIcon(largeIcon)
                        .setSmallIcon(R.drawable.ic_launcher)
                        .setContentTitle(title)
                        .setStyle(new NotificationCompat.BigTextStyle()
                                .bigText(msg))
                        .setContentText(msg);
//                        .setSound(soundUri);

        mBuilder.setContentIntent(contentIntent);
        mBuilder.setSound(Settings.System.DEFAULT_NOTIFICATION_URI);
        mNotificationManager.notify(NOTIFICATION_ID, mBuilder.build());
    }
}
