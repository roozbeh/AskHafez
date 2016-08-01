package com.ipronto.askhafez;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.app.TabActivity;
import android.util.Log;
import android.util.Patterns;
import android.widget.LinearLayout;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;
import android.view.Menu;
import android.content.Intent;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;

public class MainActivity extends TabActivity {
	TabHost tabHost;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

//        tracker = GoogleAnalyticsTracker.getInstance();
//        tracker.startNewSession("UA-36120510-1", 10, this);
//        GoogleAnalytics analytics = GoogleAnalytics.getInstance(this);
        // To enable debug logging use: adb shell setprop log.tag.GAv4 DEBUG
//        tracker = analytics.newTracker("UA-36120510-1");

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
        
        initDailyGhazals();

        handleDeepLink();
    }


    @Override
    protected void onNewIntent(Intent newIntent) {
        this.setIntent(newIntent);

        handleDeepLink();
    }

    public static String[] extractLinks(String text) {
        List<String> links = new ArrayList<String>();
        Matcher m = Patterns.WEB_URL.matcher(text);
        while (m.find()) {
            String url = m.group();
            Log.d("MainActivity", "URL extracted: " + url);
            links.add(url);
        }

        return links.toArray(new String[links.size()]);
    }

    void handleDeepLink() {
        if (this.getIntent().hasExtra("link_url")) {
            String link_url = this.getIntent().getStringExtra("link_url");
            Uri u = Uri.parse(link_url);
            String ghazalNumber = u.getPath().substring(1);
            navigateTo(Integer.parseInt(ghazalNumber));
        }
    }

    void initDailyGhazals() {
        SharedPreferences prefs = this.getSharedPreferences(
                getString(R.string.SettingsKey), Context.MODE_PRIVATE);

        if (prefs.getInt("DailyGhazal", -1) == -1) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setMessage("Do you want to receive daily Ghazal of Hafez?").setPositiveButton("Yes", dialogClickListener)
                    .setNegativeButton("No", dialogClickListener).show();

        }
    }

    DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
            final SharedPreferences prefs = MainActivity.this.getSharedPreferences(
                    getString(R.string.SettingsKey), Context.MODE_PRIVATE);

            switch (which){
                case DialogInterface.BUTTON_POSITIVE:
                    //Yes button clicked
                    HafezAPI.instance().sendToken2Api(MainActivity.this, new HafezAPI.TutAPIListener() {
                        @Override
                        public void responseReady(boolean success, Object message) {
                            Log.i("MainActivity", "Token sent, success " + success);
                            if (success) {
                                prefs.edit().putInt("DailyGhazal", 1).apply();
                            }
                        }
                    });
                    break;

                case DialogInterface.BUTTON_NEGATIVE:
                    prefs.edit().putInt("DailyGhazal", 0).apply();
                    //No button clicked
                    break;
            }
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
