import QtQuick 1.1
import com.nokia.meego 1.1

TextField{
	id: root;
	property alias enterText: sip.actionKeyLabel;
	property alias enterEnabled: sip.actionKeyEnabled;
	signal returnPressed();

	height: 50;
	width: parent.width;
	inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase;
	platformStyle: TextFieldStyle {
		paddingRight: clear.width;
	}
	platformSipAttributes:SipAttributes {
		id: sip;
		actionKeyHighlighted: actionKeyEnabled;
	}
	Keys.onReturnPressed:{
		root.returnPressed();
		root.platformCloseSoftwareInputPanel();
	}
	ToolIcon{
		id: clear;
		width: 45;
		anchors.right: parent.right;
		anchors.verticalCenter: parent.verticalCenter;
		enabled: root.text !== "";
		visible: enabled;
		z: 2;
		iconSource: Qt.resolvedUrl("../image/katarina-s-clear.png");
		onClicked: {
			root.text = "";
			root.forceActiveFocus();
			root.platformOpenSoftwareInputPanel();
		}
	}
}
