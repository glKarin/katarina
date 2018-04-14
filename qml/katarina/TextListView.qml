import QtQuick 1.1
import com.nokia.meego 1.1

ListView{
	id: root;
	clip: true;
	spacing: 4;
	delegate:Component{
		Item{
			height: info.height;
			width: ListView.view.width;
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
	ScrollDecorator{
		flickableItem: parent;
	}

}
