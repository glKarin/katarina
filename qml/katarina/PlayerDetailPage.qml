import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script
import "../js/utility.js" as Utility

KatarinaPage{
	id:root;
	property string playerName: "";
	property string serverName: null;
	property string serverId: null;
	title: playerName;

	QtObject{
		id: qtObj;
		property string privatePlayerName: root.playerName;
		property string privateServerName: root.serverName;
		property string privateServerId: root.serverId;
		property variant playerInfo: null;
		property variant rankInfo: null;
		property int heroCount: 0;

		function getPlayerInfo()
		{
			if(!privatePlayerName || (!privateServerName || !privateServerId))
			return;
			if(privatePlayerName === "" || (privateServerName === "" || privateServerId === ""))
			return;
			playerInfo = null;
			rankInfo = null;
			heroCount = 0;
			var opt = {
				playerName: privatePlayerName,
				serverName: privateServerName
			};
			var argv = {
				player_name: "'" + playerName + "'",
				server_name: "'" + serverName + "'",
				server_id: "'" + serverId + "'"
			};
			Script.tbInsert("player_search_history", argv);
			playerModel.clear();
			heroModel.clear();
			getPlayerBaseInfo();
			getPlayerRankInfo();
			function success(jsObject)
			{
				if(jsObject)
				{
					playerInfo = Script.getPlayerBaseInfo(jsObject);
					if(playerInfo)
					{
						getPlayerBaseInfo(playerInfo);
						if(playerInfo.level == 30)
						{
							var opt2 = {
								playerName: privatePlayerName,
								serverName: privateServerId
							};
							function success2(jsObject2)
							{
								if(jsObject2)
								{
									rankInfo = Script.getPlayerRankInfo(jsObject2);
									getPlayerRankInfo(rankInfo);
								}
							}
							function fail2(e)
							{
								app.showMsg(qsTr("Get player rank info fail") + " - " + e);
							}
							Script.callAPI("PlayerRankInfo", success2, fail2, opt2, "GET");
						}
						getPlayerHeroes();
					}
				}
				root.indicating = false;
			}

			function fail(e)
			{
				app.showMsg(qsTr("Get player base info fail") + " - " + e);
				root.indicating = false;
			}
			Script.tbQSelect("player_search_history", playerModel, true);
			Script.callAPI("PlayerBaseInfo", success, fail, opt, "GET");
			root.indicating = true;
		}
		function getPlayerHeroes()
		{
			subIndicator.visible = true;
			heroModel.clear();
			var opt = {
				_do: "personal/championslist",
				playerName: privatePlayerName,
				serverName: privateServerName
			};
			function success(jsObject)
			{
				if(jsObject)
				{
					heroCount = jsObject.championsNum || 0;
					Script.getPlayerHeroes(jsObject.content, heroModel);
					listView.currentIndex = -1;
				}
				subIndicator.visible = false;
			}
			function fail(e)
			{
				app.showMsg(qsTr("Get player hero fail") + " - " + e);
				subIndicator.visible = false;
			}
			Script.callAPI("PlayerAllHeroes", success, fail, opt, "GET");
		}

		function getPlayerBaseInfo(baseInfo)
		{
			baseModel.clear();
			avator.source = baseInfo ? baseInfo.portrait : "";
			Utility.setText(baseModel, qsTr("Level"), baseInfo ? baseInfo.level : "", true);
			Utility.setText(baseModel, qsTr("Ability"), baseInfo ? baseInfo.zhandouli : "", true);
			Utility.setText(baseModel, qsTr("Good"), baseInfo ? baseInfo.good : "", true);
		}

		function getPlayerRankInfo(rankInfo)
		{
			rankModel.clear();
			Utility.setText(rankModel, qsTr("Rank"), rankInfo ? rankInfo.tier + (rankInfo.rank ? rankInfo.rank : "") : "");
			Utility.setText(rankModel, qsTr("League point"), rankInfo ? rankInfo.league_points : "");
		}
	}

	Column{
		id: baseColumn;
		anchors{
			top: headerBottom;
			left: parent.left;
		}
		spacing: 4;
		visible: !root.indicating;
		width: 480;
		Column{
			width: parent.width;
			visible: baseModel.count > 0;
			LineText{
				width: parent.width;
				text: qsTr("Base Info");
			}
			Row{
				width: parent.width;
				height: subColumn.height;
				spacing: 5;
				Item{
					id: image;
					width: 160;
					height: subColumn.height;
					Image{
						id: avator;
						anchors.centerIn: parent;
						width: 64;
						height: 64;
						smooth: true;
					}
				}
				TextColumn{
					id: subColumn;
					width: parent.width - image.width - parent.spacing;
					model: ListModel{
						id: baseModel;
					}
				}
			}
			LineText{
				width: parent.width;
				text: rankModel.count > 0 ? qsTr("Rank Info") : qsTr("No Rank Info");
			}
			TextColumn{
				width: parent.width;
				model: ListModel{
					id: rankModel;
				}
			}
		}
	}
	Column{
		id: heroColumn;
		anchors{
			top: app.inPortrait ? baseColumn.bottom : headerBottom;
			left: app.inPortrait ? parent.left : baseColumn.right;
			right: parent.right;
			bottom: parent.bottom;
		}
		visible: !root.indicating && !subIndicator.visible;
		LineText{
			id: heroTitle;
			width: parent.width;
			text: qsTr("Hero") + " [" + qtObj.heroCount + "]";
		}
		ListView{
			id: listView;
			width: parent.width;
			height: parent.height - heroTitle.height;
			header: PullToActivate{
				flickableItem: ListView.view;
				onRefresh:{
					qtObj.getPlayerHeroes();
				}
			}
			model: ListModel{
				id: heroModel;
			}
			spacing: 4;
			clip: true;
			delegate: Component{
				Rectangle{
					id: delegate;
					width: ListView.view.width;
					state: ListView.isCurrentItem ? "full" : "normal";
					color: ListView.isCurrentItem ? "lightskyblue" : "white";
					border.width: ListView.isCurrentItem ? 1 : 0;
					border.color: "lightseagreen";
					states: [
						State{
							name: "full";
							PropertyChanges {
								target: delegate;
								height: 200;
							}
						}
						,
						State{
							name: "normal";
							PropertyChanges {
								target: delegate;
								height: 110;
							}
						}
					]
					transitions: [
						Transition {
							from: "normal";
							to: "full";
							NumberAnimation{
								target: delegate;
								property: "height";
								duration: 400;
								easing.type: Easing.OutExpo;
							}
						}
						,
						Transition {
							from: "full";
							to: "normal";
							NumberAnimation{
								target: delegate;
								property: "height";
								duration: 110;
								easing.type: Easing.InExpo;
							}
						}
					]
					Column{
						anchors.fill: parent;
						Row{
							id: normalRow
							width: parent.width;
							height: 100;
							Image{
								id: image;
								smooth: true;
								width: height;
								height: parent.height;
								source: Script.getHeroPic(model.championName);
							}
							Column{
								width: parent.width - image.width;
								height: parent.height;
								Text{
									width: parent.width;
									height: parent.height / 3;
									font.pixelSize: constants._NormalPixelSize;
									font.family: constants._FontFamily;
									elide: Text.ElideRight;
									text: "<b><strong>" + model.championNameCN + "</strong></b>";
								}
								Text{
									width: parent.width;
									height: parent.height / 3;
									clip:true;
									font.pixelSize: constants._NormalPixelSize;
									font.family: constants._FontFamily;
									elide: Text.ElideRight;
									text: "<b><strong>" + qsTr("Win rate") + ": </strong></b>" + model.winRate + "%";
								}
								Text{
									width: parent.width;
									height: parent.height / 3;
									clip:true;
									font.pixelSize: constants._NormalPixelSize;
									font.family: constants._FontFamily;
									elide: Text.ElideRight;
									text: "<b><strong>" + qsTr("Match stat") + ": </strong></b>" + model.matchStat;
								}
							}
						}
						Column{
							width: parent.width;
							height: delegate.state === "full" ? parent.height - normalRow.height : 0;
							visible: delegate.state === "full";
							Text{
								width: parent.width;
								height: parent.height / 3;
								clip:true;
								font.pixelSize: constants._NormalPixelSize;
								font.family: constants._FontFamily;
								elide: Text.ElideRight;
								text: "<b><strong>" + qsTr("Average") + " " + qsTr("K") + ": </strong></b>" + model.averageK + " <b><strong>" + qsTr("D") + ": </strong></b>" + model.averageD + " <b><strong>" + qsTr("A") + ": </strong></b>" + model.averageA;
							}
							Text{
								width: parent.width;
								height: parent.height / 3;
								clip:true;
								font.pixelSize: constants._NormalPixelSize;
								font.family: constants._FontFamily;
								elide: Text.ElideRight;
								text: "<b><strong>" + qsTr("Average KDA Rating") + ": </strong></b>" + model.averageKDARating;
							}
							Text{
								width: parent.width;
								height: parent.height / 3;
								clip:true;
								font.pixelSize: constants._NormalPixelSize;
								font.family: constants._FontFamily;
								elide: Text.ElideRight;
								text: "<b><strong>" + qsTr("MVP") + ": </strong></b>" + model.totalMVP;
							}
						}
					}
					MouseArea{
						anchors.fill: parent;
						onClicked:{
							listView.currentIndex = index;
							var x = mouse.x;
							var y = mouse.y;
							if((x >= image.x && x <= image.x + image.width) &&
							(y >= image.y && y <= image.y + image.height))
							{
								var page = Qt.createComponent(Qt.resolvedUrl("HeroDetailPage.qml"));
								pageStack.push(page, {enName: model.championName});
							}
						}
					}
				}
			}
			ScrollDecorator{
				flickableItem: parent;
			}
		}
	}
	BusyIndicator{
		id: subIndicator;
		anchors.centerIn: heroColumn;
		z: 4;
		visible: false;
		running: visible;
	}

	tools:ToolBarLayout{
		ToolIcon{
			iconId: "toolbar-back";
			onClicked:{
				pageStack.pop();
			}
		}
		ToolIcon{
			iconId: "toolbar-list";
			onClicked:{
				var page = Qt.createComponent(Qt.resolvedUrl("PlayerMatchPage.qml"));
				pageStack.push(page, {playerName: root.playerName, serverId: root.serverId});
			}
		}
		ToolIcon{
			iconId: "toolbar-refresh";
			onClicked:{
				qtObj.getPlayerInfo();
			}
		}
	}

	Component.onCompleted:{
		qtObj.getPlayerInfo();
	}
}
