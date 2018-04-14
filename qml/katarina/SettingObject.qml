import QtQuick 1.1

QtObject{
	property string userName: qUtility.getSetting("user_name");
	property string userServerName: qUtility.getSetting("user_server_name");
	property string userServerId: qUtility.getSetting("user_server_id");

	property string lockOrientation: qUtility.getSetting("lock_orientation");
	property string defaultPlayer: qUtility.getSetting("default_player");
	property int glWidgetOrientation: qUtility.getSetting("gl_widget_orientation");

	onUserNameChanged:{
		qUtility.setSetting("user_name", userName);
	}
	onUserServerNameChanged:{
		qUtility.setSetting("user_server_name", userServerName);
	}
	onUserServerIdChanged:{
		qUtility.setSetting("user_name_id", userServerId);
	}
	onLockOrientationChanged:{
		qUtility.setSetting("lock_orientation", lockOrientation);
	}
	onDefaultPlayerChanged:{
		qUtility.setSetting("default_player", defaultPlayer);
	}
	onGlWidgetOrientationChanged:{
		qUtility.setSetting("gl_widget_orientation", glWidgetOrientation);
	}

}
