import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id: root;
	title: qsTr("Heroes");

	QtObject{
		id: qtObj;
		property string type: "free";
		property variant heroes: null;
		property string price: "全部";
		property string tag: "全部";
		property string location: "全部";
		property string keyword: "";
		property variant filterDialog: null;

		function getHeroes(t){
			if(t !== undefined)
				type = t;
			if(type !== "free" && type !== "all")
				type = "free";
				heroesModel.clear();
				heroes = null;
				price = "全部";
				tag = "全部";
				location = "全部";
				keyword = "";
				textField.text = "";
			var opt = {
				type: type
			};
			function success(jsObject){
				if(jsObject)
				{
					heroes = Script.getHeroes(jsObject[type]);
					if(heroes)
					{
						filterHeroes();
					}
				}
				root.indicating = false;
			}

			function fail(e){
				app.showMsg(qsTr("Get hero list fail") + " - " + e);
				root.indicating = false;
			}
			Script.callAPI("Heroes", success, fail, opt, "GET");
			root.indicating = true;
		}

		function filterHeroes()
		{
			if(!heroes && !Array.isArray(heroes))
			{
				return;
			}
			Array.prototype.contains = function(str){
				return this.indexOf(str) > -1;
			}
			Array.prototype.match = function(re){
				for(var i = 0; i < this.length; i++)
				{
					if(this[i].match(re))
					{
						return true;
					}
				}
				return false;
			}
			String.prototype.contains = function(str){
				return this.indexOf(str) > -1;
			}
			heroesModel.clear();
			var t = Script.getEnTagName(tag);
			var k = new RegExp("^.*" + keyword + ".*$", "i");
			for(var i = 0; i < heroes.length; i++)
			{
				var e = heroes[i];
				if(tag !== "全部" && !e.tags.contains(t))
				{
					continue;
				}
				if(location !== "全部" && !e.location.contains(location))
				{
					continue;
				}
				if(price !== "全部" && !e.price.contains(price))
				{
					continue;
				}
				if(![e.enName, e.cnName, e.title].match(k))
				{
					continue;
				}
				heroesModel.append(e);
			}
		}

		function filter(name, value)
		{
			if(!name)
			{
				return;
			}
			var valid = true;
			switch(name)
			{
				case "tag":
				tag = value;
				break;
				case "location":
				location = value;
				break;
				case "price":
				price = value;
				break;
				case "keyword":
				keyword = value;
				break;
				default:
				valid = false;
				break;
			}
			if(valid)
			{
				filterHeroes();
			}
		}

		function openFilterDialog(title, t, model)
		{
			if(!filterDialog){
				var component = Qt.createComponent(Qt.resolvedUrl("FilterSelectionDialog.qml"));
				if(component.status == Component.Ready){
					filterDialog = component.createObject(root);
					filterDialog.selectedValue.connect(function(value){
						qtObj.filter(filterDialog.tag, value);
					});
					filterDialog.openDialog(title, t, model);
				}
			}else{
				filterDialog.openDialog(title, t, model);
			}
		}
	}

	ButtonRow{
		id: typeRow;
		anchors{
			top: headerBottom;
			left: parent.left;
			right: parent.right;
		}
		z: 1;
		exclusive: true;
		Button{
			width: parent.width / 2;
			text: qsTr("Free");
			onClicked:{
				qtObj.getHeroes("free");
			}
		}
		Button{
			width: parent.width / 2;
			text: qsTr("All");
			onClicked:{
				qtObj.getHeroes("all");
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
			placeholderText:qsTr("Input hero name");
			enterText: qsTr("Search");
			enterEnabled: qtObj.heroes !== null && Array.isArray(qtObj.heroes);
			onReturnPressed:{
				search.focus = true;
				search.clicked();
			}
		}
		SearchButton{
			id: search;
			enabled: qtObj.heroes !== null && Array.isArray(qtObj.heroes);
			onClicked:{
				if(textField.text !== qtObj.keyword) {
					qtObj.filter("keyword", textField.text);
				}
			}
		}
	}

	ButtonRow{
		id: filterRow;
		anchors{
			top: searchRow.bottom;
			left: parent.left;
			right: parent.right;
		}
		z: 1;
		exclusive: false;
		TabButton{
			text: qsTr("Tag") + "\n" + qtObj.tag;
			onClicked:{
				qtObj.openFilterDialog(qsTr("Tag"), "tag", constants._Tags);
			}
		}
		TabButton{
			text: qsTr("Location") + "\n" + qtObj.location;
			onClicked:{
				qtObj.openFilterDialog(qsTr("Location"), "location", constants._Location);
			}
		}
		TabButton{
			text: qsTr("Price") + "\n" + qtObj.price;
			onClicked:{
				qtObj.openFilterDialog(qsTr("Price"), "price", constants._Price);
			}
		}
	}

	GridView{
		anchors{
			top: filterRow.bottom;
			left: parent.left;
			right: parent.right;
			bottom:parent.bottom;
		}
		cellWidth: 120;
		cellHeight: 150;
		clip: true;
		visible: !root.indicating;
		model: ListModel{
			id: heroesModel;
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
					source: Script.getHeroPic(model.enName);
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
					font.pixelSize: constants._NormalPixelSize;
					text: model.cnName;
				}
				MouseArea{
					anchors.fill: parent;
					onClicked:{
						var page = Qt.createComponent(Qt.resolvedUrl("HeroDetailPage.qml"));
						pageStack.push(page, {enName: model.enName});
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
				qtObj.getHeroes();
			}
		}
	}

	Component.onCompleted:{
		qtObj.getHeroes();
	}
}
