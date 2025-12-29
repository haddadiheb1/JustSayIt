package com.antigravity.voice_task.voice_task

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import android.graphics.Color
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

class TaskWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TaskListFactory(this.applicationContext)
    }
}

class TaskListFactory(val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var tasks = JSONArray()

    override fun onCreate() {
        // Init
    }

    override fun onDataSetChanged() {
        val widgetData = HomeWidgetPlugin.getData(context)
        val jsonStr = widgetData.getString("tasks_json", "[]")
        tasks = try {
            JSONArray(jsonStr)
        } catch (e: Exception) {
            JSONArray()
        }
    }

    override fun onDestroy() {
        // Close data source
    }

    override fun getCount(): Int {
        return tasks.length()
    }

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_item)
        try {
            val task = tasks.getJSONObject(position)
            views.setTextViewText(R.id.item_task_title, task.getString("title"))
            views.setTextViewText(R.id.item_task_time, task.optString("time", ""))
            
            // Handle Priority Color
            // Assuming priority is passed as hex color string "#RRGGBB" or int
            // Let's assume passed as String hex
            val colorStr = task.optString("color", "#2196F3")
            try {
                views.setInt(R.id.item_priority_indicator, "setBackgroundColor", Color.parseColor(colorStr))
            } catch (e: Exception) {
                // Ignore color parse error
            }

            // Fill-in intent if we want click on item to open app
            val fillInIntent = Intent()
            // You can put extras here
            views.setOnClickFillInIntent(R.id.item_task_title, fillInIntent)

        } catch (e: Exception) {
             e.printStackTrace()
        }
        return views
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}
