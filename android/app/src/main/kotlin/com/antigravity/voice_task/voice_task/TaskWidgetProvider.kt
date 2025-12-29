package com.antigravity.voice_task.voice_task

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class TaskWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    // val widgetData = HomeWidgetPlugin.getData(context) // Optional: Get preferences
    val views = RemoteViews(context.packageName, R.layout.widget_layout)

    // Set up the collection
    // We attach the RemoteViewsService to the ListView
    // The intent needs to point to the Service class
    val intent = Intent(context, TaskWidgetService::class.java).apply {
        // Add a random data to ensure the intent is unique, forcing service recreation/update
        data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
    }
    
    views.setRemoteAdapter(R.id.widget_list_view, intent)
    views.setEmptyView(R.id.widget_list_view, R.id.widget_empty_view)

    appWidgetManager.updateAppWidget(appWidgetId, views)
    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list_view)
}
