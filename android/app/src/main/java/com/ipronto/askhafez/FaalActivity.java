package com.ipronto.askhafez;

import com.google.android.apps.analytics.GoogleAnalyticsTracker;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;

public class FaalActivity extends GenericActivity {
	GoogleAnalyticsTracker tracker;

	public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.faal_layout);
        
		TextView faalFarsiTV = (TextView) findViewById(R.id.faal_fa_text);
		String farsiFaalText = getResources().getString(R.string.FaalFarsiText);
		faalFarsiTV.setText(Farsi.Convert(farsiFaalText));
        
		ImageButton button = (ImageButton)findViewById(R.id.faalButton);
	    // Register the onClick listener with the implementation above
	    button.setOnClickListener(faalButtonListener);

        tracker = GoogleAnalyticsTracker.getInstance();
	    tracker.trackPageView("/android/faal");

        initAds();
	 }
	 
	 private void doFaal(){
		 MainActivity main = (MainActivity) this.getParent();
		 main.faal();			 
	 }
	 
	 private OnClickListener faalButtonListener = new OnClickListener() {
		 public void onClick(View v) {
			 // do something when the button is clicked
			 doFaal();
		 }
	 };	 
}
