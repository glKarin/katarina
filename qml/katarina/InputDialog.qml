import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root

	property real inputHeight: 160;
	property real inputWidth: 400;
	property alias placeholderText: textfield.placeholderText;
	property string title: "";
	property alias buttonText: button.text;
	property alias text: textfield.text;
	property alias enterText: textfield.enterText;
	property alias enterEnabled: textfield.enterEnabled;
	property alias inputMethodHints: textfield.inputMethodHints;
	property alias validator: textfield.validator;
	property int animationTime: 600;
	signal accept(string res);
	anchors.fill: parent;
	z: 1;
	visible: input.height !== 0 || input.width !== 0;

	function open()
	{
		input.state = "open";
	}

	function close()
	{
		input.state = "close";
	}

	MouseArea{
		anchors.fill: parent;
		onClicked:{
			root.close();
		}
	}

	Rectangle{
		id: input;
		anchors.centerIn: parent;
		z: 1;
		color: "black";
		radius: 12;
		smooth: true;
		opacity: 0.9;
		state: "close";
		Column{
			spacing: 10;
			anchors.fill: parent;
			Text{
				id: label;
				anchors.horizontalCenter: parent.horizontalCenter;
				font.family: constants._FontFamily;
				font.pixelSize: constants._NormalPixelSize;
				color: "white";
				clip: true;
				text: "<b><strong>" + root.title + "</strong></b>"
			}
			KatarinaTextField{
				id: textfield;
				anchors.horizontalCenter: parent.horizontalCenter;
				height: 50;
				clip: true;
				width: parent.width - 10;
				onReturnPressed:{
					button.focus = true;
					button.clicked();
				}
			}
			Button{
				id: button;
				anchors.horizontalCenter: parent.horizontalCenter;
				clip: true;
				visible: input.height === root.inputHeight;
				onClicked:{
					root.close();
					root.accept(textfield.text);
				}
			}
		}
		states:[
			State{
				name: "open";
				PropertyChanges {
					target: input;
					height: root.inputHeight;
					width: root.inputWidth;
				}
			}
			,
			State{
				name: "close";
				PropertyChanges {
					target: input;
					height: 0;
					width: 0;
				}
			}
		]
		transitions: [
			Transition {
				from: "close";
				to: "open";
				ParallelAnimation{
					NumberAnimation{
						target: input;
						property: "height";
						duration: root.animationTime;
						easing.type: Easing.OutExpo;
					}
					NumberAnimation{
						target: input;
						property: "width";
						duration: root.animationTime;
						easing.type: Easing.OutExpo;
					}
				}
			}
			,
			Transition {
				from: "open";
				to: "close";
				ParallelAnimation{
					NumberAnimation{
						target: input;
						property: "height";
						duration: root.animationTime;
						easing.type: Easing.InExpo;
					}
					NumberAnimation{
						target: input;
						property: "width";
						duration: root.animationTime;
						easing.type: Easing.InExpo;
					}
				}
			}
		]
	}

	/*
	Component.onDestruction:{
		console.log("destrucrion");
	}
	*/
}
