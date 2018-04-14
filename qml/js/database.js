.pragma library

var katarina_database = function(name, version, desc, size){

	var db = openDatabaseSync(name, version, "", desc, size);

	this._create_table = function(tname, targs){
		var dropSql = "DROP TABLE IF EXISTS %1";
		var createSql = "CREATE TABLE IF NOT EXISTS %1 (%2)";
		if (db.version !== version){
			try{
				var change = function (ta){
					ta.executeSql(dropSql.arg(tname));
					ta.executeSql(createSql.arg(tname).arg(targs));
				}
				db.changeVersion(db.version, version, change);
			}catch(e)
			{
				console.log("Throw exception when change table %1 version '%2' to '%3'.\n - %4".arg(tname).arg(db.version).arg(version).arg(e));
			}
		} else {
			try{
				var trans = function(ta){
					ta.executeSql(createSql.arg(tname).arg(targs));
				}
				db.transaction(trans);
			}catch(e){
				console.log("Throw exception when execute SQL: [%1].\n - %2".arg(createSql.arg(tname).arg(targs)).arg(e));
			}
		}
	}

	this._insert = function(tname, argv){
		var sql = "INSERT OR REPLACE INTO %1 (%2) VALUES (%3)";
		var proto = [];
		var values = [];
		for(var i in argv){
			proto.push(i);
			values.push(argv[i]);
		}
		try{
			db.transaction(function(ta){
				ta.executeSql(sql.arg(tname).arg(proto.join(", ")).arg(values.join(", ")));
			});
		}catch(e){
			console.log("Throw exception when execute SQL: [%1].\n - %2".arg(sql.arg(tname).arg(proto.join(",")), values.join(",")).arg(e));
		}
	}

	this._qselect = function(tname, model, desc){
		var sql = "SELECT * FROM %1";
		if(desc === undefined)
			desc = false;
		try{
			db.readTransaction(function(ta){
				var rd = ta.executeSql(sql.arg(tname));
				if(desc)
					for (var i = rd.rows.length - 1; i >= 0; i --){
						var item = rd.rows.item(i);
						model.append(item);
					}
				else
					for (var i = 0; i < rd.rows.length; i++){
						var item = rd.rows.item(i);
						model.append(item);
					}
			});
		}catch(e){
			console.log("Throw exception when execute SQL: [%1] into ListModel.\n - %2".arg(sql.arg(tname)).arg(e));
		}
	}

	this._select = function(tname, desc){
		var sql = "SELECT * FROM %1";
		if(desc === undefined)
			desc = false;
		var tmp = [];
		try{
			db.readTransaction(function(ta){
				var rd = ta.executeSql(sql.arg(tname));
				if(desc)
					for (var i = rd.rows.length - 1; i >= 0; i --){
						var item = rd.rows.item(i);
						tmp.push(item);
					}
				else
					for (var i = 0; i < rd.rows.length; i++){
						var item = rd.rows.item(i);
						tmp.push(item);
					}
			});
		}catch(e){
			console.log("Throw exception when execute SQL: [%1] into JS Array.\n - %2".arg(sql.arg(tname)).arg(e));
		}
		return tmp;
	}

	this._get = function(tname, column, argv){
		var sql = "SELECT %1 FROM %2 WHERE %3";
		var proto = [];
		for(var i in argv){
			proto.push(i + " = " + argv[i]);
		}
		var rd = null;
		try{
			db.readTransaction(function(ta){
				rd = ta.executeSql(sql.arg(tkey).arg(tname).arg(proto.join(" and "))).rows.item(0)[column];
			});
		}catch(e){
			console.log("Throw exception when selectexecute SQL: [%1].\n - %2".arg(sql.arg(tkey).arg(tname).arg(proto.join(" and "))).arg(e));
		}
		return rd;
	}

	this._delete = function(tname, argv){
		var sql = "DELETE FROM %1 WHERE %2";
		var proto = [];
		for(var i in argv){
			proto.push(i + " = " + argv[i]);
		}
		try{
			db.transaction(function(ta){
				ta.executeSql(sql.arg(tname).arg(proto.join(" and ")));
			});
		}catch(e){
			console.log("Throw exception wheexecute SQL: [%1].\n - %2".arg(sql.arg(tname).arg(proto.join(" and "))).arg(e));
		}
	}

	this._remove = function(tname){
		var sql = "DELETE FROM %1";
		try{
			db.transaction(function(ta){
				ta.executeSql(sql.arg(tname));
			});
		}catch(e){
			console.log("Throw exception wheexecute SQL: [%1].\n - %2".arg(sql.arg(tname)).arg(e));
		}
	}

	this._count = function(tname){
					var sql = "SELECT COUNT(1) AS c FROM %1";
		var rd = 0;
		try{
			db.readTransaction(function(ta){
				try{
					rd = ta.executeSql(sql.arg(tname)).rows.item(0)["c"];
				}catch(e){
					rd = 0;
				}
			});
		}catch(e){
			console.log("Throw exception when execute SQL: [%1].\n - %2".arg(sql.arg(tname)).arg(e));
		}
		return rd;
	}

	this._drop_table = function(){
		var sql = "DROP TABLE IF EXISTS %1";
		try{
			db.readTransaction(function(ta){
				ta.executeSql(sql.arg(tname));
			});
		}catch(e){
			console.log("Throw exception when execute SQL: [%1].\n - %2".arg(sql.arg(tname)).arg(e));
		}
	}
}
