(function (console, $global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.dateStr = function(date) {
	var m = date.getMonth() + 1;
	var d = date.getDate();
	var h = date.getHours();
	var mi = date.getMinutes();
	var s = date.getSeconds();
	return date.getFullYear() + "-" + (m < 10?"0" + m:"" + m) + "-" + (d < 10?"0" + d:"" + d) + " " + (h < 10?"0" + h:"" + h) + ":" + (mi < 10?"0" + mi:"" + mi) + ":" + (s < 10?"0" + s:"" + s);
};
var MainElectron = function() {
	var main = new MainServer();
	var mainWindow = null;
	electron_main_App.on("window-all-closed",function() {
		electron_main_App.quit();
	});
	electron_main_App.on("ready",function() {
		mainWindow = new electron_main_BrowserWindow({ resizable : false, width : 325, height : 730, center : true, minWidth : 325, minHeight : 730, title : "Playrr"});
		mainWindow.loadURL("http://localhost:3000");
		mainWindow.on("closed",function() {
			mainWindow = null;
		});
	});
};
MainElectron.__name__ = true;
MainElectron.main = function() {
	var main = new MainElectron();
};
MainElectron.prototype = {
	__class__: MainElectron
};
var MainServer = function() {
	this.currentPlaylistID = 0;
	var _g = this;
	console.log("\n\n\n\n\n\n\n\n\n\n");
	console.log("\n--------------- " + Std.string(new Date()) + " --------------- \n");
	console.log("Express website: open browser at " + model_AppConstants.IP + ":" + model_AppConstants.PORT);
	console.log("Stop node.js : CTRL + c");
	this.spotify = new api_spotify_SpotifyApi();
	this.youtube = new api_youtube_YoutubeApi();
	var checkInstall = new utils_CheckInstall();
	var app = new js_npm_Express();
	var server = js_node_Http.createServer(app);
	var io = new js_npm_socketio_Server(server);
	var options = { filename : js_node_Path.join(__dirname,"/public/_db/relatedartists.ddb"), autoload : true};
	this._dbRelatedArtists = new js_npm_NeDB(options);
	var options1 = { filename : js_node_Path.join(__dirname,"/public/_db/toptracks.ddb"), autoload : true};
	this._dbTopTracks = new js_npm_NeDB(options1);
	var options2 = { filename : js_node_Path.join(__dirname,"/public/_db/currentartist.ddb"), autoload : true};
	this._dbCurrentArtist = new js_npm_NeDB(options2);
	var options3 = { filename : js_node_Path.join(__dirname,"/public/_db/playlist.ddb"), autoload : true};
	this._dbPlaylist = new js_npm_NeDB(options3);
	var options4 = { filename : js_node_Path.join(__dirname,"/public/_db/config.ddb"), autoload : true, timestampData : true};
	this._dbConfig = new js_npm_NeDB(options4);
	this.spotify.on("error",function(str) {
		console.log(MainServer.SERVER + "oeps ERROR : " + str);
		_g._socket.emit(model_SocketConstants.ERROR);
	});
	app.set("port",model_AppConstants.PORT);
	app.set("views",__dirname + "/public/views");
	app.set("view engine","jade");
	app["use"](new js_npm_express_Favicon(__dirname + "/public/favicon.ico"));
	app["use"](new js_npm_express_Morgan("dev"));
	app["use"](js_npm_express_BodyParser.json());
	app["use"](js_npm_express_BodyParser.urlencoded({ extended : true}));
	app["use"](new js_npm_express_Static(js_node_Path.join(__dirname,"public")));
	app.get("/",function(req,res) {
		res.sendfile(__dirname + "/public/index_advanced.html");
	});
	app["use"](function(req1,res1,next) {
		res1.status(404).send("404");
	});
	io.on("connection",function(socket) {
		_g._socket = socket;
		socket.emit("message",{ message : "welcome to Party Playrr"});
		socket.on("send",function(data) {
			io.sockets.emit("message",data);
		});
		socket.on(model_SocketConstants.SCREEN,function(e) {
			console.log(MainServer.SERVER + "hello from client");
			_g.resetInterface();
			_g.lastTrackPlayed();
			_g.lastPlaylist();
		});
		socket.on(model_SocketConstants.SEARCH,function(data1) {
			_g.getArtistProfileList(data1);
		});
		socket.on(model_SocketConstants.SEARCH_WITH_ID,function(data2) {
			console.log(MainServer.SERVER + "## YOYYOOOO");
			_g.currentPlaylistID = 1;
			var vo = new model_StoreVO(data2);
			vo._id = 1;
			_g._dbPlaylist.remove({ },{ multi : true},function(err,numRemoved) {
				_g._dbPlaylist.loadDatabase(function(err1) {
				});
			});
			_g._dbPlaylist.insert(vo);
			_g.noIdeaHowToCallThisFunction(data2.id);
		});
		socket.on(model_SocketConstants.NEXT_TRACK,function(e1) {
			console.log(MainServer.SERVER + ":: NEXT TRACK :: TODO :: -------------- e: " + Std.string(e1));
			console.log(MainServer.SERVER + "currentPlaylistID: " + _g.currentPlaylistID);
			_g.currentPlaylistID++;
			_g._dbPlaylist.find({ _id : _g.currentPlaylistID},function(err2,docs) {
				console.log(" | docs.length: " + docs.length);
				console.log(" | docs[0]: " + Std.string(docs[0]));
				if(docs.length <= 0) {
					console.log(MainServer.SERVER + "ERROR > WHAT TO DO NEXT?");
					_g.currentPlaylistID = 0;
					var s = new model_SearchVO();
					io.sockets.emit(model_SocketConstants.NEXT_TRACK,s);
					return;
				}
				_g.getArtistTopTracks(docs[0].id);
			});
		});
		socket.on(model_SocketConstants.PREV_TRACK,function(e2) {
			console.log(MainServer.SERVER + ":: PREVIOUS TRACK :: TODO :: -------------- e: " + Std.string(e2));
		});
	});
	console.log(MainServer.SERVER + "Listening on port " + model_AppConstants.PORT);
	server.listen(app.get("port"),function() {
		console.log(MainServer.SERVER + "Express server listening on port " + Std.string(app.get("port")));
	});
};
MainServer.__name__ = true;
MainServer.prototype = {
	resetInterface: function() {
		console.log(MainServer.SERVER + "TODO!");
	}
	,lastPlaylist: function() {
		var _g = this;
		console.log(MainServer.SERVER + "+ lastPlaylist");
		this._dbPlaylist.find({ _id : 1},function(err,docs) {
			console.log(" | err: " + Std.string(err));
			console.log(" | docs.length: " + docs.length);
			console.log(" | docs[0]: " + Std.string(docs[0]));
			if(docs.length == 0 || err != null) return;
			_g._socket.emit(model_SocketConstants.CURRENT,null);
		});
	}
	,lastTrackPlayed: function() {
		var _g = this;
		console.log(MainServer.SERVER + "+ lastTrackPlayed");
		this._dbTopTracks.find({ _id : 1},function(err,docs) {
			console.log(" | err: " + Std.string(err));
			console.log(" | docs.length: " + docs.length);
			console.log(" | docs[0]: " + Std.string(docs[0]));
			if(docs.length == 0 || err != null) {
				console.log("NO FIRST TRACK");
				_g._socket.emit(model_SocketConstants.PLAYER,"/sfx/chime_tone.mp3");
			} else {
				var track = docs[0];
				_g.getRelatedArtists(track.artists[0].id);
				_g.searchYoutube(track);
				_g._socket.emit(model_SocketConstants.PROFILE_UPDATE,track);
			}
		});
	}
	,noIdeaHowToCallThisFunction: function(id,data) {
		if(data != null) console.log(MainServer.SERVER + "---------->> data: " + Std.string(data));
		this.getRelatedArtists(id);
		this.getArtistTopTracks(id);
	}
	,getArtistProfileList: function(searchVO) {
		var _g = this;
		console.log(MainServer.SERVER + "getArtistProfileList :: name: " + searchVO.name);
		this.spotify.searchArtists(searchVO.name,{ limit : model_AppConstants.SPOTIFY_SEARCH_LIMIT, offset : 0});
		this.spotify.once("searchArtists",function(arr) {
			_g._socket.emit(model_SocketConstants.SEARCH_RESULTS,arr);
			console.log("\n--------- Search for artist ----------");
			var _g2 = 0;
			var _g1 = arr.length;
			while(_g2 < _g1) {
				var i = _g2++;
				var artist = arr[i];
				console.log("" + i + ". " + decodeURIComponent(artist.name.split("+").join(" ")) + " - " + artist.id);
			}
			console.log("\n");
			if(arr.length == 1) {
				var data = arr[0];
				_g.noIdeaHowToCallThisFunction(data.id,data);
			}
		});
	}
	,getRelatedArtists: function(id) {
		var _g = this;
		console.log(MainServer.SERVER + "getRelatedArtists :: id: " + id);
		this._dbRelatedArtists.remove({ },{ multi : true},function(err,numRemoved) {
			_g._dbRelatedArtists.loadDatabase(function(err1) {
			});
		});
		this.spotify.getArtistRelatedArtists(id);
		this.spotify.once("getArtistRelatedArtists",function(json,arr) {
			_g._socket.emit(model_SocketConstants.SEARCH_RESULTS,arr);
			console.log("\n--------- Related artists ----------");
			var _g2 = 0;
			var _g1 = arr.length;
			while(_g2 < _g1) {
				var i = _g2++;
				var artist = arr[i];
				console.log("" + i + ". " + artist.name + " - " + artist.id);
				artist._id = i + 1;
				_g._dbRelatedArtists.insert(artist);
				var _vo = new model_StoreVO();
				_vo.name = artist.name;
				_vo.id = artist.id;
				_vo._id = i + 2;
				_vo.spotifyArtist = artist;
				_g._dbPlaylist.insert(_vo);
			}
			console.log("\n");
		});
	}
	,getArtistTopTracks: function(id) {
		var _g = this;
		console.log(MainServer.SERVER + "getArtistTopTracks :: id: " + id);
		this._dbTopTracks.remove({ },{ multi : true},function(err,numRemoved) {
			_g._dbTopTracks.loadDatabase(function(err1) {
			});
		});
		this.spotify.getArtistTopTracks(id);
		this.spotify.once("getArtistTopTracks",function(json,arr) {
			_g._socket.emit(model_SocketConstants.TOP_RESULTS,arr);
			console.log("\n--------- Artist Top Tracks ----------");
			var _g2 = 0;
			var _g1 = arr.length;
			while(_g2 < _g1) {
				var i = _g2++;
				var track = arr[i];
				console.log("" + i + ". " + decodeURIComponent(track.name.split("+").join(" ")) + " - " + track.id);
				track._id = i + 1;
				_g._dbTopTracks.insert(track);
			}
			_g._dbCurrentArtist.insert(arr[0]);
			_g._socket.emit(model_SocketConstants.PROFILE_UPDATE,arr[0]);
			console.log("\n");
			_g.searchYoutube(arr[0]);
		});
	}
	,searchYoutube: function(track) {
		var _g = this;
		console.log(MainServer.SERVER + "searchYoutube :: track.artists[0].name: " + track.artists[0].name);
		console.log(MainServer.SERVER + "searchYoutube :: track.name: " + decodeURIComponent(track.name.split("+").join(" ")));
		this.youtube.search(track.artists[0].name + " " + decodeURIComponent(track.name.split("+").join(" ")),model_AppConstants.YOUTUBE_SEARCH_LIMIT);
		this.youtube.once("SEARCH_ARTISTS",function(json,arr) {
			console.log("\n--------- Youtube search results ----------");
			if(arr.length == 0) console.log("OHHHHH no search");
			var count = 0;
			var notUndefinend = [];
			var _g1 = 0;
			var _g2 = arr.length;
			while(_g1 < _g2) {
				var i = _g1++;
				var searchItem = arr[i];
				console.log("" + i + ". " + searchItem.snippet.title + " - " + searchItem.id.videoId);
				if(searchItem.id.videoId != null) notUndefinend.push(searchItem);
			}
			console.log("\n");
			_g._socket.emit(model_SocketConstants.YOU_PLAYER,encodeURIComponent(notUndefinend[count].id.videoId));
		});
	}
	,__class__: MainServer
};
Math.__name__ = true;
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
var js_node_events_EventEmitter = require("events").EventEmitter;
var api_spotify_SpotifyApi = function() {
	console.log("Start SpotifyApi");
	js_node_events_EventEmitter.call(this);
	var obj = { clientId : model_AppConstants.SPOTIFY_CLIENT_ID, clientSecret : model_AppConstants.SPOTIFY_CLIENT_SECRET};
	this.spotifyApi = new js_npm_SpotifyWebApiNode(obj);
};
api_spotify_SpotifyApi.__name__ = true;
api_spotify_SpotifyApi.__super__ = js_node_events_EventEmitter;
api_spotify_SpotifyApi.prototype = $extend(js_node_events_EventEmitter.prototype,{
	searchArtists: function(q,options) {
		var _g = this;
		if(options == null) options = { limit : 50, offset : 0};
		this.spotifyApi.searchArtists(q,options,function(err,data) {
			if(err != null) {
				console.log("Something went wrong!" + err);
				_g.emit("error","searchArtists : error: " + err);
			} else {
				var _json = data;
				var arr = _json.body.artists.items;
				_g.urlEncodeArtistArray(arr);
				_g.emit("searchArtists",arr);
			}
		});
	}
	,getArtistRelatedArtists: function(id) {
		var _g = this;
		this.spotifyApi.getArtistRelatedArtists(id,function(err,data) {
			if(err != null) {
				console.log("Something went wrong!" + err);
				_g.emit("error","getArtistRelatedArtists : error: " + err);
			} else {
				var _json = data;
				var arr = _json.body.artists;
				_g.urlEncodeArtistArray(arr);
				_g.emit("getArtistRelatedArtists",_json,arr);
			}
		});
	}
	,getArtistTopTracks: function(id,iso) {
		if(iso == null) iso = "NL";
		var _g = this;
		this.spotifyApi.getArtistTopTracks(id,"NL",function(err,data) {
			if(err != null) {
				console.log("Something went wrong!" + err);
				_g.emit("error","getArtistTopTracks : error: " + err);
			} else {
				var _json = data;
				var arr = _json.body.tracks;
				_g.urlEncodeArtistTopTrackArray(arr);
				_g.emit("getArtistTopTracks",_json,arr);
			}
		});
	}
	,urlEncodeArtistTopTrackArray: function(arr) {
		var _g1 = 0;
		var _g = arr.length;
		while(_g1 < _g) {
			var i = _g1++;
			var toptracks = arr[i];
		}
	}
	,urlEncodeArtistArray: function(arr) {
		var _g1 = 0;
		var _g = arr.length;
		while(_g1 < _g) {
			var i = _g1++;
			var artist = arr[i];
			this.urlEncodeArtist(artist);
		}
	}
	,urlEncodeArtist: function(artist) {
		artist.name_urlencode = encodeURIComponent(artist.name);
	}
	,__class__: api_spotify_SpotifyApi
});
var api_youtube_YoutubeApi = function() {
	this.youTube = new js_npm_YoutubeNode();
	console.log("Start YoutubeApi");
	js_node_events_EventEmitter.call(this);
	this.youTube.setKey(model_AppConstants.YOUTUBE_API_KEY);
};
api_youtube_YoutubeApi.__name__ = true;
api_youtube_YoutubeApi.__super__ = js_node_events_EventEmitter;
api_youtube_YoutubeApi.prototype = $extend(js_node_events_EventEmitter.prototype,{
	search: function(q,limit) {
		if(limit == null) limit = 10;
		var _g = this;
		this.youTube.search(q,limit,function(err,data) {
			if(err != null) {
				console.log("Something went wrong!" + err);
				_g.emit("error","youtube search : error: " + err);
			} else {
				var _json = data;
				var arr = _json.items;
				_g.emit("SEARCH_ARTISTS",_json,arr);
			}
		});
	}
	,__class__: api_youtube_YoutubeApi
});
var electron_main_App = require("app");
var electron_main_BrowserWindow = require("browser-window");
var haxe__$Int64__$_$_$Int64 = function(high,low) {
	this.high = high;
	this.low = low;
};
haxe__$Int64__$_$_$Int64.__name__ = true;
haxe__$Int64__$_$_$Int64.prototype = {
	__class__: haxe__$Int64__$_$_$Int64
};
var haxe_io_Error = { __ename__ : true, __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] };
haxe_io_Error.Blocked = ["Blocked",0];
haxe_io_Error.Blocked.toString = $estr;
haxe_io_Error.Blocked.__enum__ = haxe_io_Error;
haxe_io_Error.Overflow = ["Overflow",1];
haxe_io_Error.Overflow.toString = $estr;
haxe_io_Error.Overflow.__enum__ = haxe_io_Error;
haxe_io_Error.OutsideBounds = ["OutsideBounds",2];
haxe_io_Error.OutsideBounds.toString = $estr;
haxe_io_Error.OutsideBounds.__enum__ = haxe_io_Error;
haxe_io_Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe_io_Error; $x.toString = $estr; return $x; };
var haxe_io_FPHelper = function() { };
haxe_io_FPHelper.__name__ = true;
haxe_io_FPHelper.i32ToFloat = function(i) {
	var sign = 1 - (i >>> 31 << 1);
	var exp = i >>> 23 & 255;
	var sig = i & 8388607;
	if(sig == 0 && exp == 0) return 0.0;
	return sign * (1 + Math.pow(2,-23) * sig) * Math.pow(2,exp - 127);
};
haxe_io_FPHelper.floatToI32 = function(f) {
	if(f == 0) return 0;
	var af;
	if(f < 0) af = -f; else af = f;
	var exp = Math.floor(Math.log(af) / 0.6931471805599453);
	if(exp < -127) exp = -127; else if(exp > 128) exp = 128;
	var sig = Math.round((af / Math.pow(2,exp) - 1) * 8388608) & 8388607;
	return (f < 0?-2147483648:0) | exp + 127 << 23 | sig;
};
haxe_io_FPHelper.i64ToDouble = function(low,high) {
	var sign = 1 - (high >>> 31 << 1);
	var exp = (high >> 20 & 2047) - 1023;
	var sig = (high & 1048575) * 4294967296. + (low >>> 31) * 2147483648. + (low & 2147483647);
	if(sig == 0 && exp == -1023) return 0.0;
	return sign * (1.0 + Math.pow(2,-52) * sig) * Math.pow(2,exp);
};
haxe_io_FPHelper.doubleToI64 = function(v) {
	var i64 = haxe_io_FPHelper.i64tmp;
	if(v == 0) {
		i64.low = 0;
		i64.high = 0;
	} else {
		var av;
		if(v < 0) av = -v; else av = v;
		var exp = Math.floor(Math.log(av) / 0.6931471805599453);
		var sig;
		var v1 = (av / Math.pow(2,exp) - 1) * 4503599627370496.;
		sig = Math.round(v1);
		var sig_l = sig | 0;
		var sig_h = sig / 4294967296.0 | 0;
		i64.low = sig_l;
		i64.high = (v < 0?-2147483648:0) | exp + 1023 << 20 | sig_h;
	}
	return i64;
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__name__ = true;
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
	__class__: js__$Boot_HaxeError
});
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js_Boot.__nativeClassName(o);
		if(name != null) return js_Boot.__resolveNativeClass(name);
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js_Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js_Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js_Boot.__interfLoop(cc.__super__,cl);
};
js_Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js_Boot.__interfLoop(js_Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js_Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js_Boot.__isNativeObj = function(o) {
	return js_Boot.__nativeClassName(o) != null;
};
js_Boot.__resolveNativeClass = function(name) {
	return $global[name];
};
var js_html_compat_ArrayBuffer = function(a) {
	if((a instanceof Array) && a.__enum__ == null) {
		this.a = a;
		this.byteLength = a.length;
	} else {
		var len = a;
		this.a = [];
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			this.a[i] = 0;
		}
		this.byteLength = len;
	}
};
js_html_compat_ArrayBuffer.__name__ = true;
js_html_compat_ArrayBuffer.sliceImpl = function(begin,end) {
	var u = new Uint8Array(this,begin,end == null?null:end - begin);
	var result = new ArrayBuffer(u.byteLength);
	var resultArray = new Uint8Array(result);
	resultArray.set(u);
	return result;
};
js_html_compat_ArrayBuffer.prototype = {
	slice: function(begin,end) {
		return new js_html_compat_ArrayBuffer(this.a.slice(begin,end));
	}
	,__class__: js_html_compat_ArrayBuffer
};
var js_html_compat_DataView = function(buffer,byteOffset,byteLength) {
	this.buf = buffer;
	if(byteOffset == null) this.offset = 0; else this.offset = byteOffset;
	if(byteLength == null) this.length = buffer.byteLength - this.offset; else this.length = byteLength;
	if(this.offset < 0 || this.length < 0 || this.offset + this.length > buffer.byteLength) throw new js__$Boot_HaxeError(haxe_io_Error.OutsideBounds);
};
js_html_compat_DataView.__name__ = true;
js_html_compat_DataView.prototype = {
	getInt8: function(byteOffset) {
		var v = this.buf.a[this.offset + byteOffset];
		if(v >= 128) return v - 256; else return v;
	}
	,getUint8: function(byteOffset) {
		return this.buf.a[this.offset + byteOffset];
	}
	,getInt16: function(byteOffset,littleEndian) {
		var v = this.getUint16(byteOffset,littleEndian);
		if(v >= 32768) return v - 65536; else return v;
	}
	,getUint16: function(byteOffset,littleEndian) {
		if(littleEndian) return this.buf.a[this.offset + byteOffset] | this.buf.a[this.offset + byteOffset + 1] << 8; else return this.buf.a[this.offset + byteOffset] << 8 | this.buf.a[this.offset + byteOffset + 1];
	}
	,getInt32: function(byteOffset,littleEndian) {
		var p = this.offset + byteOffset;
		var a = this.buf.a[p++];
		var b = this.buf.a[p++];
		var c = this.buf.a[p++];
		var d = this.buf.a[p++];
		if(littleEndian) return a | b << 8 | c << 16 | d << 24; else return d | c << 8 | b << 16 | a << 24;
	}
	,getUint32: function(byteOffset,littleEndian) {
		var v = this.getInt32(byteOffset,littleEndian);
		if(v < 0) return v + 4294967296.; else return v;
	}
	,getFloat32: function(byteOffset,littleEndian) {
		return haxe_io_FPHelper.i32ToFloat(this.getInt32(byteOffset,littleEndian));
	}
	,getFloat64: function(byteOffset,littleEndian) {
		var a = this.getInt32(byteOffset,littleEndian);
		var b = this.getInt32(byteOffset + 4,littleEndian);
		return haxe_io_FPHelper.i64ToDouble(littleEndian?a:b,littleEndian?b:a);
	}
	,setInt8: function(byteOffset,value) {
		if(value < 0) this.buf.a[byteOffset + this.offset] = value + 128 & 255; else this.buf.a[byteOffset + this.offset] = value & 255;
	}
	,setUint8: function(byteOffset,value) {
		this.buf.a[byteOffset + this.offset] = value & 255;
	}
	,setInt16: function(byteOffset,value,littleEndian) {
		this.setUint16(byteOffset,value < 0?value + 65536:value,littleEndian);
	}
	,setUint16: function(byteOffset,value,littleEndian) {
		var p = byteOffset + this.offset;
		if(littleEndian) {
			this.buf.a[p] = value & 255;
			this.buf.a[p++] = value >> 8 & 255;
		} else {
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p] = value & 255;
		}
	}
	,setInt32: function(byteOffset,value,littleEndian) {
		this.setUint32(byteOffset,value,littleEndian);
	}
	,setUint32: function(byteOffset,value,littleEndian) {
		var p = byteOffset + this.offset;
		if(littleEndian) {
			this.buf.a[p++] = value & 255;
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p++] = value >> 16 & 255;
			this.buf.a[p++] = value >>> 24;
		} else {
			this.buf.a[p++] = value >>> 24;
			this.buf.a[p++] = value >> 16 & 255;
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p++] = value & 255;
		}
	}
	,setFloat32: function(byteOffset,value,littleEndian) {
		this.setUint32(byteOffset,haxe_io_FPHelper.floatToI32(value),littleEndian);
	}
	,setFloat64: function(byteOffset,value,littleEndian) {
		var i64 = haxe_io_FPHelper.doubleToI64(value);
		if(littleEndian) {
			this.setUint32(byteOffset,i64.low);
			this.setUint32(byteOffset,i64.high);
		} else {
			this.setUint32(byteOffset,i64.high);
			this.setUint32(byteOffset,i64.low);
		}
	}
	,__class__: js_html_compat_DataView
};
var js_html_compat_Uint8Array = function() { };
js_html_compat_Uint8Array.__name__ = true;
js_html_compat_Uint8Array._new = function(arg1,offset,length) {
	var arr;
	if(typeof(arg1) == "number") {
		arr = [];
		var _g = 0;
		while(_g < arg1) {
			var i = _g++;
			arr[i] = 0;
		}
		arr.byteLength = arr.length;
		arr.byteOffset = 0;
		arr.buffer = new js_html_compat_ArrayBuffer(arr);
	} else if(js_Boot.__instanceof(arg1,js_html_compat_ArrayBuffer)) {
		var buffer = arg1;
		if(offset == null) offset = 0;
		if(length == null) length = buffer.byteLength - offset;
		if(offset == 0) arr = buffer.a; else arr = buffer.a.slice(offset,offset + length);
		arr.byteLength = arr.length;
		arr.byteOffset = offset;
		arr.buffer = buffer;
	} else if((arg1 instanceof Array) && arg1.__enum__ == null) {
		arr = arg1.slice();
		arr.byteLength = arr.length;
		arr.byteOffset = 0;
		arr.buffer = new js_html_compat_ArrayBuffer(arr);
	} else throw new js__$Boot_HaxeError("TODO " + Std.string(arg1));
	arr.subarray = js_html_compat_Uint8Array._subarray;
	arr.set = js_html_compat_Uint8Array._set;
	return arr;
};
js_html_compat_Uint8Array._set = function(arg,offset) {
	var t = this;
	if(js_Boot.__instanceof(arg.buffer,js_html_compat_ArrayBuffer)) {
		var a = arg;
		if(arg.byteLength + offset > t.byteLength) throw new js__$Boot_HaxeError("set() outside of range");
		var _g1 = 0;
		var _g = arg.byteLength;
		while(_g1 < _g) {
			var i = _g1++;
			t[i + offset] = a[i];
		}
	} else if((arg instanceof Array) && arg.__enum__ == null) {
		var a1 = arg;
		if(a1.length + offset > t.byteLength) throw new js__$Boot_HaxeError("set() outside of range");
		var _g11 = 0;
		var _g2 = a1.length;
		while(_g11 < _g2) {
			var i1 = _g11++;
			t[i1 + offset] = a1[i1];
		}
	} else throw new js__$Boot_HaxeError("TODO");
};
js_html_compat_Uint8Array._subarray = function(start,end) {
	var t = this;
	var a = js_html_compat_Uint8Array._new(t.slice(start,end));
	a.byteOffset = start;
	return a;
};
var js_node_Http = require("http");
var js_node_Path = require("path");
var js_npm_Express = require("express");
var js_npm_NeDB = require("nedb");
var js_npm_SpotifyWebApiNode = require("spotify-web-api-node");
var js_npm_YoutubeNode = require("youtube-node");
var js_npm_express_BodyParser = require("body-parser");
var js_npm_express_Favicon = require("serve-favicon");
var js_npm_express_Morgan = require("morgan");
var js_npm_express_Static = require("express").static;
var js_npm_socketio_Server = require("socket.io");
var model_AppConstants = function() { };
model_AppConstants.__name__ = true;
var model_SearchVO = function() {
};
model_SearchVO.__name__ = true;
model_SearchVO.prototype = {
	toString: function() {
		var _str = "";
		_str += "{";
		_str += "name: " + this.name + ", ";
		_str += "id: " + this.id + ", ";
		_str += "spotifyArtist: " + Std.string(this.spotifyArtist) + ", ";
		_str += "}";
		return _str;
	}
	,__class__: model_SearchVO
};
var model_SocketConstants = function() { };
model_SocketConstants.__name__ = true;
var model_StoreVO = function(data) {
	model_SearchVO.call(this);
	if(data != null) {
		this.name = data.name;
		this.id = data.id;
	}
};
model_StoreVO.__name__ = true;
model_StoreVO.__super__ = model_SearchVO;
model_StoreVO.prototype = $extend(model_SearchVO.prototype,{
	__class__: model_StoreVO
});
var utils_CheckInstall = function() {
	console.log("////////////");
};
utils_CheckInstall.__name__ = true;
utils_CheckInstall.prototype = {
	__class__: utils_CheckInstall
};
String.prototype.__class__ = String;
String.__name__ = true;
Array.__name__ = true;
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
var ArrayBuffer = $global.ArrayBuffer || js_html_compat_ArrayBuffer;
if(ArrayBuffer.prototype.slice == null) ArrayBuffer.prototype.slice = js_html_compat_ArrayBuffer.sliceImpl;
var DataView = $global.DataView || js_html_compat_DataView;
var Uint8Array = $global.Uint8Array || js_html_compat_Uint8Array._new;
MainServer.SERVER = "[SERVER] : ";
haxe_io_FPHelper.i64tmp = (function($this) {
	var $r;
	var x = new haxe__$Int64__$_$_$Int64(0,0);
	$r = x;
	return $r;
}(this));
js_Boot.__toStr = {}.toString;
js_html_compat_Uint8Array.BYTES_PER_ELEMENT = 1;
model_AppConstants.IP = "http://localhost";
model_AppConstants.PORT = "3000";
model_AppConstants.YOUTUBE_API_KEY = "AIzaSyB2OewXe4m_Z4ByewYnQOwvp7hSqXZgZNI";
model_AppConstants.SPOTIFY_CLIENT_ID = "2b0d1fddbb90459bba814cda105aa291";
model_AppConstants.SPOTIFY_CLIENT_SECRET = "dbff4b863ddb4324b1a3832f1567d27a";
model_AppConstants.SPOTIFY_SEARCH_LIMIT = 20;
model_AppConstants.YOUTUBE_SEARCH_LIMIT = 10;
model_SocketConstants.PROFILE_UPDATE = "profileupdate";
model_SocketConstants.TOP_RESULTS = "topresults";
model_SocketConstants.SEARCH_RESULTS = "searchresults";
model_SocketConstants.SEARCH_WITH_ID = "search_with_id";
model_SocketConstants.ERROR = "error";
model_SocketConstants.PLAYER = "player";
model_SocketConstants.YOU_PLAYER = "you_player";
model_SocketConstants.SEARCH = "search";
model_SocketConstants.NEXT_TRACK = "next-track";
model_SocketConstants.PREV_TRACK = "prev-track";
model_SocketConstants.SCREEN = "screen";
model_SocketConstants.CURRENT = "current";
MainElectron.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);
