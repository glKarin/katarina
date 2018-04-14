import QtQuick 1.1
import com.nokia.meego 1.1

Page{
	id: root;
	property variant model: null;
	property int index: 0;

	QtObject{
		id: qtObj;
		property variant imageViewDialog: null;

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
	ToolIcon{
		id: toolIcon;
		anchors{
			top: parent.top;
			left: parent.left;
		}
		z: 2;
		rotation: -90;
		opacity: 0.5;
		iconId: "toolbar-up-white";
		onClicked:{
			pageStack.pop();
		}
	}

	PathView{
		id: pathView;
		anchors.fill: parent;
		clip: true;
		model: root.model;
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
				Image{
					anchors.fill: parent;
					smooth: true;
					asynchronous: true;
					clip: true;
					source: app.inPortrait ? model.smallImg : model.bigImg;
					Text{
						anchors{
							top: parent.top;
							horizontalCenter: parent.horizontalCenter;
							topMargin: 4;
						}
						color: "blue";
						font.family: constants._FontFamily;
						font.pixelSize: constants._LargePixelSize;
						text: "<b><strong>" + model.name + "</strong></b>";
						opacity: 0.6;
					}
				}
				MouseArea{
					anchors.fill: parent;
					onClicked:{
						qtObj.openDialog(model.bigImg);
					}
				}
			}
		}
	}

	RowIndicator{
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		z:2;
		count: root.model.count;
		currentIndex: pathView.currentIndex;
	}

	Component.onCompleted:{
		var i = root.model.count % 2 ? root.model.count / 2 : root.model.count / 2 + 1;
		root.index = (root.index + i) % root.model.count;
		pathView.currentIndex = root.index;
	}
}
