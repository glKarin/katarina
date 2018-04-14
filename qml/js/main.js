.pragma library

Qt.include("network_manager.js")
Qt.include("katarina_api.js");
Qt.include("database.js");

var db = new katarina_database("katarina", "1.0", "Katarina Datebase", 5 * 1024 * 1024);

function init(s){
	db._create_table('player_search_history', 'player_name TEXT NOT NULL, server_name TEXT NOT NULL, server_id TEXT NOT NULL, PRIMARY KEY(player_name, server_name, server_id)');
}

function tbQSelect(name, model, desc){
	if(name && model)
		db._qselect(name, model, desc);
}

function tbInsert(name, item){
	if(name && item)
		db._insert(name, item);
}

function tbDelete(name, argv){
	if(name && argv)
		db._delete(name, argv);
}

function tbGet(name, column, argv){
	if(name && column && argv)
		return db._get(name, column, argv);
}

function tbRemove(name){
	if(name)
		db._remove(name);
}

function tbCount(name){
	if(name)
		return db._count(name);
}

function callAPI(api, success, fail, args, method, headers){
	var url = api.indexOf("/") !== -1 || api.indexOf(".") !== -1 ? api : KatarinaAPI[api];
	if(!method)
		method = "GET";
	var request = new NetworkRequest(method, url);
	if(args){
		request.addParameters(args);
	}
	if(headers){
		request.addHeaders(headers);
	}
	request.sendRequest(success, fail);
	return request.url;
}

function getHeroPic(name){
	return KatarinaAPI["HeroPic"].arg(name);
}

function getUnsupportUrlContent(url)
{
	var link = url.toString();
	var actionFieldName = {
		videoPlay: "vid",
		toHeroDetail: "heroEnName",
		toZBDetail: "zbId",
		toNewsTopic: "topicId"
	};

	//console.log("_" + link);
	var urlRegExp = /^http:\/\/box\.dwstatic\.com\/unsupport\.php\?(.+)/;
	if(!urlRegExp.test(link))
		return null;
	var argStr = link.match(urlRegExp)[1];
	var argArr = argStr.split("&");
	var argObj = ({});
	argArr.forEach(function(e){
		var arr = e.split("=");
		argObj[arr[0]] = arr[1] || "";
	});

	var action = "lolboxAction";

	var actionValue = argObj[action];
	if(actionValue)
	{
		var item = {
			type: actionValue,
			value: argObj[actionFieldName[actionValue]]
		}
	console.log(item.type +"_" + item.value);
		return item;
	}
	return null;
}

function getAPI(api, args){
	var url = KatarinaAPI[api];
	var optStr = "";
	if(args){
		var arga = [];
		for(var i in args){
			arga.push(i + "=" + args[i]);;
		}
		optStr = arga.join("&");
	}
	return(url + (optStr && optStr !== "" ? '?' + optStr : ""));
}

function getSkinPic(name, id, size){
	if(!size)
		size = "big";
	if(!id || !Number.isNumber(id))
		id = 0;
	var api = size === "big" ? "BigSkinPic" : "SmallSkonPic";
	return KatarinaAPI[api].arg(name).arg(id);
}

function getAbilityPic(name, ability)
{
	return KatarinaAPI["AbilityPic"].arg(name).arg(ability);
}

function getEnTagName(cnName)
{
	var enName;
	switch(cnName)
	{
		case "坦克":
			enName = "tank";
			break;
		case "战士":
			enName = "fighter";
			break;
		case "法师":
			enName = "mage";
			break;
		case "射手":
			enName = "marksman";
			break;
		case "刺客":
			enName = "assassin";
			break;
		case "辅助":
			enName = "support";
			break;
		case "新手":
			enName = "female";
			break;
		default:
			enName = cnName;
			break;
	}
	return enName;
}

function getHeroes(obj, model)
{
	if(!obj)
		return;
	var res = [];
	if(Array.isArray(obj))
	{
		obj.forEach(function(e){
			var item = {
				cnName: e.cnName || "",
				enName: e.enName || "",
				title: e.title || "",
				tags: e.tags.split(",") || [],
				"location": e["location"].split(",") || [],
				price: ["金币 " + e.price.split(",")[0] || "金币 0", "点劵 " + e.price.split(",")[1] || "点劵 0"]
			};
			if(model)
				model.append(item);
			else
				res.push(item);
		});
	}
	if(!model)
		return res;
}

