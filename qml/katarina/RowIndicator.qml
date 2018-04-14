import QtQuick 1.1

Item{
	id: root;
	property int count: 0;
	property int cellBorderWidth: 5;
	property int cellWidth: 10;
	property int currentIndex: 0;

	opacity: 0.6;
	width: count * (cellWidth + cellBorderWidth);
	height: cellWidth;
	anchors.bottomMargin: cellBorderWidth;
	anchors.rightMargin: cellBorderWidth;
	Row{
		anchors.fill: parent;
		spacing: root.cellBorderWidth;
		Repeater{
			model: root.count;
			delegate: Component{
				Rectangle{
					radius: 90;
					border.color: root.currentIndex === index ? "red" : "green";
					border.width: root.cellBorderWidth;
					color: root.currentIndex === index ? "pink" : "lightskyblue";
					smooth: true;
					width: root.cellWidth;
					height: width;
				}
			}
		}
	}
}
