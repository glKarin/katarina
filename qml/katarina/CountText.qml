import QtQuick 1.1

Text{
	id: root;
	property real base: 0.0;
	property int level: 1;
	property real grow : 0.0;
	property string label: "";

	font.pixelSize: constants._NormalPixelSize;
	font.family: constants._FontFamily;
	elide: Text.ElideRight;
	text: "<b><strong>" + label + ": </strong></b>" + (grow ? (base + level * grow).toFixed(2) : base);
}
