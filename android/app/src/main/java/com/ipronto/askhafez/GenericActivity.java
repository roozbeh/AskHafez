package com.ipronto.askhafez;

import android.app.Activity;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;

/**
 * Created by roozbeh on 6/7/15.
 */
public class GenericActivity extends Activity {

    protected void initAds() {
        AdView mAdView = (AdView) findViewById(R.id.adView);
        if (mAdView != null) {
            AdRequest adRequest = new AdRequest.Builder().addTestDevice("9DE8C59A4BDBF61FBA44A0EBECFF4A96").build();
            mAdView.loadAd(adRequest);
        }
    }

}
