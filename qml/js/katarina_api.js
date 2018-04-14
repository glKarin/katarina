.pragma library

var KatarinaAPI = {
	Version: "http://box.dwstatic.com/upgrade/version.php", //?version=300&versionName=3.0.0&isAutoRequest=1
	Heroes: "http://lolbox.duowan.com/phone/apiHeroes.php", //type=free|all
	HeroDetail: "http://lolbox.duowan.com/phone/apiHeroDetail.php",//heroName=enName
	HeroSkins: "http://box.dwstatic.com/apiHeroSkin.php", //hero=enName
	HeroSounds: "http://box.dwstatic.com/apiHeroSound.php", //hero=enName
	HeroVideos: "http://box.dwstatic.com/apiVideoesNormalDuowan.php", //?src=duowan&action=l&sk=&pageUrl=&heroEnName=Katarina&tag=Katarina&p=5&withCategory=1
	VideoDetail: "http://box.dwstatic.com/apiVideoesNormalDuowan.php", //?action=f&vid=1399695
	PlayerAllHeroes: "http://lolbox.duowan.com/new/api/index.php",// ?_do=personal/championslist&serverName=%E6%B0%B4%E6%99%B6%E4%B9%8B%E7%97%95&playerName=%E5%89%91%E5%AE%A2fj
	Items: "http://lolbox.duowan.com/phone/apiZBItemList.php", //tag=all
	ItemDetail: "http://lolbox.duowan.com/phone/apiItemDetail.php", //id=
	PlayerMatchInfo: "http://lolbox.duowan.com/phone/playerDetailNew.php",

	NewsTags: "http://box.dwstatic.com/apiNewsList.php", //?action=c
	NewsList: "http://box.dwstatic.com/apiNewsList.php", //action=l&newsTag=upgradenews&p=1
	NewsDetail: "http://box.dwstatic.com/newsDetailShare.php", //?newsId=22716&lolBoxAction=toNewsDetail
	AlbumList: "http://box.dwstatic.com/apiAlbum.php", //?action=l&albumTag=bw&p=1
	AlbumDetail: "http://tu.duowan.cn/gallery/%1.html",

	PlayerBaseInfo: "http://api.xunjob.cn/playerinfo.php", //?playerName=serverName="
	PlayerRankInfo: "http://API.xunjob.cn/s5str.php", //?playerName=玩家名&serverName=服务器id,
	PlayerRecentHeroes: "http://API.xunjob.cn/hero.php", //?serverName=服务器名&playerName=玩家名

	ItemPic: "http://img.lolbox.duowan.com/zb/%1_64x64.png",
	AbilityPic: "http://img.lolbox.duowan.com/abilities/%1_%2_64x64.png",
	HeroPic: "http://img.lolbox.duowan.com/champions/%1_120x120.jpg",
	BigSkinPic: "http://box.dwstatic.com/skin/%1/%1_Splash_%2.jpg",
	SmallSkinPic: "http://box.dwstatic.com/skin/%1/%1_%2.jpg",

	LolKingModels: "http://www.lolking.net/models",
	LolKingIcons: "http://lkimg.zamimg.com/images/v2/champions/icons/size100x100/%1.png"
}
