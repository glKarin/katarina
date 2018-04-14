import QtQuick 1.1
import com.nokia.meego 1.1

Rectangle{
	id: root;
	property string title: "";

	height: app.inPortrait ? constants._HeaderHeight : constants._HeaderHeightLandscape;
	z: 3;
	color: constants._HeaderBGColor;
	width: parent.width;

	Image{
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.top: parent.top;
		anchors.rightMargin: -20;
		clip: true;
		smooth: true;
		//anchors.topMargin:2;
		opacity: 0.5;
		source: Qt.resolvedUrl("");
		z:2;
	}

	Text{
		anchors.centerIn: parent;
		font.pixelSize: constants._LargePixelSize;
		font.family: constants._FontFamily;
		z: 3;
		color: constants._HeaderTextColor;
		clip: true;
		elide: Text.ElideRight;
		text: root.title;
	}

}

