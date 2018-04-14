import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id:root;
	title: qsTr("About");

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
				style: "middle";
				text: qsTr("Feature");
			}
			Text{
				width: parent.width;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: qsTr("1. View heroes detail, sound, skin and video.");
				wrapMode: Text.WordWrap;
			}
			Text{
				width: parent.width;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: qsTr("2. Search player, and view detail.");
				wrapMode: Text.WordWrap;
			}
			Text{
				width: parent.width;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: qsTr("3. View items.");
				wrapMode: Text.WordWrap;
			}
			Text{
				width: parent.width;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: qsTr("4. View player match detail.");
				wrapMode: Text.WordWrap;
			}
			Text{
				width: parent.width;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: qsTr("5. View news and albums.");
				wrapMode: Text.WordWrap;
			}
			Text{
				width: parent.width;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: qsTr("6. View hero 3D model animation.");
				wrapMode: Text.WordWrap;
			}
			LineText{
				style: "middle";
				text: qsTr("Update");
			}
			Text{
				width: parent.width;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: qsTr("1. Fixed download source of 3D hero's models.");
				wrapMode: Text.WordWrap;
			}
			LineText{
				style: "middle";
				text: qsTr("About");
			}
			Text{
				anchors.horizontalCenter: parent.horizontalCenter;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: "<strong><b>" + qUtility.getAppInfo("app_name") + "</b></strong>";
				wrapMode: Text.WordWrap;
			}
			Text{
				width: parent.width;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: qsTr("Same as a Lol box, base on DUOWAN API.");
				wrapMode: Text.WordWrap;
			}
			Text{
				width: parent.width;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: qsTr("3D model file by LolKing.");
				wrapMode: Text.WordWrap;
			}
			Text{
				anchors.horizontalCenter: parent.horizontalCenter;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				text: qsTr("Version") + ": " + qUtility.getAppInfo("app_version") + " - " + qUtility.getAppInfo("app_status");
				wrapMode: Text.WordWrap;
			}
			Text{
				anchors.horizontalCenter: parent.horizontalCenter;
				font.pixelSize: constants._NormalPixelSize;
				font.family: constants._FontFamily;
				wrapMode: Text.WordWrap;
				text: qUtility.getAppInfo("app_developer") + " @ " + qUtility.getAppInfo("app_time");
			}
		}
	}

	ScrollDecorator{
		flickableItem: flickable;
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

