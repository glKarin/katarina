import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id: root;
	title: qsTr("News");

	QtObject{
		id: qtObj;
		property int pageNo: 1
		property int pageSize: 20;
		property int pageCount: 0;
		property int totalCount: 0;
		property string tag: "";
		property string type: "";

		function getNewsTags(){
			tagsModel.clear();
			pageNo = 1;
			pageCount = 0;
			totalCount = 0;
			var opt = {
				action: "c"
			};
			function success(jsObject){
				if(jsObject)
				{
					Script.getNewsTags(jsObject, tagsModel);
					if(tagsModel.count > 0)
					{
						getNewsList(tagsModel.get(0).type, tagsModel.get(0).tag, 1);
					}
				}
				root.indicating = false;
			}

			function fail(e){
				app.showMsg(qsTr("Get news tags fail") + " - " + e);
				root.indicating = false;
			}
			Script.callAPI("NewsTags", success, fail, opt, "GET");
			root.indicating = true;
		}

		function getNewsList(y, t, p)
		{
			if(t && y)
			{
				if(tag !== t)
				{
					pageNo = 1;
					pageCount = 0;
					totalCount = 0;
					tag = t;
					type = y;
				}
			}
			var n = pageNo;
			if(typeof(p) === "number")
			{
				n = p;
			}
			else if(p === "prev")
			{
				n--;
			}
			else if(p === "next")
			{
				n++
			}
			else
			{
				n = 1; 
			}

			if(n <= 1)
			{
				n = 1;
			}
			else if(n > pageCount)
			{
				n = pageCount;
			}
			pageNo = n;
			newsModel.clear();
			albumModel.clear();
			var opt = {
				action: "l",
				p: pageNo
			};
			if(type === "album")
			{
				opt["albumsTag"] = tag;
			}
			else
			{
				opt["newsTag"] = tag;
			}
			if(type === "album")
			{
				tabGroup.currentTab = gridView;
			}
			else
			{
				tabGroup.currentTab = listView;
			}
			function success(jsObject)
			{
				if(jsObject)
				{
					pageCount = jsObject.totalPage || 0;
					if(totalCount != jsObject.totalRecord)
					{
						totalCount = jsObject.totalRecord || 0;
						if(type === "album")
						{
							app.showMsg(qsTr("Album count") + ": " + totalCount);
						}
						else
						{
							app.showMsg(qsTr("News count") + ": " + totalCount);
						}
					}
					if(type === "album")
					{
						Script.getAlbumList(jsObject.data, albumModel);
					}
					else
					{
						Script.getNewsList(jsObject.data, newsModel);
					}
				}
				listIndicator.visible = false;
			}

			function fail(e){
				if(type === "album")
				{
					app.showMsg(qsTr("Get album list fail") + " - " + e);
				}
				else
				{
					app.showMsg(qsTr("Get news list fail") + " - " + e);
				}
				listIndicator.visible = false;
			}
			if(type === "album")
			{
				Script.callAPI("AlbumList", success, fail, opt, "GET");
			}
			else
			{
				Script.callAPI("NewsList", success, fail, opt, "GET");
			}
			listIndicator.visible = true;
		}

		function openDialog()
		{
			if(!loader.item){
				loader.sourceComponent = Qt.createComponent(Qt.resolvedUrl("InputDialog.qml"));
				if (loader.status === Loader.Ready){
					var item = loader.item;
					item.placeholderText = qsTr("Input page no") + "(1 - %1)".arg(qtObj.pageCount);
					item.title = qsTr("Jump to");
					item.buttonText = qsTr("Jump");
					item.enterText = qsTr("Jump");
					item.enterEnabled = qtObj.pageCount > 1;
					item.inputMethodHints = Qt.ImhDigitsOnly;
					item.validator = intValidator;
					item.accept.connect(function(res){
						qtObj.getNewsList(undefined, undefined, parseInt(res));
					});
					item.placeholderTextChanged.connect(function(){
						item.text = "";
					});
					item.open();
				}
			}else{
				loader.item.placeholderText = qsTr("Input page no") + "(1 - %1)".arg(qtObj.pageCount);
				loader.item.open();
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
					text: "<b><strong>" + model.name + "</strong></b>"; 
					color: parent.ListView.isCurrentItem ? "red" : "black";
				}
				MouseArea{
					anchors.fill: parent;
					onClicked:{
						typeRow.currentIndex = index;
						qtObj.getNewsList(model.type, model.tag);
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
			header: Component{
				PullToActivate{
					flickableItem: ListView.view;
					onRefresh:{
						qtObj.getNewsList(undefined, undefined, "this");
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
										text: model.type === "topic" ? qsTr("Topic") : (model.type === "video" ? qsTr("Video") : (model.type === "news") ? qsTr("News") : qsTr("Other"));
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
								pageStack.push(page, {topicId: model.id, topicTitle: model.title});
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

		Flickable{
			id: gridView;
			anchors.fill: parent;
			clip: true;
			contentWidth: width;
			contentHeight: flow.height;
			flickableDirection: Flickable.VerticalFlick;
			PullToActivate{
				flickableItem: gridView;
				onRefresh:{
					qtObj.getNewsList(undefined, undefined, "this");
				}
			}
			Flow{
				id: flow;
				width: parent.width;
				spacing: 4;
				Repeater{
					model: ListModel{
						id: albumModel;
					}
					delegate: Component{
						Rectangle{
							width: model.coverWidth + 20;
							height: model.coverHeight + 60;
							color: "white";
							Column{
								anchors.fill:parent;
								Image{
									id: albumImage;
									anchors.horizontalCenter: parent.horizontalCenter;
									height: model.coverHeight;
									width: model.coverWidth;
									source: model.coverUrl;
									smooth:true;
								}
								Text{
									id: albumTitle;
									width: parent.width;
									font.pixelSize: constants._NormalPixelSize;
									font.family: constants._FontFamily;
									elide: Text.ElideRight;
									text: model.title;
									clip: true;
								}
								Row{
									width: parent.width;
									height: parent.height - albumImage.height - albumTitle.height;
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
										text: model.updated;
									}
								}
							}
							MouseArea{
								anchors.fill:parent;
								onClicked:{

									var page = Qt.createComponent(Qt.resolvedUrl("GalleryDetailPage.qml"));
									pageStack.push(page, {galleryId: model.galleryId, galleryTitle: model.title});
								}
							}
						}
					}
				}
			}
		}
	}

	BusyIndicator{
		id: listIndicator;
		anchors.centerIn: tabGroup;
		visible: false;
		running: visible;
		z: 1;
		style: BusyIndicatorStyle{
			size: "small";
		}
	}

	Loader{
		id: loader;
		anchors.fill: parent;
		z:2
	}
	IntValidator{
		id: intValidator;
		top: qtObj.pageCount;
		bottom: 1;
	}

	tools: ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		ToolIcon{
			iconId: "toolbar-search";
			enabled: qtObj.pageCount > 0;
			onClicked:{
				qtObj.openDialog();
			}
		}
		Button{
			platformStyle:ButtonStyle {
				buttonWidth: buttonHeight; 
			}
			iconSource: "image://theme/icon-m-toolbar-previous";
			enabled:qtObj.pageNo > 1;
			onClicked:{
				qtObj.getNewsList(undefined, undefined, "prev");
			}
		}
		Button{
			platformStyle:ButtonStyle {
				buttonWidth: buttonHeight; 
			}
			iconSource: "image://theme/icon-m-toolbar-next";
			enabled:qtObj.pageNo < qtObj.pageCount;
			onClicked:{
				qtObj.getNewsList(undefined, undefined, "next");
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				qtObj.getNewsTags();
			}
		}
		Text{
			width: parent.width / 6;
			elide: Text.ElideRight;
			font.family: constants._FontFamily;
			font.pixelSize: constants._NormalPixelSize;
			text:qtObj.pageNo + "/" + qtObj.pageCount;
		}
	}

	Component.onCompleted:{
		qtObj.getNewsTags();
	}

	/*
	Component.onDestruction:{
		loader.sourceComponent = undefined;
	}
	*/
}

