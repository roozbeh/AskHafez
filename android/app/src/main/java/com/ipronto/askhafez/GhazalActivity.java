package com.ipronto.askhafez;

import java.io.IOException;
import java.util.Iterator;
import java.util.Random;
import java.util.Vector;

import com.google.android.apps.analytics.GoogleAnalyticsTracker;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TableLayout;
import android.widget.TextView;
import android.database.SQLException;
import android.graphics.Typeface;

public class GhazalActivity extends GenericActivity {
	private int ghazal_number;
	private DataBaseHelper myDbHelper;
	private HorizontalPager realViewSwitcher;
	private int ghazal_count;
	GoogleAnalyticsTracker tracker;
	private int m_screen; 
	
	public GhazalActivity() {
	}

    private void shareGhazal(int g) {
        Vector<String> mesras = myDbHelper.loadGhazal(g, 1);
        String ghazalText = "";
        Iterator<String> itr = mesras.iterator();
        for(int i=0;itr.hasNext();i++) {
            String mesra = itr.next();
            ghazalText += mesra;
            if (i%2 == 0)
                ghazalText += "   ";
            else
                ghazalText += "\n";
        }

        mesras = myDbHelper.loadGhazal(g, 2);
        itr = mesras.iterator();
        for(int i=0;itr.hasNext();i++) {
            String mesra = itr.next();
            ghazalText += mesra;
            if (i%2 == 0)
                ghazalText += "   ";
            else
                ghazalText += "\n";
        }

        ghazalText += "\n";
        ghazalText += "\n";
        ghazalText += "AskHafez on Android: https://play.google.com/store/apps/details?id=com.ipronto.askhafez&hl=en \n";

        Intent share = new Intent(Intent.ACTION_SEND);
        share.setType("text/plain");
        share.putExtra(Intent.EXTRA_TEXT, ghazalText);

        startActivity(Intent.createChooser(share, "Please choose how to want to share Ghazal"));
    }

	private ScrollView drawGhazal(final int g) {
		Vector<String> mesras = myDbHelper.loadGhazal(g, 1);
		
		Log.d("HorizontalPager", "draw ghazal started");
		ScrollView scrollView = new ScrollView(this);
		scrollView.setLayoutParams(new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));

		TableLayout tableLayout = new TableLayout(this);

        TextView ghazalIndexTV = new TextView(this);
        ghazalIndexTV.setText("Ghazal #" + (g+1));
        ghazalIndexTV.setGravity(Gravity.LEFT);

        Button btnShare = new Button(this);
        btnShare.setBackgroundDrawable(getResources().getDrawable(R.drawable.share));
        int height = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 40, getResources().getDisplayMetrics());
        btnShare.setLayoutParams(new LayoutParams(height, height));

        LinearLayout headerView = new LinearLayout(this);
        headerView.setLayoutParams(new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));
        headerView.setOrientation(LinearLayout.HORIZONTAL);

        headerView.addView(ghazalIndexTV);
        headerView.addView(btnShare);

        btnShare.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                shareGhazal(g);
            }
        });

        tableLayout.addView(headerView);

		Iterator<String> itr = mesras.iterator();
		for(int i=0;itr.hasNext();i++) {
	        TextView mesraTV = new TextView(this);
	        String mesra = itr.next();
	        Typeface tf= Farsi.GetFarsiFont(this);
	        mesraTV.setTypeface(tf);	        
//	        mesraTV.setText(Farsi.Convert(mesra));
	        mesraTV.setText(DariGlyphUtils.reshapeText(mesra));
	        mesraTV.setPadding(4,2,4,2);
	        if (i%2 == 0)
	        	mesraTV.setGravity(Gravity.RIGHT);
	        tableLayout.addView(mesraTV);
		}

		mesras = myDbHelper.loadGhazal(g, 2);
		itr = mesras.iterator();
		for(int i=0;itr.hasNext();i++) {
	        TextView mesraTV = new TextView(this);
	        mesraTV.setText(itr.next());
	        if (i%2 == 0) {
		        LinearLayout.LayoutParams llp = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
		        llp.setMargins(50, 50, 50, 50);
		        mesraTV.setLayoutParams(llp);
	        }
	        mesraTV.setPadding(4,2,4,2);
	        tableLayout.addView(mesraTV);
		}
		
		tableLayout.setLayoutParams(new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
		scrollView.addView(tableLayout);
		
		Log.d("HorizontalPager", "draw ghazal end");
		return scrollView;
	}
	
	private void openDB() {
		myDbHelper = new DataBaseHelper(this);
		try {
			myDbHelper.createDataBase();
		} catch (IOException ioe) {
			throw new Error("Unable to create database");
		}

		try {
			myDbHelper.openDataBase();
		}catch(SQLException sqle){
			throw sqle;		
		}
	}
	
	public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.ghazal_layout);
        tracker = GoogleAnalyticsTracker.getInstance();
        
        openDB();
        ghazal_count = myDbHelper.getGhazalCount(); 