function getHeroDetail(obj)
{
	if(!obj)
		return null;
	var name = obj.name;

	//description
	var description = {
		name: obj.name || "",
		displayName: obj.displayName + " " + obj.title || "",
		description: obj.description || "",
		tags: obj.tags || "",
		price: obj.price || ","
	};

	//ability
	var ability = {
		B: obj[name + "_B"],
		Q: obj[name + "_Q"],
		W: obj[name + "_W"],
		E: obj[name + "_E"],
		R: obj[name + "_R"]
	};

	//property
	var propArr = [
		"health", "healthRegen", 
		"mana", "manaRegen", 
		"armor", "magicResist", 
		"attack", "criticalChance",
		"moveSpeed", "range",
		"ratingDefense", "ratingMagic",
		"ratingDifficulty", "ratingAttack"
	];
	var prop = ({});
	propArr.forEach(function(e){
		var p = ({});
		if(obj[e])
			p[e] = obj[e];
		else
		{
			p[e + "Base"] =  obj[e + "Base"];
			p[e + "Level"] = obj[e + "Level"];
		}
		prop[e] = p;
	});

	var tips = {
		tips: obj["tips"],
		opponentTips: obj["opponentTips"]
	};

	var relation = {
		like: obj["like"],
		hate: obj["hate"]
	}

	var detail = {
		description: description,
		ability: ability,
		prop: prop,
		tips: tips,
		relation: relation
	};
	return detail;
}

function getHeroSkin(obj, model)
{
	if(!obj || !model)
		return;
	if(Array.isArray(obj)){
		obj.forEach(function(e){
			var item = {
				name: e.name || "",
				smallImg: e.smallImg || "",
				bigImg: e.bigImg || ""
			};
			model.append(item);
		});
	}
}

function getHeroSounds(obj, model)
{
	if(!model || !obj)
		return;
	if(Array.isArray(obj))
	{
		obj.forEach(function(e){
			var item = {
				sound: e || ""
			};
			model.append(item);
		});
	}
}

function getSoundName(name, path)
{
	if(!name || !path)
		return"";
	var regExp = new RegExp(name + "_(.*){1}\.mp3");
	if(path.match(regExp))
		return path.match(regExp)[1];
	else
		return name;
}

function getHeroVideos(obj, model)
{
	if(!obj || !model)
		return 0;
	var totalPage = 0;
	if(Array.isArray(obj))
	{
		obj.forEach(function(e){
			var item = {
				vid: e.vid || "",
				cover_url: e.cover_url || "",
				title: e.title || "",
				upload_time: e.upload_time || "",
				play_count: e.play_count || 0
			};
			model.append(item);
			totalPage = e.totalPage;
		});
		return totalPage;
	}
}

function getVideoStream(obj, model, sort)
{
	if(!obj || !model)
		return;
	var items = obj.items;
	if(!items)
		return;
	if(sort === undefined)
		sort = false;
	for(var i in items)
	{
		var e = items[i];
		var arr = [];
		if(e.transcode && e.transcode.urls)
		{
			var urls = e.transcode.urls;
			for(var j = 0; j < urls.length; j++)
			{
				arr.push({index: j, urls: urls[j]});
			}
		}
		var ele = {
			task_name: e.task_name || "",
			task_value: i || "",
			transcode: arr
		}
		model.append(ele);
		if(sort)
		{
			for(var i = 0; i < model.count - 1; i++)
				for(var j = i + 1; j < model.count; j++)
					if(Number(model.get(j).task_value) < Number(model.get(i).task_value))
						model.move(j, i, 1);
		}
	}
}

function getPlayerBaseInfo(obj)
{
	if(!obj)
		return null;
	if(obj.message == 1)
	{
		var baseInfo = {
			portrait: obj.portrait || "",
			level: obj.level || 0,
			zhandouli: obj.zhandouli || 0,
			good: obj.good || "0"
		};
		return baseInfo;
	}
	return null;
}

function getPlayerRankInfo(obj)
{
	if(!obj)
		return null;
	if(!obj.tier && !obj.rank)
		return null;
	return obj;
}

