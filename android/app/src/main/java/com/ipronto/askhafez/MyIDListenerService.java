package com.ipronto.askhafez;

import android.util.Log;

import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.google.android.gms.iid.InstanceID;
import com.google.android.gms.iid.InstanceIDListenerService;

import java.io.IOException;

/**
 * Created by roozbeh on 7/9/16.
 */
public class MyIDListenerService  extends InstanceIDListenerService {

    public void onTokenRefresh() {
        InstanceID instanceID = InstanceID.getInstance(MyIDListenerService.this);
        String token;
        try {
            token = instanceID.getToken(getString(R.string.SenderID), GoogleCloudMessaging.INSTANCE_ID_SCOPE, null);
        } catch (IOException e) {
            token = "Failed" + e;
        }

        Log.i("MyIDListenerService", "Token refreshed: " + token);
    }
}
