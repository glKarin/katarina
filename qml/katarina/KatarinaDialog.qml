import QtQuick 1.1
import com.nokia.meego 1.1

Dialog {
	id: root

	property alias indicating: indicator.visible;
	property alias headTitle: titletext.text;
	property alias buttonText: button.text;
	property int contentItemHeight: height - head.height - buttons.height;

	title: Rectangle {
		id:head;
		height: 60;
		width: parent.width;
		color: "black";
		z: 2;
		Column{
			anchors.fill: parent;
			Row{
				height: 55;
				width: parent.width;
				Text{
					id:titletext;
					width: parent.width - space.width - tool.width;
					anchors.verticalCenter: parent.verticalCenter;
					font.family: constants._FontFamily;
					font.pixelSize: constants._LargePixelSize;
					color: "deeppink";
				}
				Rectangle{
					id:space;
					anchors.verticalCenter: parent.verticalCenter;
					width: 2;
					height: parent.height;
					color: "white"
					radius: 2;
				}
				ToolIcon{
					id:tool;
					height: parent.height;
					width: height;
					iconId: "toolbar-close-white";
					anchors.verticalCenter: parent.verticalCenter;
					onClicked:{
						root.reject();
					}
				}
			}
			Rectangle{
				width: parent.width;
				height: 2;
				color: "white"
				radius: 2;
			}
		}
	}

	BusyIndicator{
		id:indicator;
		anchors.centerIn:parent;
		z:3;
		platformStyle:BusyIndicatorStyle{
			size:"large";
			inverted: true;
		}
		visible:false;
		running:visible;
	}

	buttons:Item{
		id: buttons;
		width: parent.width;
		height: 50;
		Button {
			id: button;
			anchors.horizontalCenter: parent.horizontalCenter
			text: qsTr("OK");
			onClicked:{
				root.accept();
			}
		}
	}
}