function getPlayerHeroes(obj, model)
{
	if(!obj || !model)
		return;
	if(Array.isArray(obj))
	{
		obj.forEach(function(e){
			var item = {
				championName: e.championName,
				championNameCN: e.championNameCN,
				averageK: e.averageKDA[0],
				averageD: e.averageKDA[1],
				averageA: e.averageKDA[2],
				averageKDARating: e.averageKDARating,
				winRate: e.winRate,
				matchStat: e.matchStat,
				averageMinionsKilled: e.averageMinionsKilled,
				averageDamage: e.averageDamage,
				averageEarn: e.averageEarn,
				totalMVP: e.totalMVP
			};
			model.append(item);
		});
	}
}

function getItems(obj)
{
	if(obj && Array.isArray(obj))
		return obj;
	return null;
}

function getItemPic(id)
{
	return KatarinaAPI["ItemPic"].arg(id);
}

function getItemInfo(obj)
{
	return obj;
}

function getNewsTags(obj, model)
{
	if(!obj || !model)
		return;
	if(Array.isArray(obj))
	{
		obj.forEach(function(e){
			model.append(e);
		});
	}
}

function getNewsList(obj, model)
{
	if(!obj || !model)
		return;
	if(Array.isArray(obj))
	{
		obj.forEach(function(e){
			var item = {
				title: e.title,
				content: e.content,
				time: Qt.formatDate(new Date(parseInt(e.time) * 1000), "yyyy-MM-dd"),
				type: e.type,
				id: e.type === "topic" ? e.destUrl.match(/^http:\/\/box\.dwstatic\.com\/unsupport\.php\?newsId=([0-9]+)&lolboxAction=toNewsTopic&topicId=([0-9]+)/)[2] : e.id,
				photo: e.photo,
				videoList: e.hasVideo !== 0 ? (e.videoList || []) : null
			};
			model.append(item);
		});
	}
}

function getTopicDetail(obj, model)
{
	if(!obj || !model)
		return;
	if(Array.isArray(obj))
	{
		obj.forEach(function(e){
			var item = {
				title: e.title,
				type: e.type,
				data: e.data || {news: []},
				url: e.url || ""
			};
			model.append(item);
		});
	}
}

function getAlbumList(obj, model)
{
	if(!obj || !model)
		return;
	if(Array.isArray(obj))
	{
		obj.forEach(function(e){
			var item = {
				galleryId: e.galleryId,
				title: e.title,
				coverUrl: e.coverUrl,
				updated: Qt.formatDate(new Date(parseInt(e.updated) * 1000), "yyyy-MM-dd"),
				type: e.type,
				coverWidth: parseInt(e.coverWidth) || 0,
				coverHeight: parseInt(e.coverHeight) || 0
			};
			model.append(item);
		});
	}
}

function getGalleryUrl(id)
{
	return KatarinaAPI["AlbumDetail"].arg(id);
}

function getAlbumDetail(html, model)
{
	if(!html || !model)
		return false;
	if(html === "")
		return false;
	var regExp = /(?:\nvar imgJson = )(.+);\n/;
	try
	{
		var res = JSON.parse(html.match(regExp)[1]);
		if(res){
			if(Array.isArray(res.picInfo))
			{
				res.picInfo.forEach(function(e){
					var item = {
						title: e.title,
						url: e.url,
						file_width: parseInt(e.file_width),
						file_height: parseInt(e.file_height),
						comment_url: e.comment_url
					};
					model.append(item);
				});
				return true;
			}
		}
	}
	catch(e)
	{
		console.log(JSON.stringify(e));
		return false;
	}
	return false;
}

function getModelList(html, model)
{
	var championSelect = /<select name="champion".*?>([\s\S]+?)<\/select>/m;
	var championSelectRes =  html.match(championSelect);
	if(!championSelectRes)
		return;
	var championOption = /<option value="(\d+?)">(.*?)<\/option>/;
	var arr = championSelectRes[0].split(/[\r\n]+?/);
	arr.forEach(function(e){
		var championOptionRes = e.match(championOption);
		if(championOptionRes)
		{
			var item = {
				id: championOptionRes[1],
				name: championOptionRes[2]
			};
			model.append(item);
		}
	});
	var championSkins = {};
	var championSkinsVar = /championSkins\[\d+?\].*=.*;/g;
	var championSkinsArr = html.match(championSkinsVar);
	for(var i in championSkinsArr)
		eval(championSkinsArr[i]);
	return championSkins;
}

function getLolKingHeroPic(id){
	return KatarinaAPI["LolKingIcons"].arg(id);
}

