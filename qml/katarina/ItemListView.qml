import QtQuick 1.1
import "../js/main.js" as Script

ListView{
	id: root;
	signal openItem(string itemId);

	width: parent.width;
	spacing: 2;
	height: 80;
	orientation: ListView.Horizontal;
	clip: true;
	delegate: Component{
		Item{
			height: ListView.view.height;
			width: height;
			Image{
				anchors.centerIn: parent;
				width: 64;
				height: 64;
				smooth: true;
				source: Script.getItemPic(modelData);
			}
			MouseArea{
				anchors.fill: parent;
				onClicked:{
					root.openItem(modelData);
				}
			}
		}
	}
}
