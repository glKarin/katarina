import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

Page{
	id:root;
	orientationLock: settings.lockOrientation === "portrait" ? PageOrientation.LockPortrait : settings.lockOrientation === "landscape"? PageOrientation.LockLandscape : PageOrientation.Automatic;

	property int desktopWidth: screen.currentOrientation === Screen.Portrait || screen.currentOrientation === Screen.PortraitInverted ? 120 : 122;
	property int iconHorizontalMargin: (desktopWidth - iconWidth) / 2;
	property int desktopHeight: 118;
	property int iconTopMargin: (desktopHeight - iconHeight) / 2;
	property int textHeight: 30;
	property int iconWidth: 80;
	property int iconHeight: 80;
	property real frontBackgroundOpacity: 0.5;
	property int desktopLabelSize: 20;//normal //18
	property string desktopLabelColor: "#FFFFFF";

	Rectangle{
		anchors.fill: parent;
		color: "black";
		GridView{
			id: maingrid;
			anchors.fill: parent;
			clip: true;
			model: ListModel{
				id:hsmodel;
			}
			cellWidth: desktopWidth;
			cellHeight: desktopHeight + textHeight;
			delegate:Component{
				Item{
					width: GridView.view.cellWidth;
					height: GridView.view.cellHeight;
					Image{
						id: icon;
						anchors.top: parent.top;
						anchors.topMargin: iconTopMargin;
						height: iconHeight;
						width: iconWidth;
						anchors.horizontalCenter: parent.horizontalCenter;
						source: Qt.resolvedUrl(model.icon);
						smooth: true;
					}
					Text{
						anchors.topMargin: iconTopMargin;
						anchors.top: icon.bottom;
						font.pixelSize: desktopLabelSize + 2;
						font.weight: Font.Light;
						color: desktopLabelColor;
						elide: Text.ElideRight;
						anchors.horizontalCenter: parent.horizontalCenter;
						clip: true;
						text: model.name;
					}
					Rectangle{
						id: shadow;
						anchors.fill: parent;
						color: "black";
						opacity: 0.5;
						visible: mousearea.pressed;
					}
					MouseArea{
						id: mousearea;
						anchors.topMargin: iconTopMargin;
						anchors.fill: parent;
						onClicked:{
							maingrid.currentIndex = index;
							if(model.actions === "KATARINA_QUIT"){
								Qt.quit();
							}else if(model.actions === "unfinished"){
								app.showMsg(qsTr("Comimg soon!"));
							}else{
								var page = Qt.createComponent(Qt.resolvedUrl(model.actions + ".qml"));
								pageStack.push(page);
							}
						}
					}
				}
			}
		}
		ScrollDecorator{
			opacity: 0.5;
			flickableItem: maingrid;
		}

	}

	Component.onCompleted:{
		hsmodel.clear();
		hsmodel.append({
			icon: "../image/katarina-l-news.png",
			name: qsTr("News"),
			actions: "NewsPage"
		});
		hsmodel.append({
			icon: "../image/katarina-l-hero.png",
			name: qsTr("Hero"),
			actions: "HeroesPage"
		});
		hsmodel.append({
			icon: "../image/katarina-l-GL.png",
			name: qsTr("Hero Model"),
			actions: "HeroModelPage"
		});
		hsmodel.append({
			icon: "../image/katarina-l-item.png",
			name: qsTr("Item"),
			actions: "ItemsPage"
		});
		hsmodel.append({
			icon: "../image/katarina-l-search.png",
			name: qsTr("Player"),
			actions: "PlayerSearchPage"
		});
		hsmodel.append({
			icon: "../image/katarina-l-settings.png",
			name: qsTr("Setting"),
			actions: "SettingPage"
		});
		hsmodel.append({
			icon: "../image/katarina-l-about.png",
			name: qsTr("About"),
			actions: "AboutPage"
		});
		hsmodel.append({
			icon: "../image/katarina-l-quit.png",
			name: qsTr("Quit"),
			actions: "KATARINA_QUIT"
		});
	}
}

