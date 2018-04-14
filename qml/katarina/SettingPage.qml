import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id:root;
	title: qsTr("Setting");

	Flickable{
		id: flickable;
		anchors{
			top: headerBottom;
			left: parent.left;
			right: parent.right;
			bottom: parent.bottom
		}
		contentWidth: width;
		clip: true;
		contentHeight: Math.max(mainlayout.height, height);
		flickableDirection: Flickable.VerticalFlick;
		Column{
			id:mainlayout;
			width: parent.width;
			spacing: 4;
			LineText{
				style: "left";
				text: qsTr("Default Video Player");
			}
			ButtonColumn{
				width: parent.width;
				spacing:4;
				CheckBox{
					width: parent.width;
					checked: settings.defaultPlayer === "katarina";
					text: qsTr("Internal Player");
					onClicked:{
						settings.defaultPlayer = "katarina";
					}
				}
				CheckBox{
					width: parent.width;
					checked: settings.defaultPlayer === "harmattan_grob";
					text: qsTr("Harmattan Grob Browser");
					onClicked:{
						settings.defaultPlayer = "harmattan_grob";
					}
				}
				CheckBox{
					width: parent.width;
					checked: settings.defaultPlayer === "harmattan_video_suite";
					text: qsTr("Harmattan Video Suite");
					onClicked:{
						settings.defaultPlayer = "harmattan_video_suite";
					}
				}
			}
			LineText{
				style: "left";
				text: qsTr("Lock Orientation");
			}
			ButtonColumn{
				width: parent.width;
				spacing:4;
				CheckBox{
					width: parent.width;
					checked: settings.lockOrientation === "automatic";
					text: qsTr("Automatic");
					onClicked:{
						settings.lockOrientation = "automatic";
					}
				}
				CheckBox{
					width: parent.width;
					checked: settings.lockOrientation === "portrait";
					text: qsTr("Lock Portrait");
					onClicked:{
						settings.lockOrientation = "portrait";
					}
				}
				CheckBox{
					width: parent.width;
					checked: settings.lockOrientation === "landscape";
					text: qsTr("Lock Landscape");
					onClicked:{
						settings.lockOrientation = "landscape";
					}
				}
			}
			LineText{
				style: "left";
				text: qsTr("GL Model Viewer Orientation");
			}
			ButtonColumn{
				width: parent.width;
				spacing:4;
				CheckBox{
					width: parent.width;
					checked: settings.glWidgetOrientation === 0;
					text: qsTr("Landscape");
					onClicked:{
						settings.glWidgetOrientation = 0;
						qGLModelViewer.orientation = 0;
					}
				}
				CheckBox{
					width: parent.width;
					checked: settings.glWidgetOrientation === 1;
					text: qsTr("Portrait");
					onClicked:{
						settings.glWidgetOrientation = 1;
						qGLModelViewer.orientation = 1;
					}
				}
			}
		}
	}
	ScrollDecorator{
		flickableItem:flickable;
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
	}
}
