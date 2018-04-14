import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id:root;
	property string newsId: "";
	property string newsTitle: "";
	property variant videoList: null;
	title: newsTitle;

	QtObject{
		id: qtObj;
		property string privateNewsId: root.newsId;
		property variant videoListDialog: null;

		function getNewsDetail()
		{
			if(!privateNewsId)
			{
				return;
			}
			if(privateNewsId === "")
			{
				return;
			}
			var opt = {
				newsId: privateNewsId,
				lolBoxAction: "toNewsDetail"
			};
			webview.url = Script.getAPI("NewsDetail", opt);
		}

		function openUrl(url, href)
		{
			var res = Script.getUnsupportUrlContent(url);
			if(res)
			{
				var page;
				switch(res["type"])
				{
					case "videoPlay":
					page = Qt.createComponent(Qt.resolvedUrl("PlayerPage.qml"));
					pageStack.push(page, {vid: res["value"], videoTitle: root.newsTitle});
					break;
					case "toHeroDetail":
					break;
					case "toZBDetail":
					break;
					case "toNewsTopic":
					break;
					default:
					app.showMsg(qsTr("Unknow unsupport url") + " - lolBoxAction: " + res.type);
					href = true;
					break;
				}
				if(!href)
				{
					webview.back.trigger();
				}
			}
			else
			{
				if(href)
				{
					webview.url = url;
				}
			}
		}
		function openDialog()
		{
			if(!root.videoList || root.videoList.count === 0)
			{
				app.showMsg("No video.");
				return;
			}
			if(!qtObj.videoListDialog){
				var component = Qt.createComponent(Qt.resolvedUrl("VideoListDialog.qml"));
				if(component.status == Component.Ready){
					qtObj.videoListDialog = component.createObject(root);
					qtObj.videoListDialog.selectedValue.connect(function(value){
						var page = Qt.createComponent(Qt.resolvedUrl("PlayerPage.qml"));
						pageStack.push(page, {vid: value, videoTitle: root.newsTitle});
					});
					qtObj.videoListDialog.openDialog(root.videoList);
				}
			}else{
				qtObj.videoListDialog.open();
			}
		}
	}

	WebView{
		id: webview;
		anchors{
			top: headerBottom;
			left: parent.left;
			right: parent.right;
			bottom: parent.bottom;
		}
		onLinkClicked:{
			qtObj.openUrl(link, true);
		}
		onAlert:{
			app.showMsg(message);
		}
		onUrlChanged: {
			qtObj.openUrl(url, false);
		}
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		ToolIcon{
			iconId: "toolbar-tab-previous";
			onClicked:{
				webview.back.trigger();
			}
		}
		ToolIcon{
			iconId: "toolbar-tab-next";
			onClicked:{
				webview.forward.trigger();
			}
		}
		ToolIcon{
			iconId: webview.progress === 1.0 ? "toolbar-refresh" : "toolbar-stop";
			onClicked:{
				if(webview.progress === 1.0){
					webview.reload.trigger();
				}else{
					webview.stop.trigger();
				}
			}
		}
		ToolIcon{
			visible: root.videoList !== null;
			enabled: visible;
			iconId: "toolbar-list";
			onClicked:{
				qtObj.openDialog();
			}
		}
	}

	Component.onCompleted:{
		qtObj.getNewsDetail();
	}
}

