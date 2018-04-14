import QtQuick 1.1
import com.nokia.meego 1.1

Column{
	id: root;
	property alias model: repeat.model;
	width: parent.width;
	clip: true;
	spacing: 4;
	Repeater{
		id: repeat;
		delegate: Component{
			Item{
				height: info.height;
				width: root.width;
				Text{
					id: info;
					width: parent.width;
					font.pixelSize: constants._NormalPixelSize;
					font.family: constants._FontFamily;
					wrapMode: Text.WordWrap;
					text: "<b><strong>" + model.name + ": </strong></b>" + model.value;
				}
			}
		}
	}
}

