import QtQuick 1.1
import com.nokia.meego 1.1
import "../js/main.js" as Script
import "../js/utility.js" as Utility

Item{
	id: root;
	property string enName: null;
	ListView{
		id: abilityList;
		anchors{
			top: parent.top;
			left: parent.left;
			right: parent.right;
			leftMargin: 5;
			rightMargin: 5;
		}
		z: 1;
		model: ListModel{
			id: abilityModel;
		}
		spacing: (width - height * 5) / 4;
		height: 64;
		orientation: ListView.Horizontal;
		interactive: false;
		clip: true;
		delegate: Component{
			Item{
				height: ListView.view.height;
				width: height;
				Image{
					smooth: true;
					anchors.fill: parent;
					source: Script.getAbilityPic(root.enName, model.key);
				}
				MouseArea{
					anchors.fill: parent;
					onClicked:{
						root.setAbilityText(model.name, model.cost, model.cooldown, model.range, model.description, model.effect);
					}
				}
			}
		}
	}
	TextListView{
		id: flickable;
		anchors{
			top: abilityList.bottom;
			left: parent.left;
			right: parent.right;
			bottom: parent.bottom;
			topMargin: 4;
		}
		model: ListModel{
			id: infoModel;
		}
	}
	function setAbilityText(name, cost, cooldown, range, description, effect)
	{
		infoModel.clear();
		Utility.setText(infoModel, qsTr("Name"),  name, true);
		Utility.setText(infoModel, qsTr("Cost"), cost, true); 
		Utility.setText(infoModel, qsTr("Cooldown"), cooldown, true); 
		Utility.setText(infoModel, qsTr("Range"), range, true); 
		Utility.setText(infoModel, qsTr("Description"), description, true); 
		Utility.setText(infoModel, qsTr("Effect"), effect, true); 
	}
	
	function init(ability){
		abilityModel.clear();
		if(ability)
		{
			var abilityArr = ["B", "Q", "W", "E", "R"];
			abilityArr.forEach(function(i){
				abilityModel.append(
					{
						key: i,
						name: ability[i].name, 
						cost: ability[i].cost, 
						cooldown: ability[i].cooldown, 
						range: ability[i].range,
						description: ability[i].description.replace(/\n/g, "<br/>"),
						effect: ability[i].effect.replace(/\n/g, "<br/>")
					}
				);
			});
			if(abilityModel.count === 5)
			{
				var a = abilityModel.get(0);
				root.setAbilityText(a.name, a.cost, a.cooldown, a.range, a.description, a.effect);
			}
			else
			{
				root.setAbilityText();
			}
		}
		else
		{
			root.setAbilityText();
		}
	}
}
