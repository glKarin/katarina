import QtQuick 1.1

QtObject{
	property string _FontFamily: "Nokia Pure Text";
	property int _TinyPixelSize: 12;
	property int _SmallPixelSize: 18;
	property int _NormalPixelSize: 22;
	property int _LargePixelSize: 30;
	property int _SuperPixelSize: 42;
	property int _HeaderHeight: 80;
	property int _HeaderHeightLandscape: 60;
	property string _HeaderBGColor: "lightseagreen";
	property string _HeaderTextColor: "#9E1B29";

	property variant _Server: [
		{com: "电信", server: [
			{name: "艾欧尼亚", id: "电信一"},
			{name: "祖安", id: "电信二"},
			{name: "诺克萨斯", id: "电信三"},
			{name: "班德尔城", id: "电信四"},
			{name: "皮尔特沃夫", id: "电信五"},
			{name: "战争学院", id: "电信六"},
			{name: "巨神峰", id: "电信七"},
			{name: "雷瑟守备", id: "电信八"},
			{name: "裁决之地", id: "电信九"},
			{name: "黑色玫瑰", id: "电信十"},
			{name: "暗影岛", id: "电信十一"},
			{name: "钢铁烈阳", id: "电信十二"},
			{name: "均衡教派", id: "电信十三"},
			{name: "水晶之痕", id: "电信十四"},
			{name: "影流", id: "电信十五"},
			{name: "守望之海", id: "电信十六"},
			{name: "征服之海", id: "电信十七"},
			{name: "卡拉曼达", id: "电信十八"},
			{name: "皮城警备", id: "电信十九"}
		]},
		{com: "网通", server: [
			{name: "比尔吉沃特", id: "网通一"},
			{name: "德玛西亚", id: "网通二"},
			{name: "弗雷尔卓德", id: "网通三"},
			{name: "无畏先锋", id: "网通四"},
			{name: "恕瑞玛", id: "网通五"},
			{name: "扭曲丛林", id: "网通六"},
			{name: "巨龙之巢", id: "网通七"}
		]},
		{com: "教育", server: [
			{name: "教育网专区", id: "教育一"}
		]}
	];

	property variant _Tags: [
		"全部",
		"新手",
		"战士",
		"法师",
		"刺客",
		"坦克",
		"辅助",
		"射手"
	];

	property variant _Location: [
		"全部",
		"上单",
		"中单",
		"ADC",
		"打野",
		"辅助"
	];

	property variant _Price: [
		"全部",
		"金币 450",
		"金币 1350",
		"金币 3150",
		"金币 4800",
		"金币 6300",
		"点劵 1000",
		"点劵 1500",
		"点劵 2000",
		"点劵 2500",
		"点劵 3000",
		"点劵 3500",
		"点劵 4000",
		"点劵 4500"
	];

	property variant _ItemTypeModel: ListModel{
		ListElement{
			name: "全部";
			value: "all";
		}
		ListElement{
			name: "工资装";
			value: "GoldPer";
		}
		ListElement{
			name: "视野";
			value: "Vision";
		}
		ListElement{
			name: "移动速度";
			value: "movement";
		}
		ListElement{
			name: "法力值";
			value: "mana";
		}
		ListElement{
			name: "法力值增长";
			value: "mana_regen";
		}
		ListElement{
			name: "生命值";
			value: "health";
		}
		ListElement{
			name: "生命值增长";
			value: "health_regen";
		}
		ListElement{
			name: "暴击几率";
			value: "critical_strike";
		}
		ListElement{
			name: "法术强度";
			value: "spell_damage";
		}
		ListElement{
			name: "护甲";
			value: "armor";
		}
		ListElement{
			name: "魔法抗性";
			value: "spell_block";
		}
		ListElement{
			name: "物理伤害";
			value: "damage";
		}
		ListElement{
			name: "冷却缩减";
			value: "cooldown_reduction";
		}
		ListElement{
			name: "其他";
			value: "other";
		}
	}
}
