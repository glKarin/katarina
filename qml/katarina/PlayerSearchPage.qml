import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "../js/main.js" as Script
import "../js/utility.js" as Utility

KatarinaPage{
	id:root;

	title: qsTr("Player Search");

	QtObject{
		id:qtObj;
		property variant playerInfo: null;
		property variant rankInfo: null;
		property string playerName: "";
		property string serverId: "";
		property string serverName: "";
		property variant queryDialog: null;

		function getPlayerInfo(player_name, server_name, server_id)
		{
			if(player_name)
			{
				playerName = player_name;
			}
			if(server_name)
			{
				serverName = server_name;
			}
			if(server_id)
			{
				serverId = server_id;
			}
			if(!playerName || (!serverName || !serverId))
				return;
			if(playerName === "" || (serverName === "" || serverId === ""))
				return;
			playerInfo = null;
			playerInfo = null;
			var opt = {
				playerName: playerName,
				serverName: serverName
			};
			var argv = {
				player_name: "'" + playerName + "'",
				server_name: "'" + serverName + "'",
				server_id: "'" + serverId + "'"
			};
			Script.tbInsert("player_search_history", argv);
			playerModel.clear();
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
						flipable.state = "back";
						if(playerInfo.level == 30)
						{
							var opt2 = {
								playerName: playerName,
								serverName: serverId
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
		function getComModel()
		{
			comModel.clear();
			constants._Server.forEach(function(e){
				comModel.append({value: e.com});
			});
			comtc.selectedIndex = 0;
			getServerModel();
		}

		function getServerModel()
		{
			serverModel.clear();
			constants._Server[comtc.selectedIndex].server.forEach(function(e){
				serverModel.append({value: e.name + " " + e.id});
			});
			servertc.selectedIndex = 0;
		}

		function getPlayerBaseInfo(baseInfo)
		{
			baseModel.clear();
			more.visible = (baseInfo != null);
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

		function syncQueryComponent(player_name, server_name, server_id)
		{
			textfield.text = player_name;
			var com = server_id.substring(0, 2);
			for(var i = 0; i < comModel.count; i++){
				if(comModel.get(i).value === com)
				{
					if(comtc.selectedIndex !== i)
					{
						comtc.selectedIndex = i;
						getServerModel();
					}
					break;
				}
			}
			for(var i = 0; i < serverModel.count; i++)
			{
				if(serverModel.get(i).value === (server_name + " " + server_id))
				{
					servertc.selectedIndex = i;
					break;
				}
			}
		}
		function openDialog()
		{
			if(!qtObj.queryDialog){
				var component = Qt.createComponent(Qt.resolvedUrl("KatarinaQueryDialog.qml"));
				if(component.status == Component.Ready){
					qtObj.queryDialog = component.createObject(root);
					qtObj.queryDialog.accepted.connect(function(){
						Script.tbRemove("player_search_history");
						playerModel.clear();
						Script.tbQSelect("player_search_history", playerModel, true);
					});
					qtObj.queryDialog.open();
				}
			}else{
				qtObj.queryDialog.open();
			}
		}

	}

	Rectangle{
		id: rect;
		anchors{
			top: headerBottom;
			left:parent.left;
		}
		width: 480;
		height: 280;
		z: 1;
		Row{
			anchors.fill: parent;
			spacing: 5;
			Column{
				width: parent.width - search.width - parent.spacing;
				height: parent.height;
				spacing: 2;
				KatarinaTextField{
					id: textfield;
					height: 50;
					placeholderText:qsTr("Input player name");
					width: parent.width;
					enterText: qsTr("Search");
					enterEnabled: text !== "";
					onReturnPressed:{
						search.focus = true;
						search.clicked();
					}
					onActiveFocusChanged:{
						if(activeFocus)
						{
							flipable.state = "front";
						}
					}
				}
				Tumbler {
					height: parent.height - parent.spacing - textfield.height;
					width: parent.width;
					anchors.fill: undefined;
					columns: [comtc, servertc];
					TumblerColumn {
						id: comtc;
						width: 120;
						label: qsTr("Com");
						items: ListModel{
							id: comModel;
						}
						selectedIndex: 0;
						onSelectedIndexChanged:{
							qtObj.getServerModel();
						}
					}

					TumblerColumn {
						id:servertc;
						label: qsTr("Server");
						items: ListModel{
							id: serverModel;
						}
						selectedIndex: 0;
						onSelectedIndexChanged:{
							if(selectedIndex === -1){
								selectedIndex = 0;
							}
						}
					}
				}
			}
			SearchButton{
				id: search;
				anchors.verticalCenter: parent.verticalCenter;
				enabled:textfield.text !== "";
				onClicked:{
					if(textfield.text !== "") {
						var serverName = constants._Server[comtc.selectedIndex].server[servertc.selectedIndex].name;
						var serverId = constants._Server[comtc.selectedIndex].server[servertc.selectedIndex].id;
						qtObj.getPlayerInfo(textfield.text, serverName, serverId);
					}
				}
			}
		}
	}

	Flipable{
		id: flipable;
		anchors{
			top: app.inPortrait ? rect.bottom : headerBottom;
			left: app.inPortrait ? parent.left : rect.right;
			right: parent.right;
			bottom: parent.bottom;
		}
		front: ListView{
			id: listView;
			anchors.fill: parent;
			model:ListModel{
				id: playerModel
			}
			clip: true;
			delegate: Component{
				Item{
					width: ListView.view.width;
					height: 80;
					Text{
						anchors.verticalCenter: parent.verticalCenter;
						width: parent.width;
						clip: true;
						font.pixelSize: constants._NormalPixelSize;
						font.family: constants._FontFamily;
						elide: Text.ElideRight;
						text: model.player_name + " - " + model.server_name + "(" + model.server_id + ")";
					}
					MouseArea{
						anchors.fill:parent;
						onClicked:{
							listView.currentIndex = index;
							qtObj.syncQueryComponent(model.player_name, model.server_name, model.server_id);
							search.clicked();
						}
						onPressAndHold:{
							Script.tbDelete("player_search_history", {server_name: "'" + model.server_name + "'", player_name: "'" + model.player_name + "'"});
							playerModel.clear();
							Script.tbQSelect("player_search_history", playerModel, true);
						}
					}
				}
			}
		}

		back: Flickable{
			id: flickable
			anchors.fill: parent;
			contentWidth: width;
			contentHeight: Math.max(height, baseInfoColumn.height);
			flickableDirection: Flickable.VerticalFlick;
			clip: true;
			PullToActivate{
				flickableItem: flickable;
				onRefresh:{
					qtObj.syncQueryComponent(qtObj.playerName, qtObj.serverName, qtObj.serverId);
					qtObj.getPlayerInfo();
				}
			}
			Column{
				id: baseInfoColumn;
				width: parent.width;
				visible: baseModel.count > 0;
				spacing: 4;
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
				Button{
					id: more;
					anchors.horizontalCenter: parent.horizontalCenter;
					text: qsTr("more");
					enabled: visible;
					onClicked:{
						var page = Qt.createComponent(Qt.resolvedUrl("PlayerDetailPage.qml"));
						pageStack.push(page, {playerName: qtObj.playerName, serverName: qtObj.serverName, serverId: qtObj.serverId});
					}
				}
			}
		}
		//visible: !root.indicating;
		transform: Rotation {
			id: rotation;
			origin: Qt.vector3d(flipable.width/2, flipable.height/2, 0);
			axis: Qt.vector3d(0, 1, 0);
			angle: 0;
		}
		states: [
			State {
				name: "back";
				PropertyChanges {
					target: rotation;
					angle: 180;
				}
			},
			State {
				name: "front";
				PropertyChanges {
					target: rotation;
					angle: 0;
				}
			}
		]
		transitions: Transition {
			RotationAnimation {
				direction: RotationAnimation.Clockwise;
			}
		}
		ScrollDecorator{
			flickableItem: flickable;
		}
	}

	tools:ToolBarLayout{
		ToolIcon{
			id: back;
			iconId: flipable.side === Flipable.Front ? "toolbar-back" : "toolbar-previous";
			onClicked:{
				if(flipable.side === Flipable.Front)
				{
					pageStack.pop();
				}
				else
				{
					flipable.state = "front";
				}
			}
		}
		Text{
			visible: flipable.side === Flipable.Front && playerModel.count !== 0;
			anchors.verticalCenter: parent.verticalCenter;
			elide: Text.ElideRight;
			font.family: constants._FontFamily;
			font.pixelSize: constants._NormalPixelSize;
			text: qsTr("Press and hold item to remove");
		}
		ToolIcon{
			id: remove;
			visible: enabled;
			enabled: playerModel.count !== 0 && flipable.side === Flipable.Front;
			iconId: "toolbar-delete";
			onClicked:{
				qtObj.openDialog();
			}
		}
	}

	/*
	 onStatusChanged: {
		 if (status === PageStatus.Active){
			 textfield.forceActiveFocus();
			 textfield.platformOpenSoftwareInputPanel();
		 }
	 }
	 */

	Component.onCompleted:{
		qtObj.getComModel();
		Script.tbQSelect("player_search_history", playerModel, true);
	}
}
