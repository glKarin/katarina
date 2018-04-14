import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script
import "../js/utility.js" as Utility

KatarinaPage{
	id:root;
	property string playerName: "";
	property string serverId: null;
	title: playerName;

	QtObject{
		id: qtObj;
		property string privatePlayerName: root.playerName;
		property string privateServerId: root.serverId;
		function getMatchInfo()
		{
			if(!privatePlayerName || !privateServerId)
			{
				return;
			}
			if(privatePlayerName === "" || privateServerId === "")
			{
				return;
			}
			var opt = {
				lolboxAction: "toPlayerDetail",
				pn: privatePlayerName,
				sn: privateServerId,
				sk: "",
				v: 300,
				timastamp: new Date().getTime()
			};
			webview.url = Script.getAPI("PlayerMatchInfo", opt);
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
					break;
					case "toHeroDetail":
					page = Qt.createComponent(Qt.resolvedUrl("HeroDetailPage.qml"));
					pageStack.push(page, {enName: res["value"]});
					break;
					case "toZBDetail":
					page = Qt.createComponent(Qt.resolvedUrl("ItemDetailPage.qml"));
					pageStack.push(page, {itemId: res["value"]});
					break;
					case "toNewsTopic":
					break;
					default:
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
	}

	Component.onCompleted:{
		qtObj.getMatchInfo();
	}
}

