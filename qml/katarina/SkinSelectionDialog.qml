import QtQuick 1.1
import com.nokia.meego 1.1

SelectionDialog{
	id: root;
	property int corner_margins: 22;
	property string championId: "";
	signal selectedValue(string championId, string skinId);

	function openDialog(name, cid, arr)
	{
		if(!cid || !arr)
		{
			return;
		}
		titleText = "<b><strong>" + name + "</strong></b>";
		championId = cid;
		selectedIndex = -1;
		model = arr;
		open();
	}

	onAccepted:{
		if(selectedIndex >= 0 && selectedIndex < model.length)
		{
			selectedValue(championId, model[selectedIndex].skinId);
		}
	}

	delegate: Component {
		Item {
			id: delegateItem
			property bool selected: index == selectedIndex;

			height: root.platformStyle.itemHeight
			anchors.left: parent.left
			anchors.right: parent.right

			MouseArea {
				id: delegateMouseArea
				anchors.fill: parent;
				onPressed: selectedIndex = index;
				onClicked:  accept();
			}


			Rectangle {
				id: backgroundRect
				anchors.fill: parent
				color: delegateItem.selected ? root.platformStyle.itemSelectedBackgroundColor : root.platformStyle.itemBackgroundColor
			}

			BorderImage {
				id: background
				anchors.fill: parent
				border { left: corner_margins; top: corner_margins; right: corner_margins; bottom: corner_margins }
				source: delegateMouseArea.pressed ? root.platformStyle.itemPressedBackground :
				delegateItem.selected ? root.platformStyle.itemSelectedBackground :
				root.platformStyle.itemBackground
			}

			Text {
				id: itemText
				elide: Text.ElideRight
				color: delegateItem.selected ? root.platformStyle.itemSelectedTextColor : root.platformStyle.itemTextColor
				anchors.verticalCenter: delegateItem.verticalCenter
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: root.platformStyle.itemLeftMargin
				anchors.rightMargin: root.platformStyle.itemRightMargin
				text: modelData.skinId + " - " + modelData.skinName;
				font: root.platformStyle.itemFont
			}
		}
	}
}

