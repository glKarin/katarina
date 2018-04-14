import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;
	anchors.fill: parent;
	Item{
		id: levelBar;
		anchors{
			top: parent.top;
			left: parent.left;
			right: parent.right;
		}
		z: 1;
		height: 30;
		Text{
			anchors{
				left: parent.left;
				verticalCenter: parent.verticalCenter;
			}
			font.family: constants._FontFamily;
			font.pixelSize: constants._NormalPixelSize;
			text: "1";
			clip: true;
			height: parent.height;
			width: height;
		}
		Text{
			anchors.centerIn: parent;
			font.family: constants._FontFamily;
			font.pixelSize: constants._NormalPixelSize;
			text: slider.value;
			clip: true;
			height: parent.height;
			width: height;
		}
		Text{
			font.family: constants._FontFamily;
			font.pixelSize: constants._NormalPixelSize;
			text: "18";
			clip: true;
			height: parent.height;
			width: height;
			anchors{
				right: parent.right;
				verticalCenter: parent.verticalCenter;
			}
		}
	}
	Slider{
		id: slider;
		anchors{
			top: levelBar.bottom;
			left: parent.left;
			right: parent.right;
		}
		z:1;
		width: parent.width - parent.height * 2;
		minimumValue: 1;
		maximumValue: 18;
		stepSize: 1;
		value: 1;
		valueIndicatorText: value + qsTr("Level");
	}
	GridView{
		id: flickable;
		anchors{
			top: slider.bottom;
			left: parent.left;
			right: parent.right;
			bottom: parent.bottom;
		}
		model: ListModel{
			id: propModel;
		}
		cellWidth: parent.width / 2;
		cellHeight: 30;
		clip:true;
		delegate: Component{
			Item{
				width: GridView.view.cellWidth;
				height: GridView.view.cellHeight;
				CountText{
					anchors.fill: parent;
					label: model.label;
					level: slider.value;
					base: model.base;
					grow: model.grow;
				}
			}
		}
	}
	ScrollDecorator{
		flickableItem: flickable;
	}
	function init(prop)
	{
		propModel.clear();
		propModel.append({
			label: qsTr("Health"), 
			base: prop && prop.health && prop.health.healthBase ? prop.health.healthBase : 0.0,
			grow: prop && prop.health && prop.health.healthLevel ? prop.health.healthLevel : 0.0,
		});
		propModel.append({
			label: qsTr("Mana"), 
			base: prop && prop.mana && prop.mana.manaBase ? prop.mana.manaBase : 0.0,
			grow: prop && prop.mana && prop.mana.manaLevel ? prop.mana.manaLevel : 0.0
		});
		propModel.append({
			label: qsTr("Armor"), 
			base: prop && prop.armor && prop.armor.armorBase ? prop.armor.armorBase : 0.0,
			grow: prop && prop.armor && prop.armor.armorLevel ? prop.armor.armorLevel : 0.0
		});
		propModel.append({
			label: qsTr("Magic Resist"), 
			base: prop && prop.magicResist && prop.magicResist.magicResistBase ? prop.magicResist.magicResistBase : 0.0,
			grow: prop && prop.magicResist && prop.magicResist.magicResistLevel ? prop.magicResist.magicResistLevel : 0.0
		});
		propModel.append({
			label: qsTr("Health Regen"), 
			base: prop && prop.healthRegen && prop.healthRegen.healthRegenBase ? prop.healthRegen.healthRegenBase : 0.0,
			grow: prop && prop.healthRegen && prop.healthRegen.healthRegenLevel ? prop.healthRegen.healthRegenLevel : 0.0
		});
		propModel.append({
			label: qsTr("Mana Regen"), 
			base: prop && prop.manaRegen && prop.manaRegen.manaRegenBase ? prop.manaRegen.manaRegenBase : 0.0,
			grow: prop && prop.manaRegen && prop.manaRegen.manaRegenLevel ? prop.manaRegen.manaRegenLevel : 0.0
		});
		propModel.append({
			label: qsTr("Attack"), 
			base: prop && prop.attack && prop.attack.attackBase ? prop.attack.attackBase : 0.0,
			grow: prop && prop.attack && prop.attack.attackLevel ? prop.attack.attackLevel : 0.0
		});
		propModel.append({
			label: qsTr("Critical Chance"), 
			base: prop && prop.criticalChance && prop.criticalChance.criticalChanceBase ? prop.criticalChance.criticalChanceBase : 0.0,
			grow: prop && prop.criticalChance && prop.criticalChance.criticalChanceLevel ? prop.criticalChance.criticalChanceLevel : 0.0
		});
		propModel.append({
			label: qsTr("Move Speed"), 
			base: prop && prop.moveSpeed && prop.moveSpeed.moveSpeed ? prop.moveSpeed.moveSpeed : 0.0,
			grow: 0.0
		});
		propModel.append({
			label: qsTr("Range"), 
			base: prop && prop.range && prop.range.range ? prop.range.range : 0.0,
			grow: 0.0
		});
		propModel.append({
			label: qsTr("Rating Attack"), 
			base: prop && prop.ratingAttack && prop.ratingAttack.ratingAttack ? prop.ratingAttack.ratingAttack : 0.0,
			grow: 0.0
		});
		propModel.append({
			label: qsTr("Rating Magic"), 
			base: prop && prop.ratingMagic && prop.ratingMagic.ratingMagic ? prop.ratingMagic.ratingMagic : 0.0,
			grow: 0.0
		});
		propModel.append({
			label: qsTr("Rating Defense"), 
			base: prop && prop.ratingDefense && prop.ratingDefense.ratingDefense ? prop.ratingDefense.ratingDefense : 0.0,
			grow: 0.0
		});
		propModel.append({
			label: qsTr("Rating Difficulty"), 
			base: prop && prop.ratingDifficulty && prop.ratingDifficulty.ratingDifficulty ? prop.ratingDifficulty.ratingDifficulty : 0.0,
			grow: 0.0
		});
		slider.value = 1;
	}
}
