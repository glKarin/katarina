import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id:root;
	property string galleryId: "";
	property string galleryTitle: "";
	title: galleryTitle;

	QtObject{
		id: qtObj;
		property string privateGalleryId: root.galleryId;
		property variant imageViewDialog: null;
		function getGalleryDetail()
		{
			if(!privateGalleryId)
			{
				return;
			}
			if(privateGalleryId === "")
			{
				return;
			}
			photoModel.clear();
			webview.url = "";
			//console.log(Script.getGalleryUrl(privateGalleryId));
			function success(html)
			{
				if(html !== ""){
					if(Script.getAlbumDetail(html, photoModel)){
						tabGroup.currentTab = pathView;
					}
					else
					{
						webview.url = Script.getGalleryUrl(privateGalleryId);
						tabGroup.currentTab = webview;
					}
				}
				root.indicating = false;
			}
			function fail(e)
			{
				app.showMsg(qsTr("Get album detail fail") + " - " + e);
				webview.url = Script.getGalleryUrl(privateGalleryId);
				tabGroup.currentTab = webview;
				root.indicating = false;
			}
			Script.callAPI(Script.getGalleryUrl(privateGalleryId), success, fail, undefined, "POST");
			root.indicating = true;
		}

		function openDialog(url)
		{
			if(!qtObj.imageViewDialog){
				var component = Qt.createComponent(Qt.resolvedUrl("ImageViewDialog.qml"));
				if(component.status == Component.Ready){
					qtObj.imageViewDialog = component.createObject(root);
					qtObj.imageViewDialog.imageUrl = url;
					qtObj.imageViewDialog.open();
				}
			}else{
				qtObj.imageViewDialog.imageUrl = url;
				qtObj.imageViewDialog.open();
			}
		}
	}

	TabGroup{
		id: tabGroup;
		anchors{
			top: headerBottom;
			left: parent.left;
			right: parent.right;
			bottom: parent.bottom;
		}
		PathView{
			id: pathView;
			anchors.fill: parent;
			clip: true;
			model: ListModel{
				id: photoModel;
			}
			path:Path{
				startX: pathView.model.count % 2 ? (- pathView.model.count * pathView.width / 2 + pathView.width) : (- pathView.model.count * pathView.width / 2 + pathView.width / 2 * 3);
				startY: pathView.height / 2;
				PathLine{
					x: pathView.model.count % 2 ? (pathView.model.count * pathView.width / 2 + pathView.width) : (pathView.model.count * pathView.width / 2 + pathView.width / 2 * 3);
					y: pathView.height / 2;
				}
			}
			delegate: Component{
				Item{
					width: PathView.view.width;
					height: PathView.view.height;
					Item{
						anchors{
							top: parent.top;
							left: parent.left;
							right: parent.right;
							bottom: photoTitle.top;
						}
						Image{
							id: photoImage;
							anchors.centerIn: parent;
							fillMode: Image.PreserveAspectFit;
							width: Math.min(parent.width, model.file_width);
							height: Math.min(model.file_height, parent.height - photoTitle.height);
							smooth: true;
							asynchronous: true;
							source: model.url;
							clip: true;
							MouseArea{
								anchors.fill: parent;
								onClicked:{
									qtObj.openDialog(model.url);
								}
							}
						}
					}
					Row{
						id: photoTitle;
						anchors{
							left: parent.left;
							right: parent.right;
							bottom: parent.bottom;
							topMargin: 4;
						}
						z: 1;
						height: 40;
						spacing: 4;
						Text{
							anchors.verticalCenter: parent.verticalCenter;
							width: parent.width - parent.spacing - commentIcon.width;
							font.family: constants._FontFamily;
							font.pixelSize: constants._NormalPixelSize;
							elide: Text.ElideMiddle;
							clip: true;
							text: model.title;
						}
						ToolIcon{
							id: commentIcon;
							height: parent.height;
							width: height;
							iconId: "toolbar-view-menu";
							onClicked:{
								webview.url = model.comment_url;
								tabGroup.currentTab = webview;
							}
						}
					}
				}
			}
		}
		WebView{
			id: webview;
			anchors.fill: parent;
			onLinkClicked:{
				url = link;
			}
			onAlert:{
				app.showMsg(message);
			}
		}
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: tabGroup.currentTab === webview && photoModel.count > 0 ? "toolbar-previous" : "toolbar-back";
			onClicked:{
				if(tabGroup.currentTab === webview && photoModel.count > 0)
				{
					tabGroup.currentTab = pathView;
				}
				else
				{
					pageStack.pop();
				}
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
				qtObj.getGalleryDetail();
			}
		}
	}

	Component.onCompleted:{
		qtObj.getGalleryDetail();
	}
}


