import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id: root;
	title: qsTr("Items");

	QtObject{
		id: qtObj;
		property variant items: null;
		property string type: "all";
		property string keyword: "";

		function getItems(t){
			if(t !== undefined)
			{
				type = t;
			}
			itemsModel.clear();
			items = null;
			keyword = "";
			textField.text = "";
			var opt = {
				tag: type
			};
			function success(jsObject){
				if(jsObject)
				{
					items = Script.getItems(jsObject);
					if(items)
					{
						filterItems();
					}
				}
				root.indicating = false;
			}

			function fail(e){
				app.showMsg(qsTr("Get item list fail") + " - " + e);
				root.indicating = false;
			}
			Script.callAPI("Items", success, fail, opt, "GET");
			root.indicating = true;
		}

		function filterItems()
		{
			if(!items && !Array.isArray(items))
			{
				return;
			}
			String.prototype.contains = function(str){
				return this.indexOf(str) > -1;
			}
			itemsModel.clear();
			for(var i = 0; i < items.length; i++)
			{
				var e = items[i];
				if(!e.text.contains(keyword))
				{
					continue;
				}
				itemsModel.append(e);
			}
		}

		function filter(value)
		{
			if(!value)
			{
				return;
			}
			keyword = value;
			filterItems();
		}

	}

	ListView{
		id: typeRow;
		anchors{
			top: headerBottom;
			left: parent.left;
			right: parent.right;
			margins: 4;
		}
		height: 50;
		z: 1;
		clip: true;
		model: constants._ItemTypeModel;
		orientation: ListView.Horizontal;
		spacing: 4;
		delegate: Component{
			Rectangle{
				width: 120;
				height: ListView.view.height;
				radius: 10;
				smooth: true;
				color: ListView.isCurrentItem ? "lightskyblue" : "white";
				Text{
					anchors.centerIn: parent;
					elide: Text.ElideRight;
					font.family: constants._FontFamily;
					font.pixelSize: constants._NormalPixelSize;
					clip: true;
					text: "<b><strong>" + model.name + "</strong></b>"; 
					color: parent.ListView.isCurrentItem ? "red" : "black";
				}
				MouseArea{
					anchors.fill: parent;
					onClicked:{
						typeRow.currentIndex = index;
						qtObj.getItems(model.value);
					}
				}
			}
		}

	}

	Row{
		id: searchRow;
		anchors{
			top: typeRow.bottom;
			left: parent.left;
			right: parent.right;
		}
		height: 50;
		z: 1;
		spacing: 4;
		KatarinaTextField{
			id: textField;
			height: parent.height;
			width: parent.width - parent.spacing - search.width;
			placeholderText:qsTr("Input item name");
			enterEnabled: qtObj.item !== null && Array.isArray(qtObj.items);
			enterText: qsTr("Search");
			onReturnPressed:{
				search.focus = true;
				search.clicked();
			}
		}
		SearchButton{
			id: search;
			enabled: qtObj.items !== null && Array.isArray(qtObj.items);
			onClicked:{
				if(textField.text !== qtObj.keyword) {
					qtObj.filter(textField.text);
				}
			}
		}
	}

	GridView{
		anchors{
			top: searchRow.bottom;
			left: parent.left;
			right: parent.right;
			bottom:parent.bottom;
		}
		cellWidth: 120;
		cellHeight: 150;
		clip: true;
		visible: !root.indicating;
		model: ListModel{
			id: itemsModel;
		}
		delegate: Component{
			Item{
				width: GridView.view.cellWidth;
				height: GridView.view.cellHeight;
				Image{
					id: pic;
					anchors{
						top: parent.top;
						left: parent.left;
						right: parent.right;
						margins: 2;
					}
					height: width;
					smooth: true;
					source: Script.getItemPic(model.id);
				}
				Text{
					anchors{
						top: pic.bottom;
						bottom: parent.bottom;
						horizontalCenter: parent.horizontalCenter;
					}
					elide: Text.ElideRight;
					clip: true;
					font.family: constants._FontFamily;
					font.pixelSize: constants._SmallPixelSize;
					text: model.text;
				}
				MouseArea{
					anchors.fill: parent;
					onClicked:{
						var page = Qt.createComponent(Qt.resolvedUrl("ItemDetailPage.qml"));
						pageStack.push(page, {itemName: model.text, itemId: model.id});
					}
				}
			}
		}
		ScrollDecorator{
			flickableItem: parent;
		}
	}

	tools: ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				qtObj.getItems();
			}
		}
	}

	Component.onCompleted:{
		qtObj.getItems();
	}
}
