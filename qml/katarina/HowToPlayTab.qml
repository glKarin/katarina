import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script

Item{
	id: root;
	property variant tipsModel: ListModel{}
	property variant relationModel: ListModel{}
	signal openHeroDetail(string enName);

	Flickable{
		id: flickable;
		clip: true;
		anchors.fill: parent;
		contentWidth: width;
		contentHeight: Math.max(height, column.height);
		flickableDirection: Flickable.VerticalFlick;
		Column{
			id: column;
			width: parent.width;
			clip: true;
			spacing: 10;
			Repeater{
				model: root.tipsModel;
				delegate: Component{
					Item{
						width: column.width;
						height: childrenRect.height;
						Column{
							spacing: 4;
							width: parent.width;
							LineText{
								width: parent.width;
								style: "middle";
								text: model.name;
							}
							Text{
								width: parent.width;
								font.pixelSize: constants._NormalPixelSize;
								font.family: constants._FontFamily;
								wrapMode: Text.WordWrap;
								text: model.value;
							}
						}
					}
				}
			}
			Repeater{
				model: root.relationModel;
				delegate: Component{
					Item{
						width: column.width;
						height: childrenRect.height;
						Column{
							spacing: 4;
							width: parent.width;
							LineText{
								width: parent.width;
								style: "middle";
								text: model.name;
							}
							Item{
								width: parent.width;
								height: Math.max(info1.height, image1.height);
								Image{
									id: image1;
									anchors{
										left: parent.left;
										verticalCenter: parent.verticalCenter;
									}
									width: 64;
									height: 64;
									smooth: true;
									source: Script.getHeroPic(model.partner_1);
									MouseArea{
										anchors.fill: parent;
										onClicked:{
											root.openHeroDetail(model.partner_1);
										}
									}
								}
								Text{
									id: info1;
									anchors{
										top: parent.top;
										left: image1.right;
										right: parent.right;
										leftMargin: 4;
									}
									font.pixelSize: constants._NormalPixelSize;
									font.family: constants._FontFamily;
									wrapMode: Text.WordWrap;
									text: model.des_1;
								}
							}
							Rectangle{
								anchors.horizontalCenter: parent.horizontalCenter;
								width: parent.width - 40;
								height: 1;
								color: "gray";
								opacity: 0.5;
							}
							Item{
								width: parent.width;
								height: Math.max(info2.height, image2.height);
								Image{
									id: image2;
									anchors{
										left: parent.left;
										verticalCenter: parent.verticalCenter;
									}
									width: 64;
									height: 64;
									smooth: true;
									source: Script.getHeroPic(model.partner_2);
									MouseArea{
										anchors.fill: parent;
										onClicked:{
											root.openHeroDetail(model.partner_2);
										}
									}
								}
								Text{
									id: info2;
									anchors{
										top: parent.top;
										left: image2.right;
										right: parent.right;
										leftMargin: 4;
									}
									font.pixelSize: constants._NormalPixelSize;
									font.family: constants._FontFamily;
									wrapMode: Text.WordWrap;
									text: model.des_2;
								}
							}
						}
					}
				}
			}
		}
	}

	ScrollDecorator{
		flickableItem: flickable;
	}

	function init(tips, relation){
		root.tipsModel.clear();
		root.tipsModel.append({name: qsTr("Tips"), value: tips && tips.tips ? tips.tips : ""});
		root.tipsModel.append({name: qsTr("Opponent Tips"), value: tips && tips.opponentTips ? tips.opponentTips : ""});

		root.relationModel.clear();
		if(!relation)
		return;
		var like = relation.like;
		var likeItem = ({});
		likeItem["name"] = qsTr("Like");
		like.forEach(function(e, i){
			likeItem["partner_" + (i + 1)] = e.partner;
			likeItem["des_" + (i + 1)] = e.des;
		});
		root.relationModel.append(likeItem);
		var hate = relation.hate;
		var hateItem = ({});
		hateItem["name"] = qsTr("Hate");
		hate.forEach(function(e, i){
			hateItem["partner_" + (i + 1)] = e.partner;
			hateItem["des_" + (i + 1)] = e.des;
		});
		root.relationModel.append(hateItem);
	}
}
