import QtQuick 1.1
import com.nokia.meego 1.1

Item {
	id: root

	property Flickable flickableItem

	property int visualY

	property bool reloadTriggered

	property int indicatorStart: 25
	property int refreshStart: 120

	property string pullDownMessage: isHeader ? qsTr("Pull down to activate") : qsTr("Pull up to activate");
	property string releaseRefreshMessage: qsTr("Release to activate");
	property string disabledMessage: qsTr("Now loading");

	property bool platformInverted: false;
	property bool isHeader: true;

	signal refresh;

	width: parent ? parent.width : page.width
	height: 0

	Connections {
		target: flickableItem
		onContentYChanged: {
			if (isHeader){
				if (flickableItem.atYBeginning){
					var y = root.mapToItem(flickableItem, 0, 0).y
					if ( y < refreshStart + 20 )
					visualY = y
				}
			} else {
				if (flickableItem.atYEnd){
					var y = root.mapToItem(flickableItem, 0, 0).y
					if ( flickableItem.height - y < refreshStart + 20 )
					visualY = flickableItem.height - y
				}
			}
		}
	}

	Row {
		anchors {
			bottom: isHeader ? parent.top : undefined; top: isHeader ? undefined : parent.bottom
			horizontalCenter: parent.horizontalCenter
			bottomMargin: isHeader ? 5 : 0
			topMargin: isHeader ? 0 : 5
		}
		spacing: 5;
		Image {
			source: Qt.resolvedUrl("../image/katarina-m-downarrow.png");
			opacity: visualY < indicatorStart ? 0 : 1
			Behavior on opacity { NumberAnimation { duration: 100 } }
			rotation: {
				var newAngle = visualY
				if (newAngle > refreshStart && flickableItem.moving && !flickableItem.flicking){
					root.reloadTriggered = true
					return isHeader ? -180 : 0
				} else {
					newAngle = newAngle > refreshStart ? 180 : 0
					return isHeader ? -newAngle : newAngle - 180
				}
			}
			Behavior on rotation { NumberAnimation { duration: 150 } }
			onOpacityChanged: {
				if (opacity == 0 && root.reloadTriggered) {
					root.reloadTriggered = false
					if (root.enabled){
						root.refresh();
					}
				}
			}
		}
		Label {
			text: root.enabled ? reloadTriggered ? releaseRefreshMessage : pullDownMessage : disabledMessage;
		}
	}
}
