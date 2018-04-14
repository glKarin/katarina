import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script
import "../js/utility.js" as Utility

KatarinaPage{
	id: root;

	property string enName: null;
	title: qtObj.detail ? qtObj.detail.description.displayName : "";

	QtObject{
		id: qtObj;
		property string privateEnName: root.enName;
		property variant detail: null;

		function getHeroDetail()
		{
			if(!privateEnName || privateEnName === "")
				return;
			detail = null;
			detailTab.init();
			abilityTab.init();
			propertyTab.init();
			gameTab.init();
			skinModel.clear();
			pathView.model.clear();

			var opt = {
				heroName: privateEnName
			};
			function success(jsObject){
				if(jsObject)
				{
					detail = Script.getHeroDetail(jsObject);
					if(detail)
					{
						detailTab.init(detail.description);
						abilityTab.init(detail.ability);
						propertyTab.init(detail.prop);
						gameTab.init(detail.tips, detail.relation);
					}
				}
				root.indicating = false;
			}

			function fail(e){
				app.showMsg(qsTr("Get hero detail fail") + " - " + e);
				root.indicating = false;
			}

			function success2(jsObject){
				if(!jsObject)
				return;
				if(app.isFastNetwork())
				Script.getHeroSkin(jsObject, pathView.model);
				else
				Script.getHeroSkin([jsObject[0]], pathView.model);
				Script.getHeroSkin(jsObject, skinModel);
			}

			function fail2(e){
				app.showMsg(qsTr("Get hero skin fail") + " - " + e);
				root.indicating = false;
			}

			Script.callAPI("HeroDetail", success, fail, opt, "GET");
			var opt2 = {
				hero: privateEnName
			};
			Script.callAPI("HeroSkins", success2, fail2, opt2, "GET");
			root.indicating = true;
		}

	}

	ListModel{
		id: skinModel;
	}

	SkinImgPathView{
		id: pathView;
		width: 480;
		height: 280;
		anchors{
			top: headerBottom;
			left: parent.left;
		}
		clip: true;
		onClickSkinImg:{
			var page = Qt.createComponent(Qt.resolvedUrl("SkinImgPage.qml"));
			pageStack.push(page, {model: skinModel, index: index});
		}
	}

	ButtonRow{
		id: buttonRow;
		anchors{
			top: app.inPortrait ? pathView.bottom : headerBottom;
			left: app.inPortrait ? parent.left : pathView.right;
			right: parent.right;
		}
		TabButton{
			text: qsTr("Detail");
			tab: detailTab;
		}
		TabButton{
			text: qsTr("Ability");
			tab: abilityTab;
		}
		TabButton{
			text: qsTr("Porperty");
			tab: propertyTab;
		}
		TabButton{
			text: qsTr("Game");
			tab: gameTab;
		}
	}

	TabGroup{
		anchors{
			top: buttonRow.bottom;
			left: app.inPortrait ? parent.left : pathView.right;
			right: parent.right;
			bottom: parent.bottom;
		}
		currentTab: detailTab;

		TextListView{
			id:detailTab;
			anchors.fill: parent;
			model: ListModel{
				id: detailModel;
			}
			function init(description)
			{
				detailModel.clear();
				Utility.setText(detailModel, qsTr("Name"), description ? description.displayName : "", true); 
				Utility.setText(detailModel, qsTr("English Name"), description ? description.name : "", true);
				Utility.setText(detailModel, qsTr("Tags"), description ? description.tags : "", true); 
				Utility.setText(detailModel, qsTr("Price"), description && description.price ? qsTr("Point") + " " + description.price.split(",")[0] + " / " + qsTr("Money") + " " + description.price.split(",")[1] : "", true);
				Utility.setText(detailModel, qsTr("Description"), description && description.description ? description.description.replace(/\n/g, "<br/>") : "", true);
			}
		}

		HeroAbilityTab{
			id: abilityTab;
			anchors.fill: parent;
			enName: qtObj.privateEnName;
		}

		HeroPropertyTab{
			id: propertyTab;
			anchors.fill: parent;
		}

		HowToPlayTab{
			id: gameTab;
			anchors.fill: parent;
			onOpenHeroDetail:{
				var page = Qt.createComponent(Qt.resolvedUrl("HeroDetailPage.qml"));
				pageStack.push(page, {enName: enName});
			}
		}
	}

	Menu{
		id: menu;
		visualParent: pageStack;
		MenuLayout{
			MenuItem{
				text: qsTr("Sound");
				onClicked:{
					var page = Qt.createComponent(Qt.resolvedUrl("HeroSoundPage.qml"));
					pageStack.push(page, {enName: qtObj.privateEnName, cnName: root.title});
				}
			}
			MenuItem{
				text: qsTr("Video");
				onClicked:{
					var page = Qt.createComponent(Qt.resolvedUrl("HeroVideoPage.qml"));
					pageStack.push(page, {enName: qtObj.privateEnName, cnName: root.title});
				}
			}
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
				qtObj.getHeroDetail();
			}
		}
		ToolIcon{
			iconId: "toolbar-view-menu";
			onClicked:{
				if(menu.status == DialogStatus.Closed)
				{
					menu.open();
				}
				else
				{
					menu.close();
				}
			}
		}
	}
	Component.onCompleted:{
		qtObj.getHeroDetail();
	}
}
