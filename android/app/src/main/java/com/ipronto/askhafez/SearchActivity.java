package com.ipronto.askhafez;

import java.io.IOException;
import java.util.Iterator;
import java.util.Vector;

import com.google.android.apps.analytics.GoogleAnalyticsTracker;

import android.app.Activity;
import android.database.SQLException;
import android.os.Bundle;
import android.util.Log;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.view.KeyEvent;
import android.view.View;

public class SearchActivity extends GenericActivity  {
	 EditText editText;
	 private DataBaseHelper myDbHelper;
	 private ListView listView;
	 GoogleAnalyticsTracker tracker;
	
	 public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.search_layout);

        editText = (EditText) findViewById(R.id.editText1);
        listView = (ListView) findViewById(R.id.listView1);
        
        editText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
        	@Override
        	public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
        		if (actionId == EditorInfo.IME_ACTION_SEARCH) {
        			performSearch();
        			return true;
        		}
        		return false;
        	}
        });	 
        
        openDB();

        tracker = GoogleAnalyticsTracker.getInstance();
	    tracker.trackPageView("/android/search");

         initAds();
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
	
	 
	 Vector<DataBaseHelper.MesraData> mesras;
	 
	 private void doNavigate(int id){
		 MainActivity main = (MainActivity) this.getParent();
		 main.navigateTo(id);			 
	 }
	 
	 
	 private void performSearch() {
		 Log.d("HorizontalPager", "Perform search for " + editText.getText().toString());
		 mesras = myDbHelper.searchMesras(editText.getText().toString());
		 
		 Vector<String> mesraStrings = new Vector<String>();
		 Iterator<DataBaseHelper.MesraData> itr = mesras.iterator();
		 while(itr.hasNext()) {
			 mesraStrings.add(itr.next().mesra);
		 }
		 
		 listView.setAdapter(new ArrayAdapter<String>(this, R.layout.list_mesra, mesraStrings));
		 
		 listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
			 public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				 int ghazal_id = mesras.get(position).ghazal_id;
				 doNavigate(ghazal_id);
			 }
		 });		 
	 }
}
