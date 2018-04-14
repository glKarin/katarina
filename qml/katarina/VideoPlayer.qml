import QtQuick 1.1
import com.nokia.meego 1.1
import QtMultimediaKit 1.1
import QtMobility.systeminfo 1.1
import "../js/utility.js" as Utility

Rectangle{
	id:root;

	color: "black";
	property url source;
	property bool barVisible: false;
	property variant typebar: null;
	property alias tableEnabled: table.enabled;
	property alias title: titletext.text;
	property alias playing: video.playing;
	signal exit;
	signal stopped;
	signal endOfMedia;
	//signal requestShowType;
	onBarVisibleChanged:{
		if(!barVisible){
			settingbar.state = "noshow";
			if(typebar)
			{
				typebar.state = "noshow";
			}
		}
	}

	function mouseMoveOrientation(x, y)
	{
		var v = Math.atan2(y, x) / Math.PI * 180;
		/*
		console.log(Math.atan2(0, 1) / Math.PI * 180);
		console.log(Math.atan2(1, 0) / Math.PI * 180);
		console.log(Math.atan2(0, -1) / Math.PI * 180);
		console.log(Math.atan2(-1, 0) / Math.PI * 180);
		*/
		if(v >= -45 && v <= 45)
		{
			return "right";
		}
		else if(v > 45 && v < 135)
		{
			return "down";
		}
		else if((v >= 135 && v <= 180) || (v >= -180 && v <= -135))
		{
			return "left";
		}
		else if(v > -135 && v < -45)
		{
			return "up";
		}
		else
		{
			return "no";
		}
	}

	function stop() {
		video.stop();
		video.position = 0;
		root.exit();
	}

	function stopOnly() {
		video.stop();
		video.source = "";
		video.position = 0;
	}

	function load() {
		video.source = root.source;
		console.log(source);
		if(video.source.length !== 0){
			video.play();
			video.fillMode = Video.PreserveAspectFit;
			fillmodellist.currentIndex = 0;
		}
	}

	BusyIndicator{
		id:indicator;
		anchors.centerIn: parent;
		z: 3;
		platformStyle: BusyIndicatorStyle{
			size: "large";
			inverted: true;
		}
		visible: video.playing && video.bufferProgress !== 1.0;
		running: visible;
	}

	Connections{
		target: screen;
		onMinimizedChanged:{
			if(screen.minimized){
				video.paused = true;
			}
		}
	}

	Video {
		id: video;
		anchors.fill: parent;
		onError:{
			if(error !== Video.NoError){
				app.showMsg(error + ": " + errorString);
				root.stopOnly();
			}
		}
		/*
		 onStopped:{
			 video.position = 0;
			 root.exit();
		 }
		 */
		onStatusChanged:{
			if(status === Video.EndOfMedia){
				root.endOfMedia();
				video.position = 0;
			}
		}
		volume: (devinfo.voiceRingtoneVolume > 50 ? 50 : devinfo.voiceRingtoneVolume < 20 ? 20 : devinfo.voiceRingtoneVolume) / 100;
		focus: true;
		Keys.onSpacePressed: video.paused = !video.paused;
		Keys.onLeftPressed: video.position -= 5000;
		Keys.onRightPressed: video.position += 5000;

	}
	ScreenSaver{
		id: screensaver;
		screenSaverDelayed: video.playing && !video.paused;
	}
	DeviceInfo {
		id: devinfo;
	}

	Rectangle{
		id: headbar;
		property int theight: 60;
		anchors.top: parent.top;
		width: parent.width;
		color: "black";
		z: 1;
		opacity: 0.8
		smooth: true;
		states:[
			State{
				name:"show";
				PropertyChanges {
					target: headbar;
					height: theight;
				}
			}
			,
			State{
				name:"noshow";
				PropertyChanges {
					target: headbar;
					height: 0;
				}
			}
		]
		state: root.barVisible ? "show" : "noshow";
		transitions: [
			Transition {
				from: "noshow";
				to: "show";
				NumberAnimation{
					target: headbar;
					property: "height";
					duration: 400;
					easing.type: Easing.OutExpo;
				}
			}
			,
			Transition {
				from: "show";
				to: "noshow";
				NumberAnimation{
					target: headbar;
					property: "height";
					duration: 400;
					easing.type: Easing.InExpo;
				}
			}
		]

		AutoMoveText{
			id: titletext;
			anchors.left: parent.left;
			anchors.right: table.left;
			anchors.verticalCenter: parent.verticalCenter;
			color: "white";
			pixelSize: constants._NormalPixelSize;
			isOver: visible;
			visible: parent.height === parent.theight;
		}

		ToolIcon{
			id: table;
			iconId: "toolbar-list";
			height: parent.height;
			anchors.right: fillmode.left;
			anchors.verticalCenter: parent.verticalCenter;
			visible: parent.height === parent.theight;
			onClicked:{
				timer.restart();
				//root.requestShowType();
				if(root.typebar)
				{
					root.typebar.state = (root.typebar.state === "show" ? "noshow" : "show");
				}
			}
		}
		ToolIcon{
			id:fillmode;
			iconId: "toolbar-settings";
			height: parent.height;
			anchors.right: close.left;
			anchors.verticalCenter: parent.verticalCenter;
			visible: parent.height === parent.theight;
			onClicked:{
				timer.restart();
				settingbar.state = (settingbar.state === "show" ? "noshow" : "show");
			}
		}

		ToolIcon{
			id:close;
			iconId: "toolbar-close";
			height: parent.height;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			visible: parent.height === parent.theight;
			onClicked:{
				root.stop();
			}
		}
	}

	Rectangle{
		id:settingbar;
		property int twidth: 180;
		anchors.left: parent.left;
		anchors.verticalCenter: parent.verticalCenter;
		height: 170;
		color: "black";
		z: 1;
		opacity: 0.8;
		state: "noshow";
		smooth: true;
		states: [
			State{
				name: "show";
				PropertyChanges {
					target: settingbar;
					width: twidth;
				}
			}
			,
			State{
				name: "noshow";
				PropertyChanges {
					target: settingbar;
					width: 0;
				}
			}
		]
		transitions: [
			Transition {
				from: "noshow";
				to: "show";
				NumberAnimation{
					target: settingbar;
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
					target: settingbar;
					property: "width";
					duration: 400;
					easing.type: Easing.InExpo;
				}
			}
		]
		Text{
			id: fillmodellabel;
			anchors.top: parent.top;
			anchors.horizontalCenter: parent.horizontalCenter;
			font.pixelSize: constants._LargePixelSize;
			font.family: constants._FontFamily;
			text: qsTr("Fill Mode");
			color: "white";
			visible: parent.width === parent.twidth;
			clip: true;
		}
		ListView{
			id: fillmodellist;
			anchors.fill: parent;
			anchors.topMargin: fillmodellabel.height;
			visible: parent.width === parent.twidth;
			interactive: false;
			opacity: parent.opacity;
			clip: true;
			model: ListModel{
				ListElement{
					name: "Fit";
					value: Video.PreserveAspectFit;
				}
				ListElement{
					name: "Crop";
					value: Video.PreserveAspectCrop;
				}
				ListElement{
					name: "Stretch";
					value: Video.Stretch;
				}
			}
			delegate: Component{
				Rectangle{
					width: ListView.view.width;
					height: ListView.view.height / 3;
					opacity: ListView.view.opacity;
					color: ListView.isCurrentItem ? "white" : "black";
					Text{
						color: parent.ListView.isCurrentItem ? "black" : "white";
						font.pixelSize: constants._NormalPixelSize;
						font.family: constants._FontFamily;
						anchors.centerIn: parent;
						text: model.name;
					}
					MouseArea{
						anchors.fill: parent;
						onClicked:{
							timer.restart();
							video.fillMode = model.value;
							fillmodellist.currentIndex = index;
						}
					}
				}
			}
		}
	}

	Rectangle{
		id: toolbar;
		property int theight: 60;
		anchors.bottom: parent.bottom;
		width: parent.width;
		color: "black";
		z: 1;
		opacity: 0.8
		smooth: true;
		states: [
			State{
				name:"show";
				PropertyChanges {
					target: toolbar;
					height: theight;
				}
			}
			,
			State{
				name: "noshow";
				PropertyChanges {
					target: toolbar;
					height: 0;
				}
			}
		]
		state: root.barVisible ? "show" : "noshow";
		transitions: [
			Transition {
				from: "noshow";
				to: "show";
				NumberAnimation{
					target: toolbar;
					property: "height";
					duration: 400;
					easing.type: Easing.OutExpo;
				}
			}
			,
			Transition {
				from: "show";
				to: "noshow";
				NumberAnimation{
					target: toolbar;
					property: "height";
					duration: 400;
					easing.type: Easing.InExpo;
				}
			}
		]

		ToolIcon{
			id: play;
			iconId: video.paused ? "toolbar-mediacontrol-play" : "toolbar-mediacontrol-pause";
			height: parent.height;
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
			enabled: video.playing;
			visible: parent.height === parent.theight;
			onClicked:{
				timer.restart();
				video.paused = !video.paused;
			}
		}

		Text{
			anchors.left: progressBar.left;
			anchors.top: parent.top;
			anchors.bottom: progressBar.top;
			color: "white";
			width: 60;
			font.pixelSize: constants._SmallPixelSize;
			font.family: constants._FontFamily;
			visible: parent.height === parent.theight;
			text: visible ? Utility.castMS2S(video.position) : "";
		}

		ProgressBar {
			id: progressBar
			anchors{
				left: play.right;
				right: stop.left;
				verticalCenter: toolbar.verticalCenter;
			}
			visible: parent.height === parent.theight;
			minimumValue: 0;
			maximumValue: video.duration || 0;
			value: video.position || 0;
		}
		MouseArea{
			anchors{
				left: progressBar.left;
				right: progressBar.right;
				verticalCenter: progressBar.verticalCenter;
			}
			enabled: video.duration !== 0;
			height: 5 * progressBar.height;
			onReleased:{
				timer.restart();
				if(video.seekable) {
					video.position = video.duration * mouse.x / width;
				}
			}
		}

		Text{
			id: durationtext;
			anchors.right: progressBar.right;
			anchors.top: parent.top;
			anchors.bottom: progressBar.top;
			color: "white";
			width: 60;
			font.pixelSize: constants._SmallPixelSize;
			font.family: constants._FontFamily;
			visible: parent.height === parent.theight;
			text: visible ? Utility.castMS2S(video.duration) : "";
		}

		ToolIcon{
			id: stop;
			height: parent.height;
			iconId: "toolbar-mediacontrol-stop";
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			visible: parent.height === parent.theight;
			enabled: video.playing;
			onClicked:{
				timer.restart();
				root.stopOnly();
				root.stopped();
			}
		}
	}

	Timer{
		id: timer;
		interval: 8000;
		repeat: false;
		running: root.barVisible;
		onTriggered:{
			root.barVisible = false;
		}
	}
	MouseArea{
		property int prev_x: -1;
		property int prev_y: -1;
		property bool move: false;
		anchors.fill: parent;
		hoverEnabled: true;
		onPressed:{
			prev_x = mouse.x;
			prev_y = mouse.y;
		}
		onPositionChanged:{
			if(!pressed)
			{
				return;
			}
			if(prev_x === -1 || prev_y === -1)
			{
				prev_x = mouse.x;
				prev_y = mouse.y;
				return;
			}
			if(mouse.x !== prev_x)
			{
				move = true;
				var move_x = mouse.x - prev_x;
				var p = video.position + video.duration / width * move_x;
				if(p < 0)
				{
					p = 0;
				}
				if(p > video.duration)
				{
					p = video.duration;
				}
				timeText.text = Utility.castMS2S(p);
				timeText.visible = true;
			}
		}
		onReleased:{
			if(move)
			{
				move = false;
				if(prev_x !== -1 && video.seekable)
				{
					var orientation = mouseMoveOrientation(mouse.x - prev_x, mouse.y - prev_y);
					console.log(orientation);
					if(orientation === "left" || orientation === "right")
					{
						var move_x = mouse.x - prev_x;
						var p = video.position + video.duration / width * move_x;
						if(p < 0)
						{
							p = 0;
						}
						if(p > video.duration)
						{
							p = video.duration;
						}
						video.position = p;
					}
				}
				timeText.text = "";
				timeText.visible = false;
			}
			prev_x = -1;
			prev_y = -1;
		}
		onClicked:{
			prev_x = -1;
			prev_y = -1;
			root.barVisible = !root.barVisible;
		}
		onDoubleClicked:{
			prev_x = -1;
			prev_y = -1;
			if(video.playing){
				video.paused = ! video.paused;
			}
		}
	}
	Text{
		id: timeText;
		anchors.centerIn: parent;
		color: "white";
		font.pixelSize: constants._LargePixelSize;
		font.family: constants._FontFamily;
	}


	Component.onDestruction:{
		video.stop();
	}
}
