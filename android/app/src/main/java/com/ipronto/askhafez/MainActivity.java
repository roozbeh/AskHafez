package com.ipronto.askhafez;

import com.google.android.apps.analytics.GoogleAnalyticsTracker;

import android.os.Bundle;
import android.app.TabActivity;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;
import android.view.Menu;
import android.content.Intent;

import com.zcet.unwy213548.AdListener;  //Add import statements
import com.zcet.unwy213548.MA;

public class MainActivity extends TabActivity {
	TabHost tabHost;
	GoogleAnalyticsTracker tracker;
	
	private MA ma; //Declare here
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

        tracker = GoogleAnalyticsTracker.getInstance();
        tracker.startNewSession("UA-36120510-1", 10, this);

        tabHost = getTabHost();
 
        // Tab for Photos
        TabSpec ghazalspec = tabHost.newTabSpec("Ghazals");
        // setting Title and Icon for the Tab
        ghazalspec.setIndicator("Ghazals", getResources().getDrawable(R.drawable.icon_ghazal_tab));
        Intent ghazalIntent= new Intent(this, GhazalActivity.class);
        ghazalspec.setContent(ghazalIntent);
 
        // Tab for Songs
        TabSpec faalspec = tabHost.newTabSpec("Faal");
        faalspec.setIndicator("Faal", getResources().getDrawable(R.drawable.icon_faal_tab));
        Intent faalIntent = new Intent(this, FaalActivity.class);
        faalspec.setContent(faalIntent);
 
        // Tab for Videos
        TabSpec searchspec = tabHost.newTabSpec("Search");
        searchspec.setIndicator("Search", getResources().getDrawable(R.drawable.icon_search_tab));
        Intent searchIntent = new Intent(this, SearchActivity.class);
        searchspec.setContent(searchIntent);
 
        // Adding all TabSpec to TabHost
        tabHost.addTab(ghazalspec); // Adding photos tab
        tabHost.addTab(faalspec); // Adding songs tab
        tabHost.addTab(searchspec); // Adding videos tab
        
        if(ma==null)
        	ma=new MA(this, adCallbackListener, false);
	}

	AdListener adCallbackListener=new AdListener() {
        @Override
        public void onSDKIntegrationError(String message) {
        //Here you will receive message from SDK if it detects any integration issue.
        }

        public void onSmartWallAdShowing() {
        // This will be called by SDK when it’s showing any of the SmartWall ad.
        }

        @Override
        public void onSmartWallAdClosed() {
        // This will be called by SDK when the SmartWall ad is closed.
        }

        @Override
        public void onAdError(String message) {
        //This will get called if any error occurred during ad serving.
        }
        @Override
		public void onAdCached(AdType arg0) {
		//This will get called when an ad is cached. 
		
		}
		 @Override
		public void noAdAvailableListener() {
		//this will get called when ad is not available 
		
		}
     };
     
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_main, menu);
		return true;
	}

	public void faal() {
        tabHost.setCurrentTab(0);
        GhazalActivity ghazalActivity = (GhazalActivity) getLocalActivityManager().getActivity("Ghazals");
        ghazalActivity.setRandom();
	}
	
	public void navigateTo(int id) {
        tabHost.setCurrentTab(0);
        GhazalActivity ghazalActivity = (GhazalActivity) getLocalActivityManager().getActivity("Ghazals");
        ghazalActivity.setViewToGhazal(id);
	}
	
}
