import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "../js/main.js" as Script

PageStackWindow{
	id: app;
	showStatusBar: inPortrait;
	initialPage:KatarinaTouchHome{
	}

	Constants{
		id: constants;
	}

	SettingObject{
		id: settings;
	}

	InfoBanner {
		id: infoBanner; 
		topMargin: app.showStatusBar ? 50 : 0 + 10;
		leftMargin:5;
		height:text.height + 10;
	}

	function showMsg(text) 
	{
		infoBanner.text = text;
		infoBanner.show();
		console.log(text);
	}

	function isFastNetwork()
	{
		var bearerTypeName = qUtility.bearerTypeName;
		return bearerTypeName === "WLAN" || bearerTypeName === "WCDMA" || bearerTypeName === "CDMA2000";
	}

	Component.onCompleted:{
		Script.init();
	}
}
