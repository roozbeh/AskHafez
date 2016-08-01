package com.ipronto.askhafez;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.AdListener;
import com.facebook.ads.AdSettings;
import com.facebook.ads.AdSize;
import com.facebook.ads.AdView;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;


/**
 * Created by roozbeh on 6/7/15.
 */
public class GenericActivity extends Activity implements AdListener {

    private AdView adView;
    Tracker tracker;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        AnalyticsApplication application = (AnalyticsApplication) getApplication();
        tracker= application.getDefaultTracker();
    }

    protected void initAds() {
        // Instantiate an AdView view
        adView = new AdView(this, "1260704423969786_1260705903969638", AdSize.BANNER_HEIGHT_50);

        // Find the main layout of your activity
        RelativeLayout layout = (RelativeLayout)findViewById(R.id.activityLayout);

        if (adView.getParent() != null) {
            layout.removeView(adView);
        }

        AdSettings.addTestDevice("f19f9b17b5796816fd19a0bcfed51ce5");

        RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT); // You might want to tweak these to WRAP_CONTENT
        lp.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        layout.addView(adView, lp);

        adView.setAdListener(this);
//        adView.se
        // Request to load an ad
        adView.loadAd();

    }

    @Override
    public void onError(Ad ad, AdError adError) {
        Log.e("GenericActivity", "AdView onError: " + adError.toString());
    }

    @Override
    public void onAdLoaded(Ad ad) {
        Log.i("GenericActivity", "AdView ad loaded");
    }

    @Override
    public void onAdClicked(Ad ad) {
        Log.i("GenericActivity", "AdView ad clicked");
    }

    protected void sendPageView(String pageName) {
        tracker.setScreenName(pageName);
        tracker.send(new HitBuilders.ScreenViewBuilder().build());

    }
}
