import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "../js/main.js" as Script

Page{
	id:root;

	orientationLock: PageOrientation.LockLandscape;
	property string vid: null;
	property string videoTitle: null;

	QtObject{
		id:qtObj;

		property string privateVid: root.vid;
		property bool loaded: false;

		function endOfMediaHandler(){
			addMsg(qsTr("End"));
			loader.item.stopOnly();
			exit();
		}

		function addMsg(msg){
			logView.visible = true;
			logmodel.append({value: msg});
			if(logmodel.count > 15){
				logmodel.remove(0);
			}
		}

		function exit() {
			loader.sourceComponent = undefined;
			pageStack.pop(undefined, true);
		}

		function stoppedHandler(){
			addMsg(qsTr("End"));
			//loaded = false;
		}

		function loadPlayer(url, taskName, taskValue) {
			if(!loader.item){
				addMsg(qsTr("Load video player"));
				loader.sourceComponent = Qt.createComponent(Qt.resolvedUrl("VideoPlayer.qml"));
				if (loader.status === Loader.Ready){
					var item = loader.item;
					item.source = url;
					item.title = "%1 [%2 - %3]".arg(root.videoTitle).arg(taskName).arg(taskValue);
					item.typebar = typebar;
					item.endOfMedia.connect(endOfMediaHandler);
					//item.requestShowType.connect(changeTypeBoxShow);
					item.stopped.connect(stoppedHandler);
					item.exit.connect(exit);
					item.load();
					addMsg(qsTr("Load video player success"));
					addMsg(qsTr("Playing video") + " - " + item.title);
					loaded = true;
					logView.visible = false;
				}
				else{
					addMsg(qsTr("Load video player fail"));
					loaded = false;
				}
			}else{
				var item = loader.item;
				item.source = url;
				item.stopOnly();
				item.title = "%1 [%2 - %3]".arg(root.videoTitle).arg(taskName).arg(taskValue);
				addMsg(qsTr("Playing video") + " - " + item.title);
				item.load();
				loaded = true;
				logView.visible = false;
			}
		}

		function getStreamtypes(){
			if(!privateVid || privateVid === ""){
				return;
			}
			streamtypesItem.streamModel.clear();
			var opt = {
				action: "f",
				vid: privateVid
			};
			function success(jsObject)
			{
				if(jsObject)
				{
					if(jsObject.message === "success")
					Script.getVideoStream(jsObject.result, streamtypesItem.streamModel, true);
					//console.log(streamtypesItem.streamModel.get(0).transcode.get(0).urls);
					var i = streamtypesItem.streamModel.get(0);
					loadPlayer(i.transcode.get(0).urls, i.task_name, i.task_value);
				}
				show.visible = false;
			}

			function fail(e)
			{
				app.showMsg(qsTr("Get video detail fail") + " - " + e);
				show.visible = false;
			}
			Script.callAPI("VideoDetail", success, fail, opt, "GET");
			//typebar.state = "show";
			show.visible = true;
		}

		function changeTypeBoxShow(){
			if(typebar.state === "show"){
				typebar.state = "noshow";
			}else{
				typebar.state = "show";
			}
		}
	}

	ToolIcon{
		id:back;
		iconId: "toolbar-back";
		anchors.right: parent.right;
		anchors.top: parent.top;
		enabled: visible;
		visible: !qtObj.loaded;
		z: 4;
		onClicked:{
			pageStack.pop(undefined, true);
		}
	}

	Button{
		id: replay;
		anchors.right: back.left;
		anchors.top: parent.top;
		anchors.topMargin: 7;
		platformStyle: ButtonStyle {
			buttonWidth: buttonHeight; 
		}
		iconSource: "image://theme/icon-m-toolbar-refresh";
		enabled: visible;
		visible: !qtObj.loaded;
		z: 4;
		onClicked:{
			qtObj.getStreamtypes();
		}
	}

	Rectangle{
		id:typebar;
		anchors{
			top: parent.top;
			right: parent.right;
			topMargin: 60;
			bottom: parent.bottom;
			bottomMargin: 60;
		}
		z: 4;
		opacity: 0.6;
		color: "black";
		smooth: true;
		states:[
			State{
				name:"show";
				PropertyChanges {
					target: typebar;
					width: 320;
				}
			}
			,
			State{
				name: "noshow";
				PropertyChanges {
					target: typebar;
					width: 0;
				}
			}
		]
		state: "noshow";
		transitions: [
			Transition {
				from: "noshow";
				to: "show";
				NumberAnimation{
					target: typebar;
					property: "width";
					duration: 400;
					easing.type: Easing.OutExpo;
				}
			}
			,
			Transition {
				from: "show";
				to: "noshow";
				NumberAnimation{
					target: typebar;
					property: "width";
					duration: 400;
					easing.type: Easing.InExpo;
				}
			}
		]

		StreamtypesItem{
			id: streamtypesItem;
			anchors.fill: parent;
			visible: parent.width === 320;
			z:2;
			onOpenUrl:{
				qtObj.loadPlayer(url, task_name, task_value);
				typebar.state = "noshow";
			}
		}
	}

	Item{
		id: logView;
		anchors.fill: parent;
		visible: true;
		z: 3;
		//color: "black";
		Column{
			anchors.fill: parent;
			anchors.margins: 20;
			spacing: 2;
			Repeater{
				model: ListModel{id:logmodel}
				delegate: Component{
					Text{
						width: root.width;
						font.pixelSize: constants._NormalPixelSize;
						font.family: constants._FontFamily;
						color: "white";
						text: model.value;
					}
				}
			}
		}

	}
	Loader{
		id: loader;
		anchors.fill: parent;
		z:1;
	}

	BusyIndicator{
		id: show;
		anchors.centerIn: parent;
		z: 4;
		platformStyle: BusyIndicatorStyle{
			size: "large";
			inverted: true;
		}
		visible: false;
		running: visible;
	}

	Component.onCompleted:{
		qtObj.getStreamtypes();
	}

	Component.onDestruction:{
		loader.sourceComponent = undefined;
	}
}

