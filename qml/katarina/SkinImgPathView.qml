import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	property variant model: ListModel{}
	signal clickSkinImg(int index);

	ToolIcon{
		id: toolIcon;
		anchors{
			top: parent.top;
			left: parent.left;
		}
		width: 48;
		height: width;
		z: 2;
		opacity: 0.5;
		iconId: "toolbar-up";
		onClicked:{
			flipable.state = (flipable.side === Flipable.Front ? "back" : "front");
		}
		state: flipable.side === Flipable.Front ? "out" : "in";
		transform: Rotation {
			id: toolIconRotation;
			origin: Qt.vector3d(toolIcon.width / 2, toolIcon.height / 2, 0);
			axis: Qt.vector3d(0, 0, 1);
			angle: 0;
		}
		states: [
			State{
				name: "in";
				PropertyChanges {
					target: toolIconRotation;
					angle: 135;
				}
			},
			State{
				name: "out";
				PropertyChanges {
					target: toolIconRotation;
					angle: -45;
				}
			}
		]
		transitions: Transition {
			RotationAnimation {
				direction: RotationAnimation.Clockwise;
			}
		}
	}

	Flipable{
		id: flipable;
		anchors.fill: parent;
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

		front: PathView{
			id: bigPathView;
			anchors.fill: parent;
			clip: true;
			model: root.model;
			path:Path{
				startX: bigPathView.model.count % 2 ? (- bigPathView.model.count * bigPathView.width / 2 + bigPathView.width) : (- bigPathView.model.count * bigPathView.width / 2 + bigPathView.width / 2 * 3);
				startY: bigPathView.height / 2;
				PathLine{
					x: bigPathView.model.count % 2 ? (bigPathView.model.count * bigPathView.width / 2 + bigPathView.width) : (bigPathView.model.count * bigPathView.width / 2 + bigPathView.width / 2 * 3);
					y: bigPathView.height / 2;
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
						source: model.bigImg;
						Text{
							anchors{
								top: parent.top;
								horizontalCenter: parent.horizontalCenter;
								topMargin: 4;
							}
							color: "blue";
							font.family: constants._FontFamily;
							font.pixelSize: constants._NormalPixelSize;
							text: "<b><strong>" + model.name + "</strong></b>";
							opacity: 0.6;
						}
					}
					MouseArea{
						anchors.fill: parent;
						onClicked:{
							root.clickSkinImg(index);
						}
					}
				}
			}
		}

		back: PathView{
			id: smallPathView;
			anchors.fill: parent;
			model: root.model;
			clip: true;
			path:Path{
				startX: smallPathView.model.count % 2 ? (- smallPathView.model.count * smallPathView.height * 0.6 / 2 + smallPathView.height * 0.6) : (- smallPathView.model.count * smallPathView.height * 0.6 / 2 + smallPathView.height * 0.6 / 2 * 3);
				startY: smallPathView.height / 2;
				PathLine{
					x: smallPathView.model.count % 2 ? (smallPathView.model.count * smallPathView.height * 0.6 / 2 + smallPathView.height * 0.6) : (smallPathView.model.count * smallPathView.height * 0.6 / 2 + smallPathView.height * 0.6 / 2 * 3);
					y: smallPathView.height / 2;
				}
			}
			delegate: Component{
				Item{
					width: height * 0.6;
					height: PathView.view.height;
					Image{
						anchors.fill: parent;
						smooth: true;
						source: model.smallImg;
						asynchronous: true;
						clip: true;
					}
					MouseArea{
						anchors.fill: parent;
						onClicked:{
							root.clickSkinImg(index);
						}
					}
				}
			}
		}

		onStateChanged:{
			timer.restart();
		}
	}

	RowIndicator{
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		z:2;
		count: root.model.count;
		currentIndex: flipable.side === Flipable.Front ? bigPathView.currentIndex : smallPathView.currentIndex;
	}

	Timer{
		id: timer;
		running: root.visible && root.model.count > 1 && (!bigPathView.moving || !smallPathView.moving);
		interval: 3000;
		repeat: true;
		onTriggered:{
			if(flipable.side === Flipable.Front)
				bigPathView.incrementCurrentIndex();
			else
				smallPathView.incrementCurrentIndex();
		}
	}
}
