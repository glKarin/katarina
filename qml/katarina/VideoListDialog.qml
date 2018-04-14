import QtQuick 1.1
import com.nokia.meego 1.1

SelectionDialog{
	id: root;
	property int corner_margins: 22;
	titleText: qsTr("Video List");
	signal selectedValue(string value);

	function openDialog(m)
	{
		if(!m)
		{
			return;
		}
		model = m;
		selectedIndex = -1;
		open();
	}

	onAccepted:{
		if(model && model.count)
		{
			if(selectedIndex >= 0 && selectedIndex < model.count)
			{
				selectedValue(model.get(selectedIndex).vid);
			}
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
				text: model.vid
				font: root.platformStyle.itemFont
			}
		}
	}
}

