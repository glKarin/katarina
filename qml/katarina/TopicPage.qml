import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id: root;
	property string topicId: "";
	property string topicTitle: "";
	title: topicTitle;

	QtObject{
		id: qtObj;
		property string privateTopicId: root.topicId;

		function getTopicDetail(){
			if(!privateTopicId || privateTopicId === "")
			{
				return;
			}
			tagsModel.clear();
			webview.url = "";
			var opt = {
				action: "topic",
				topicId: privateTopicId
			};
			function success(jsObject){
				if(jsObject)
				{
					root.topicTitle = jsObject.title || root.topicTitle;
					newsModel.clear();
					Script.getTopicDetail(jsObject.data, tagsModel);
					if(tagsModel.count > 0)
					{
						var item = tagsModel.get(0);
						if(item.type === "topic")
						{
							Script.getNewsList(item.data.news, newsModel);
							tabGroup.currentTab = listView;
						}
						else if(item.type === "web")
						{
							webview.url = item.url;
							tabGroup.currentTab = webview;
						}
					}
				}
				root.indicating = false;
			}

			function fail(e){
				app.showMsg(qsTr("Get topic detail fail") + " - " + e);
				root.indicating = false;
			}
			Script.callAPI("NewsList", success, fail, opt, "GET");
			root.indicating = true;
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
					page = Qt.createComponent(Qt.resolvedUrl("TopicPage.qml"));
					pageStack.push(page, {topicId: res["value"]});
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

	ListView{
		id: typeRow;
		anchors{
			top: headerBottom;
			left: parent.left;
			right: parent.right;
			margins: 4;
		}
		model: ListModel{
			id: tagsModel;
		}
		height: 50;
		z: 1;
		clip: true;
		visible: !root.indicating;
		orientation: ListView.Horizontal;
		spacing: 4;
		delegate: Component{
			Rectangle{
				width: 120;
				height: ListView.view.height;
				radius: 10;
				smooth: true;
				color: ListView.isCurrentItem ? "lightskyblue" : "white";
				Text{
					anchors.centerIn: parent;
					elide: Text.ElideRight;
					font.family: constants._FontFamily;
					font.pixelSize: constants._NormalPixelSize;
					clip: true;
					text: "<b><strong>" + (model.type === "topic" ? qsTr("Topic") : model.title) + "</strong></b>"; 
					color: parent.ListView.isCurrentItem ? "red" : "black";
				}
				MouseArea{
					anchors.fill: parent;
					onClicked:{
						typeRow.currentIndex = index;
						if(model.type === "topic")
						{
							Script.getNewsList(model.data.news, newsModel);
							tabGroup.currentTab = listView;
						}
						else if(model.type === "web")
						{
							webview.url = model.url;
							tabGroup.currentTab = webview;
						}
					}
				}
			}
		}
	}

	TabGroup{
		id: tabGroup;
		anchors{
			top: typeRow.bottom;
			left: parent.left;
			right: parent.right;
			bottom: parent.bottom;
			topMargin: 4; 
		}
		visible: !listIndicator.visible;
		ListView{
			id: listView;
			anchors.fill: parent;
			model: ListModel{
				id: newsModel;
			}
			delegate: Component{
				Rectangle{
					height:120;
					width: ListView.view.width;
					color: ListView.isCurrentItem ? "lightskyblue" : "white";
					Row{
						anchors.fill:parent;
						Image{
							id: image;
							height: parent.height;
							width: 160;
							source: model.photo;
							smooth:true;
						}
						Column{
							width: parent.width - image.width;
							height:parent.height;
							Text{
								width: parent.width;
								height: parent.height / 4;
								font.pixelSize: constants._NormalPixelSize;
								font.family: constants._FontFamily;
								elide: Text.ElideRight;
								text: model.title;
								clip: true;
							}
							Text{
								width: parent.width;
								height: parent.height / 2;
								font.pixelSize: constants._SmallPixelSize;
								font.family: constants._FontFamily;
								maximumLineCount: 2;
								elide: Text.ElideRight;
								text: model.content;
								clip: true;
								wrapMode: Text.WrapAnywhere;
							}
							Row{
								width: parent.width;
								height: parent.height / 4;
								Row{
									width: parent.width / 2;
									height: parent.height;
									Image{
										height: parent.height;
										width: height;
										source: Qt.resolvedUrl("../image/katarina-s-calendar.png");
										smooth: true;
									}
									Text{
										width: parent.width - parent.height;
										anchors.verticalCenter: parent.verticalCenter;
										clip:true;
										font.pixelSize: constants._SmallPixelSize;
										font.family: constants._FontFamily;
										elide: Text.ElideRight;
										text: model.time;
									}
								}
								Row{
									width: parent.width / 2;
									height: parent.height;
									Image{
										height: parent.height;
										width: height;
										source: Qt.resolvedUrl("../image/katarina-s-category.png");
										smooth: true;
									}
									Text{
										anchors.verticalCenter: parent.verticalCenter;
										width:parent.width - parent.height;
										clip:true;
										font.pixelSize: constants._SmallPixelSize;
										font.family: constants._FontFamily;
										elide: Text.ElideRight;
										text: model.type;
									}
								}
							}
						}
					}
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							listView.currentIndex = index;
							if(model.type === "topic")
							{
								var page = Qt.createComponent(Qt.resolvedUrl("TopicPage.qml"));
								pageStack.push(page, {newsId: model.id, newsTitle: model.title});
							}
							else
							{
								var page = Qt.createComponent(Qt.resolvedUrl("NewsDetailPage.qml"));
								pageStack.push(page, {newsId: model.id, newsTitle: model.title, videoList: model.videoList});
							}
						}
					}
				}
			}
			clip:true;
			spacing:2;

			ScrollDecorator{
				flickableItem:parent;
			}
		}

		WebView{
			id: webview;
			anchors{
				top: parent.top;
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
	}

	tools: ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		ToolIcon{
			visible: tabGroup.currentTab === webview;
			enabled: visible;
			iconId: "toolbar-tab-previous";
			onClicked:{
				webview.back.trigger();
			}
		}
		ToolIcon{
			visible: tabGroup.currentTab === webview;
			enabled: visible;
			iconId: "toolbar-tab-next";
			onClicked:{
				webview.forward.trigger();
			}
		}
		ToolIcon{
			visible: tabGroup.currentTab === webview;
			enabled: visible;
			iconId: webview.progress === 1.0 ? "toolbar-jump-to" : "toolbar-stop";
			onClicked:{
				if(webview.progress === 1.0){
					webview.reload.trigger();
				}else{
					webview.stop.trigger();
				}
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				qtObj.getTopicDetail();
			}
		}
	}

	Component.onCompleted:{
		qtObj.getTopicDetail();
	}
}


