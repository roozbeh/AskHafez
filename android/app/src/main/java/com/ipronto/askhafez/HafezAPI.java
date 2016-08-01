package com.ipronto.askhafez;

import android.content.Context;
import android.util.Log;

import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.google.android.gms.iid.InstanceID;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.loopj.android.http.SyncHttpClient;

import org.json.JSONArray;
import org.json.JSONObject;
import org.apache.http.*;

/**
 * Created by roozbeh on 7/31/16.
 */
public class HafezAPI {

    private static HafezAPI gInstance = null;

    public static HafezAPI instance() {
        if (null == gInstance) {
            gInstance = new HafezAPI();
        }

        return gInstance;
    }


    private String getSenderID(Context context) {
        int sender_id = context.getResources().getIdentifier("SenderID", "string", context.getPackageName());
        return context.getResources().getString(sender_id);
    }

    public interface TutAPIListener {
        public abstract void responseReady(boolean success, Object message);
    }

    private String getApiHost(Context context) {
        int api_host_id = context.getResources().getIdentifier("ApiHost", "string", context.getPackageName());
        return context.getResources().getString(api_host_id);
    }

    public class SecureVoiceResponseHandler extends JsonHttpResponseHandler {
        TutAPIListener listener;
        String url;
        public SecureVoiceResponseHandler(TutAPIListener l, String u) {
            listener = l;
            url = u;
        }

        protected boolean onHandleResponse(JSONObject response) {
            return false;
        }

        public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
            // If the response is JSONObject instead of expected JSONArray
            Log.i("SecureVoiceAPI", "request succeed for url: " + url);
            Log.i("SecureVoiceAPI", "response: " + response.toString());
            if (!onHandleResponse(response)) {
                listener.responseReady(true, response);
            }
        }

        @Override
        public void onSuccess(int statusCode, Header[] headers, JSONArray results) {
//            Log.w("SecureVoiceAPI", "request success for url: " + url + " but failed as it is an ARRAY!");
            Log.i("SecureVoiceAPI", "request succeed for url: " + url);
            Log.i("SecureVoiceAPI", "response: " + results.toString());
            listener.responseReady(true, results);
        }

        public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONObject errorResponse) {
            Log.w("SecureVoiceAPI", "1 request failed for url: " + url);
            listener.responseReady(false, null);
        }

        public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONArray errorResponse) {
            Log.w("SecureVoiceAPI", "2 request failed for url: " + url);
            listener.responseReady(false, null);
        }

        @Override
        public void onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable) {
            Log.w("SecureVoiceAPI", "3 request failed for url: " + url);
            Log.i("SecureVoiceAPI", "response: " + responseString);
            listener.responseReady(false, null);
        }

    }

    public void sendToken2Api(final Context context, final TutAPIListener listener) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                InstanceID instanceID = InstanceID.getInstance(context);
                String token = null;
                try {
                    token = instanceID.getToken(getSenderID(context), GoogleCloudMessaging.INSTANCE_ID_SCOPE, null);

                    String url = getApiHost(context) + "/setToken.php";

                    RequestParams params = new RequestParams("token", token);
                    params.add("os", "android");
                    params.add("uniq", android.provider.Settings.Secure.getString(context.getContentResolver(), android.provider.Settings.Secure.ANDROID_ID));

                    Log.i("TutAPI", "token sending: " + token);
                    SyncHttpClient client = new SyncHttpClient();
                    client.post(url, params, new SecureVoiceResponseHandler(listener, url));

                } catch (Exception e) {
                    e.printStackTrace();
                    Log.i("HafezAPI", "token sending failed");
                    listener.responseReady(false, null);
                }
            }
        }).start();
    }


}
