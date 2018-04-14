import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaDialog {
	id: root

	property string vid: "";
	signal openVideoUrl(string url, string task_name, string task_value);

	headTitle: qsTr("Stream types");
	anchors.fill: parent;

	QtObject{
		id: qtObj;
		property string privateVid: root.vid;

		function getVideoStream()
		{
			if(!privateVid || privateVid === "")
				return;
			streamtypesItem.streamModel.clear();
			var opt = {
				action: "f",
				vid: privateVid
			};
			function success(jsObject)
			{
				if(jsObject)
				{
					if(jsObject.message === "success")
					Script.getVideoStream(jsObject.result, streamtypesItem.streamModel, true);
				}
				indicating = false;
			}

			function fail(e)
			{
				app.showMsg(qsTr("Get video detail fail") + " - " + e);
				indicating = false;
			}
			Script.callAPI("VideoDetail", success, fail, opt, "GET");
			indicating = true;
		}

	}

	content: StreamtypesItem {
		id: streamtypesItem;
		width: parent.width;
		height: 300;
		onOpenUrl:{
			root.openVideoUrl(url, task_name, task_value);
			root.close();
		}
	}

	function getVideoStream(id){
		vid = id;
		qtObj.getVideoStream();
	}

}
