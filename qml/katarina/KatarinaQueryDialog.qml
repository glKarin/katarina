import QtQuick 1.1
import com.nokia.meego 1.1

QueryDialog{
	id: root;
	titleText: qsTr("Worning");
	message: qsTr("Are you sure remove all history");
	acceptButtonText: qsTr("OK");
	rejectButtonText: qsTr("Cancel");
	icon: Qt.resolvedUrl("../image/katarina-l-quit.png");
}
