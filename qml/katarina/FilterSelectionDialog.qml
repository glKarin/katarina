import QtQuick 1.1
import com.nokia.meego 1.1

SelectionDialog{
	id: root;
	property int corner_margins: 22;
	property string tag: "";
	signal selectedValue(string value);

	function openDialog(title, t, m)
	{
		if(!t || !m)
		{
			return;
		}
		titleText = title;
		tag = t;
		model = m;
		selectedIndex = -1;
		open();
	}

	onAccepted:{
		if(model && model.length)
		{
			if(selectedIndex >= 0 && selectedIndex < model.length)
			{
				selectedValue(model[selectedIndex]);
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
				text: modelData
				font: root.platformStyle.itemFont
			}
		}
	}
}
