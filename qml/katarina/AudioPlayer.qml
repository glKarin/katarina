import QtQuick 1.1
import com.nokia.meego 1.1
import QtMultimediaKit 1.1
import QtMobility.systeminfo 1.1
import "../js/utility.js" as Utility

Item{
	id: root;
	property alias source: audio.source;
	property alias title: title.text;
	property alias imageSource: pic.source;
	property alias prevEnabled: prev.enabled;
	property alias nextEnabled: next.enabled;
	signal prev();
	signal next();


	Column{
		anchors.fill: parent;
		AutoMoveText{
			id:title;
			anchors.left:parent.left;
			anchors.right:parent.right;
			isOver: visible;
			height: 30;
		}
		Image{
			id: pic;
			width: 360;
			height: 200;
			anchors.horizontalCenter: parent.horizontalCenter;
			smooth: true;
			BusyIndicator{
				anchors.centerIn: parent;
				running: audio.status === Audio.Loading;
				visible: running;
				platformStyle:BusyIndicatorStyle{
					inverted:true;
					size: "small";
				}
			}
		}
		Item{
			width: parent.width;
			height: 30;
			Text{
				id: playTime;
				anchors.left: parent.left;
				anchors.verticalCenter: parent.verticalCenter;
				font.family: constants._FontFamily;
				font.pixelSize: constants._SmallPixelSize;
				width:60;
				text:Utility.castMS2S(audio.position);
			}

			ProgressBar {
				id: progressBar;
				anchors.left: playTime.right;
				anchors.right: durationTime.left;
				anchors.verticalCenter: parent.verticalCenter;
				width: parent.width - 60 * 2;
				minimumValue: 0;
				maximumValue: audio.duration || 0;
				value: audio.position || 0;
			}
			MouseArea{
				anchors{
					left: progressBar.left;
					right: progressBar.right;
					verticalCenter: progressBar.verticalCenter;
				}
				enabled: audio.duration !== 0;
				height: 5 * progressBar.height;
				onReleased:{
					if(audio.seekable) {
						audio.position = audio.duration * mouse.x / width;
					}
				}
			}

			Text{
				id: durationTime;
				anchors.right: parent.right;
				anchors.verticalCenter: parent.verticalCenter;
				font.family: constants._FontFamily;
				font.pixelSize: constants._SmallPixelSize;
				width: 60;
				text: Utility.castMS2S(audio.duration);
			}
		}
		Item{
			width: parent.width;
			height: 60;
			Audio {
				id: audio;
				volume: (devinfo.voiceRingtoneVolume > 50 ? 50 : devinfo.voiceRingtoneVolume < 20 ? 20 : devinfo.voiceRingtoneVolume) / 100;
				onError:{
					if(error !== Audio.NoError){
						app.showMsg(error + " : " + errorString);
					}
				}
				onStatusChanged:{
					if(status === Audio.EndOfMedia){
						audio.position = 0;
					}
				}
				Keys.onSpacePressed: audio.paused = !audio.paused;
				Keys.onLeftPressed: audio.position -= 5000;
				Keys.onRightPressed: audio.position += 5000;
			}
			ToolBarLayout{
				ToolIcon{
					id: play;
					iconId: audio.paused ? "toolbar-mediacontrol-play" : "toolbar-mediacontrol-pause";
					enabled: audio.playing;
					onClicked:{
						audio.paused = !audio.paused;
					}
				}
				ToolIcon{
					id:prev;
					iconId: "toolbar-mediacontrol-previous";
					onClicked:{
						root.prev();
					}
				}
				ToolIcon{
					id: next;
					iconId: "toolbar-mediacontrol-next";
					onClicked:{
						root.next();
					}
				}

				ToolIcon{
					id:stop;
					iconId: "toolbar-mediacontrol-stop";
					enabled: audio.playing;
					onClicked:{
						root.stop();
					}
				}
			}

		}
	}
	ScreenSaver{
		id:screensaver;
		screenSaverDelayed: audio.playing && !audio.paused;
	}
	DeviceInfo {
		id: devinfo;
	}

	function stop(reset) 
	{
		audio.stop();
		audio.position = 0;
		if(reset)
		audio.source = "";
	}

	function play(source)
	{
		audio.source = source;
		if(audio.source.length !== 0){
			audio.play();
		}
	}

}
