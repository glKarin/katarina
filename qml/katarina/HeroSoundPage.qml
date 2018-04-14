import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

KatarinaPage{
	id: root;
	property string enName: null;
	property string cnName: null;
	title: (cnName || enName) + " " + qsTr("Sound");

	QtObject{
		id: qtObj;
		property string privateEnName: root.enName;

		function getHeroSounds()
		{
			if(!privateEnName || privateEnName === "")
				return;
			soundModel.clear();
			var opt = {
				hero: privateEnName
			};
			function success(jsObject)
			{
				soundModel.clear();
				if(jsObject)
				{
					Script.getHeroSounds(jsObject, soundModel);
				}
				root.indicating = false;
			}

			function fail(e)
			{
				app.showMsg(qsTr("Get hero sound fail") + " - " + e);
				root.indicating = false;
			}
			Script.callAPI("HeroSounds", success, fail, opt, "GET");
			root.indicating = true;
		}
		function playAudio()
		{
			if(listView.currentIndex === -1)
			return;
			var sound = soundModel.get(listView.currentIndex).sound;
			var source = "http://box.dwstatic.com/sounds/" + privateEnName + "/" + sound;
			audioPlayer.play(source);
			audioPlayer.title = sound;
		}

	}

	AudioPlayer{
		id: audioPlayer;
		anchors{
			top: headerBottom;
			left: parent.left;
			//right: app.inPortrait ? parent.right : undefined;
		}
		height: 320;
		width: 480;
		imageSource: Script.getSkinPic(enName);
		prevEnabled: soundModel.count && listView.currentIndex > 0;
		nextEnabled: soundModel.count && listView.currentIndex < soundModel.count - 1;
		onPrev:{
			if(listView.currentIndex > 0)
			{
				listView.decrementCurrentIndex();
				qtObj.playAudio();
			}
		}
		onNext:{
			if(listView.currentIndex < soundModel.count - 1)
			{
				listView.incrementCurrentIndex();
				qtObj.playAudio();
			}
		}
	}

	ListView{
		id: listView;
		visible: !root.indicating;
		anchors{
			top: app.inPortrait ? audioPlayer.bottom : headerBottom;
			left: app.inPortrait ? parent.left : audioPlayer.right;
			right: parent.right;
			bottom: parent.bottom;
		}
		clip: true;
		model: ListModel{
			id: soundModel;
		}
		delegate: Component{
			Item{
				width: ListView.view.width;
				height: 60;
				Rectangle{
					anchors.fill: parent;
					anchors.margins: border.width;
					radius: parent.ListView.view.currentIndex === index ? 10 : 0;
					color: parent.ListView.view.currentIndex === index ? "lightskyblue" : "white";
					Text{
						width: parent.width;
						height: 30;
						clip: true;
						anchors.verticalCenter: parent.verticalCenter;
						font.family: constants._FontFamily;
						font.pixelSize: constants._NormalPixelSize;
						text: Script.getSoundName(qtObj.privateEnName, model.sound);
					}
				}
				MouseArea{
					anchors.fill: parent;
					onClicked:{
						listView.currentIndex = index;
						qtObj.playAudio();
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
				audioPlayer.source = "";
				audioPlayer.title = "";
				audioPlayer.stop(true);
				qtObj.getHeroSounds();
			}
		}
	}


	Component.onCompleted:{
		qtObj.getHeroSounds();
	}

}
