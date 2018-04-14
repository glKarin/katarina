import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script
import "../js/utility.js" as Utility

KatarinaPage{
	id:root;
	property string itemName: "";
	property string itemId: null;
	title: itemName;

	QtObject{
		id: qtObj;
		property string privateItemId: root.itemId;
		property variant itemDetail: null;

		function getItemInfo()
		{
			if(!privateItemId || privateItemId === "")
			return;
			var opt = {
				"id": privateItemId
			};
			needListView.model = undefined;
			composeListView.model = undefined;
			priceModel.clear();
			descriptionModel.clear();
			function success(jsObject)
			{
				if(jsObject)
				{
					itemDetail = Script.getItemInfo(jsObject);
					if(itemDetail)
					{
						getItemDetail();
						needListView.model = itemDetail.need  ? itemDetail.need.split(",") : [];
						composeListView.model = itemDetail.compose ? itemDetail.compose.split(",") : [];
						root.itemName = itemDetail.name;
					}
				}
				root.indicating = false;
			}

			function fail(e)
			{
				app.showMsg(qsTr("Get player base info fail") + " - " + e);
				root.indicating = false;
			}
			Script.callAPI("ItemDetail", success, fail, opt, "GET");
			root.indicating = true;
		}

		function getItemDetail()
		{
			priceModel.clear();
			descriptionModel.clear();
			if(itemDetail.description)
			{
				Utility.setText(descriptionModel, qsTr("Description"), itemDetail.description, true);
			}
			else
			{
				for(var i in itemDetail.extAttrs)
				{
					Utility.setText(descriptionModel, i, itemDetail.extAttrs[i]);
				}
				Utility.setText(descriptionModel, qsTr("Description"), itemDetail.extDesc, true);
			}
			Utility.setText(priceModel, qsTr("Price"), itemDetail.price, true, 0);
			Utility.setText(priceModel, qsTr("All price"), itemDetail.allPrice, true, 0);
			Utility.setText(priceModel, qsTr("Sell price"), itemDetail.sellPrice, true, 0);
		}

	}

	Image{
		id: image;
		anchors.top: headerBottom;
		anchors.horizontalCenter: parent.horizontalCenter;
		width: 64;
		height: 64;
		smooth: true;
		source: Script.getItemPic(qtObj.privateItemId);
	}

	Flickable{
		id: flickable;
		anchors{
			top: image.bottom;
			left: parent.left;
			right: parent.right;
			bottom: parent.bottom
		}
		contentWidth: width;
		clip:true;
		flickableDirection: Flickable.VerticalFlick;
		contentHeight: Math.max(height, baseColumn.height);
		visible: !root.indicating;
		Column{
			id: baseColumn;
			width: parent.width;
			spacing: 4;
			LineText{
				width: parent.width;
				visible: descriptionModel.count > 0;
				text: qsTr("Description");
			}
			TextColumn{
				width: parent.width;
				model: ListModel{
					id: descriptionModel;
				}
			}
			LineText{
				width: parent.width;
				visible: priceModel.count > 0;
				text: qsTr("Price");
			}
			TextColumn{
				width: parent.width;
				model: ListModel{
					id: priceModel;
				}
			}
			LineText{
				width: parent.width;
				text: needListView.model !== undefined && needListView.model.length > 0 ? qsTr("Need Items") : qsTr("No Need Items");
			}
			ItemListView{
				id: needListView;
				width: parent.width;
				visible: needListView.model !== undefined && needListView.model.length > 0;
				height: 80;
				onOpenItem:{
					var page = Qt.createComponent(Qt.resolvedUrl("ItemDetailPage.qml"));
					pageStack.push(page, {itemId: itemId});
				}
			}
			LineText{
				width: parent.width;
				text: composeListView.model !== undefined && composeListView.model.length > 0 ? qsTr("Compose Items") : qsTr("No Compose Items");
			}
			ItemListView{
				id: composeListView;
				width: parent.width;
				visible: composeListView.model !== undefined && composeListView.model.length > 0;
				height: 80;
				onOpenItem:{
					var page = Qt.createComponent(Qt.resolvedUrl("ItemDetailPage.qml"));
					pageStack.push(page, {itemId: itemId});
				}
			}
		}
	}
	ScrollDecorator{
		flickableItem:flickable;
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				qtObj.getItemInfo();
			}
		}
	}

	Component.onCompleted:{
		qtObj.getItemInfo();
	}
}
