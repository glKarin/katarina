.pragma library

function castMS2S(t) {
	var format = "mm:ss";
	if(t >= 3600000){
		return parseInt(t / 3600000) + ":" + Qt.formatTime(new Date(t % 3600000), format);
	}else{
		return Qt.formatTime(new Date(t % 3600000), format);
	}
}

function isFunction(func) {
	return typeof(func) === "function";
	/*
	try {
		if (typeof(eval(funcName)) == "function") {
			return true;
		}
	} catch(e) {}
	return false;
	*/
}

function setText(model, name, value, allowNull, defValue)
{
	if(!model)
		return;
	if(allowNull === undefined)
		allowNull = false;
	if(!allowNull)
	{
		if(value && value !== "")
			model.append({name: name, value: value});
	}
	else
	{
		if(defValue === undefined)
			defValue = "";
		model.append({name: name, value: value || defValue});
	}
}
