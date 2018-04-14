import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id: root;
	property string enName: null;
	property string cnName: null;
	title: (cnName || enName) + " " + qsTr("Video");

	QtObject{
		id: qtObj;
		property int pageNo: 1
		property int pageSize: 20;
		property int pageCount: 0;
		property int totalCount: 0;
		property string privateEnName: root.enName;

		function getHeroVideos(opt)
		{
			if(!privateEnName && privateEnName === "")
				return;
			videoModel.clear();
			if(opt === "prev" && pageNo > 1)
				pageNo --;
			if(opt === "next" && pageNo < pageCount)
				pageNo++;
			var o = {
				src: "duowan",
				action: "l",
				heroEnName: privateEnName,
				tag: privateEnName,
				p: pageNo,
				withCategory: 1
			};
			function success(jsObject)
			{
				if(jsObject)
				pageCount = Script.getHeroVideos(jsObject.data, videoModel);
				root.indicating = false;
			}

			function fail(e)
			{
				app.showMsg(qsTr("Get hero video fail") + " - " + e);
				root.indicating = false;
			}
			Script.callAPI("HeroVideos", success, fail, o, "GET");
			root.indicating = true;
		}

	}

	StreamtypesDialog{
		id: streamtypesDialog;
		anchors.fill: parent;
		onOpenVideoUrl:{
		if(!url || url === "")
			return;
			console.log(url);
			app.showMsg(qsTr("Playing video") + ": " + "%1 [%2 - %3P]".arg(videoModel.get(listView.currentIndex).title).arg(task_name).arg(task_value))
		if(settings.defaultPlayer === "harmattan_grob")
			qUtility.openHarmattanGrob(url);
		else if(settings.defaultPlayer === "harmattan_video_suite")
			qUtility.openHarmattanVideoSuite(url);
		}
	}

	ListView{
		id: listView;
		anchors{
			top: headerBottom;
			left: parent.left;
			right: parent.right;
			bottom: parent.bottom;
		}
		visible: !root.indicating;
		model: ListModel{
			id: videoModel;
		}
		header: Component{
			PullToActivate{
				flickableItem: ListView.view;
				onRefresh:{
					qtObj.getHeroVideos("this");
				}
			}
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
						source: model.cover_url;
						smooth:true;
					}
					Column{
						width: parent.width - image.width;
						height:parent.height;
						Text{
							width: parent.width;
							height: parent.height / 4 * 3;
							font.pixelSize: constants._NormalPixelSize;
							font.family: constants._FontFamily;
							maximumLineCount: 3;
							elide: Text.ElideRight;
							text: model.title;
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
									text: model.upload_time.split(" ")[0];
								}
							}
							Row{
								width: parent.width / 2;
								height: parent.height;
								Image{
									height: parent.height;
									width: height;
									source: Qt.resolvedUrl("../image/katarina-s-play.png");
									smooth: true;
								}
								Text{
									anchors.verticalCenter: parent.verticalCenter;
									width:parent.width - parent.height;
									clip:true;
									font.pixelSize: constants._SmallPixelSize;
									font.family: constants._FontFamily;
									elide: Text.ElideRight;
									text: model.play_count;
								}
							}
						}
					}
				}
				MouseArea{
					anchors.fill:parent;
					onClicked:{
						listView.currentIndex = index;
						if(settings.defaultPlayer === "katarina")
						{
							var page = Qt.createComponent(Qt.resolvedUrl("PlayerPage.qml"));
							pageStack.push(page, {vid: model.vid, videoTitle: model.title}, true);
						}
						else
						{
							if(model.vid !== "")
							{
								streamtypesDialog.open();
								streamtypesDialog.getVideoStream(model.vid);
							}
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

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		Button{
			platformStyle:ButtonStyle {
				buttonWidth: buttonHeight; 
			}
			iconSource: "image://theme/icon-m-toolbar-previous";
			enabled:qtObj.pageNo > 1;
			onClicked:{
				qtObj.getHeroVideos("prev");
			}
		}
		Button{
			platformStyle:ButtonStyle {
				buttonWidth: buttonHeight; 
			}
			iconSource: "image://theme/icon-m-toolbar-next";
			enabled:qtObj.pageNo < qtObj.pageCount;
			onClicked:{
				qtObj.getHeroVideos("next");
			}
		}
		Text{
			width: parent.width / 5;
			elide: Text.ElideRight;
			font.family: constants._FontFamily;
			font.pixelSize: constants._NormalPixelSize;
			text:qtObj.pageNo + "/" + qtObj.pageCount;
		}
	}
	Component.onCompleted:{
		qtObj.getHeroVideos();
	}

	/*
	 Component.onDestruction:{
	 }
	 */
}