//        realViewSwitcher = new HorizontalPager(getApplicationContext());
        realViewSwitcher = (HorizontalPager) findViewById(R.id.horizPager);

//		LinearLayout linearLayout = (LinearLayout)findViewById(R.id.page);

		ghazal_number = 0;
		setViewToGhazal(0);
		
//		linearLayout.addView(realViewSwitcher);
//		setContentView(realViewSwitcher);
		 
		realViewSwitcher.setOnScreenSwitchListener(onScreenSwitchListener);

        initAds();
    }
	
	public void setViewToGhazal(int i) {
    	realViewSwitcher.removeAllViews();
//		realViewSwitcher.addView(drawGhazal( (i + ghazal_count - 1) % ghazal_count));
		realViewSwitcher.addView(drawGhazal(i));
		realViewSwitcher.addView(drawGhazal((1+i) % ghazal_count));
		realViewSwitcher.setCurrentScreen(0, false);
		m_screen = 0;
		
        tracker.trackPageView("/android/Ghazal" + i);
		Log.d("GhazalActivity", "/android/Ghazal" + i);
	}
	
    public void setRandom() {
    	Random r=new Random();
    	int i1 = (r.nextInt(ghazal_count) + 0);
    	
    	setViewToGhazal(i1);
    }
	
	private void scrollLeft() {
//	    int next_number = ((ghazal_count+ghazal_number-1)%ghazal_count);
//		Log.d("HorizontalPager", "ghazal_number: " + ghazal_number);
//		realViewSwitcher.addView(drawGhazal(next_number),0);
//
//	    realViewSwitcher.removeViewAt(2);
//		realViewSwitcher.setCurrentScreen(1, false);

//		Log.d("/android/Ghazal" + ghazal_number);
//        tracker.trackPageView("/android/Ghazal" + ghazal_number);
	}

	private void scrollRight() {
//
		if (realViewSwitcher.getChildCount() < ghazal_count) {
			int next_number= ((ghazal_count+ghazal_number+1)%ghazal_count);
			realViewSwitcher.addView(drawGhazal(next_number),realViewSwitcher.getChildCount());
		}


//
//		Log.d("HorizontalPager", "ghazal_number: " + ghazal_number);
//		realViewSwitcher.setCurrentScreen(1, false);
//

//		View first = realViewSwitcher.getChildAt(0);
//		View second = realViewSwitcher.getChildAt(1);
//		View third = realViewSwitcher.getChildAt(2);
//		realViewSwitcher.removeAllViews();
//		realViewSwitcher.addView(second);
//		realViewSwitcher.addView(third);
//	    realViewSwitcher.removeViewAt(0);
//		realViewSwitcher.setCurrentScreen(1, true);
//		realViewSwitcher.addView(drawGhazal(next_number),2);


		
		tracker.trackPageView("/android/Ghazal" + ghazal_number);
	}
	
	private final HorizontalPager.OnScreenSwitchListener onScreenSwitchListener =
			new HorizontalPager.OnScreenSwitchListener() {
		@Override
		public void onScreenSwitched(final int screen) {
			/*
			 * this method is executed if a screen has been activated, i.e. the screen is
			 * completely visible and the animation has stopped (might be useful for
			 * removing / adding new views)
			 */
			Log.d("HorizontalPager", "switched to screen: " + screen);
			//realViewSwitcher.remove
//			if (screen == 0) {
//				ghazal_number--;
//				scrollLeft();
//			} else if (screen == 2) {
//				ghazal_number++;
//				scrollRight();
//			}
			if (screen > m_screen) {
				ghazal_number++;
				scrollRight();
			}
			m_screen = screen;

			Log.d("GhazalActivity", "/android/Ghazal" + screen);
	        tracker.trackPageView("/android/Ghazal" + screen);
			
		}
	};	

}
