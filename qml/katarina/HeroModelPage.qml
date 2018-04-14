import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id: root;
	title: qsTr("GL LOL Model Viewer");

	QtObject{
		id: qtObj;
		property variant skinSelectionDialog: null;
		property variant championSkins: ({});

		function getModelList()
		{
			heroesModel.clear();
			championSkins = ({});
			function success(html){
				if(html)
				{
					championSkins = Script.getModelList(html, heroesModel);
				}
				flipable.state = "front";
				root.indicating = false;
			}

			function fail(e){
				app.showMsg(qsTr("Get hero model list fail") + " - " + e);
				root.indicating = false;
			}
			Script.callAPI("LolKingModels", success, fail);
			root.indicating = true;
		}

		function openSkinSelectionDialog(name, cid)
		{
			if(!skinSelectionDialog){
				var component = Qt.createComponent(Qt.resolvedUrl("SkinSelectionDialog.qml"));
				if(component.status == Component.Ready){
					skinSelectionDialog = component.createObject(root);
					skinSelectionDialog.selectedValue.connect(function(championId, skinId){
						modelTypeButtonRow.checkedButton = modelTypeButton;
						renderAnim.checked = true;
						flipable.state = "back";
						qGLModelViewer.loadModel(championId, skinId);
					});
					var skins = championSkins[cid];
					var arr = [];
					for(var i in skins)
					{
						var item = {
							skinId: parseInt(i),
							skinName: skins[i]
						}
						arr.push(item);
					}
					skinSelectionDialog.openDialog(name, cid, arr.sort(function(a, b){
						if(a.skinId < b.skinId) return -1;
						else if(a.skinId > b.skinId) return 1;
						else return 0;
					}));
				}
			}else{
				var skins = championSkins[cid];
				var arr = [];
				for(var i in skins)
				{
					var item = {
						skinId: parseInt(i),
						skinName: skins[i]
					}
					arr.push(item);
				}
				skinSelectionDialog.openDialog(name, cid, arr.sort(function(a, b){
					if(a.skinId < b.skinId) return -1;
					else if(a.skinId > b.skinId) return 1;
					else return 0;
				}));
			}
		}

	}

	Connections{
		target: qGLModelViewer;
		onLoadMessageChanged: {
			logText.text += msg + "\n";
			flickable.contentY = flickable.contentHeight - flickable.height;
		}
	}

	Flipable{
		id: flipable;
		anchors{
			top: headerBottom;
			left: parent.left;
			right: parent.right;
			bottom:parent.bottom;
		}
		state: "front";
		visible: !root.indicating;
		transform: Rotation {
			id: rotation;
			origin: Qt.vector3d(flipable.width/2, flipable.height/2, 0);
			axis: Qt.vector3d(0, 1, 0);
			angle: 0;
		}
		states: [
			State {
				name: "back";
				PropertyChanges {
					target: rotation;
					angle: 180;
				}
			},
			State {
				name: "front";
				PropertyChanges {
					target: rotation;
					angle: 0;
				}
			}
		]
		transitions: Transition {
			RotationAnimation {
				direction: RotationAnimation.Clockwise;
			}
		}
		front: GridView{
			anchors.fill: parent;
			cellWidth: 120;
			cellHeight: 150;
			clip: true;
			model: ListModel{
				id: heroesModel;
			}
			delegate: Component{
				Item{
					width: GridView.view.cellWidth;
					height: GridView.view.cellHeight;
					Image{
						id: pic;
						anchors{
							top: parent.top;
							left: parent.left;
							right: parent.right;
							margins: 2;
						}
						height: width;
						smooth: true;
						source: Script.getLolKingHeroPic(model.id);
					}
					Text{
						anchors{
							top: pic.bottom;
							bottom: parent.bottom;
							horizontalCenter: parent.horizontalCenter;
						}
						elide: Text.ElideRight;
						clip: true;
						font.family: constants._FontFamily;
						font.pixelSize: constants._NormalPixelSize;
						textFormat: Text.RichText;
						text: model.name;
					}
					MouseArea{
						anchors.fill: parent;
						onClicked:{
							qtObj.openSkinSelectionDialog(model.name, model.id);
						}
					}
				}
			}
			ScrollDecorator{
				flickableItem: parent;
			}
		}

		back: Item{
			anchors.fill: parent;
			clip: true;
			Rectangle{
				id: logBox;
				anchors{
					top: parent.top;
					left: parent.left;
				}
				width: 480;
				height: 320;
				z: 1;
				color: "black";
				radius: 12;
				smooth: true;
				opacity: 0.9;
				state: "close";
				Flickable{
					id: flickable;
					anchors.fill: parent;
					anchors.centerIn: parent;
					anchors.margins: 4;
					contentWidth: width;
					clip: true;
					contentHeight: Math.max(logText.height, height);
					flickableDirection: Flickable.VerticalFlick;
					Text{
						id: logText;
						width: parent.width;
						wrapMode: Text.WrapAnywhere;
						color: "white";
						clip: true;
						font.family: constants._FontFamily;
						font.pixelSize: constants._NormalPixelSize;
					}
				}
				ScrollDecorator{
					flickableItem: flickable;
				}
			}
			Text{
				id: animTip;
				anchors.centerIn: listView;
				z: 2;
				clip: true;
				visible: qGLModelViewer.animationList.length === 0;
				anchors.verticalCenter: parent.verticalCenter;
				font.family: constants._FontFamily;
				font.pixelSize: constants._LargePixelSize;
				text: qsTr("Loading animation");
			}
			ListView{
				id: listView;
				visible: !animTip.visible;
				anchors{
					top: app.inPortrait ? logBox.bottom : parent.top;
					left: app.inPortrait ? parent.left : logBox.right;
					right: parent.right;
					bottom: parent.bottom;
				}
				clip: true;
				model: qGLModelViewer.animationList;
				delegate: Component{
					Item{
						width: ListView.view.width;
						height: 60;
						Rectangle{
							anchors.fill: parent;
							anchors.margins: border.width;
							radius: parent.ListView.view.currentIndex === index ? 10 : 0;
							color: parent.ListView.view.currentIndex === index ? "lightskyblue" : "white";
							Text{
								width: parent.width;
								height: 30;
								anchors.verticalCenter: parent.verticalCenter;
								clip: true;
								font.family: constants._FontFamily;
								font.pixelSize: constants._NormalPixelSize;
								text: modelData;
							}
						}
						MouseArea{
							anchors.fill: parent;
							onClicked:{
								listView.currentIndex = index;
								qGLModelViewer.loadAnim(index);
							}
						}
					}
				}
				ScrollDecorator{
					flickableItem: parent;
				}
			}
		}
	}

	tools: ToolBarLayout{
		ToolIcon{
			id: back;
			iconId: flipable.side === Flipable.Front ? "toolbar-back" : "toolbar-previous";
			onClicked:{
				if(flipable.side === Flipable.Front)
				{
					pageStack.pop();
				}
				else
				{
					flipable.state = "front";
					qGLModelViewer.close();
					qGLModelViewer.clear();
					logText.text = "";
				}
			}
		}
		ButtonRow{
			id: modelTypeButtonRow;
			visible: flipable.state === "back";
			anchors.verticalCenter: parent.verticalCenter;
			Button{
				id: modelTypeButton;
				enabled: visible; 
				checked: qGLModelViewer.renderType & 1;
				text: qsTr("Model");
				onClicked:{
					var i;
					var j;
					if(checked) i = 1;
					else i = 2;
					if(renderAnim.checked) j = 4;
					else j = 0;
					qGLModelViewer.renderType = i | j;
				}
			}
			Button{
				id: boneTypeButton;
				enabled: visible;
				checked: qGLModelViewer.renderType & 2;
				text: qsTr("Bone");
				onClicked:{
					var i;
					var j;
					if(checked) i = 2;
					else i = 1;
					if(renderAnim.checked) j = 4;
					else j = 0;
					qGLModelViewer.renderType = i | j;
				}
			}
		}
		CheckBox{
			id: renderAnim;
			anchors.verticalCenter: parent.verticalCenter;
			visible: flipable.state === "back";
			enabled: visible && qGLModelViewer.animationList.length > 0;
			checked: qGLModelViewer.renderType & 4;
			text: qsTr("Anim");
			onClicked:{
				qGLModelViewer.renderType = checked ? qGLModelViewer.renderType | 4 : qGLModelViewer.renderType ^ 4;
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			visible: flipable.state === "front";
			enabled: visible;
			onClicked:{
				qtObj.getModelList();
			}
		}
	}

	Component.onCompleted:{
		qtObj.getModelList();
	}

	/*
	 Component.onDestruction:{
	 }
	 */
}
