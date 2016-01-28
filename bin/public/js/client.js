(function (console, $hx_exports, $global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
var MainClient = function() {
	this._youtubeStuff = new YoutubeStuff();
	this._win = window;
	this._doc = window.document;
	var _g = this;
	$(window.document).ready(function() {
		console.log(MainClient.CLIENT + "MainClient document ready!");
		_g.init();
	});
};
MainClient.__name__ = true;
MainClient.main = function() {
	var main = new MainClient();
};
MainClient.prototype = {
	init: function() {
		var _g = this;
		var _mock = this._doc.getElementById("mock");
		_mock.classList.add("mock");
		this._submitBtn = window.document.getElementById("submitBtn");
		this._inputSearch = js_Boot.__cast(window.document.getElementById("inputSearch") , HTMLInputElement);
		this._trackinfo = window.document.getElementById("trackinfo");
		this._cover = window.document.getElementById("cover");
		this._search = window.document.getElementById("search");
		this._player = window.document.getElementById("player");
		this._playlist = window.document.getElementById("playlist");
		this._current = window.document.getElementById("current");
		this.resetAll();
		this.updatePlaylistHeight();
		this._socket = io.connect(model_AppConstants.IP + ":" + model_AppConstants.PORT);
		this._socket.on("connect",function(data) {
			_g._socket.emit("screen");
			_g._socket.on("message",function(data1) {
				console.log(MainClient.CLIENT + "hello from server: " + Std.string(data1.message));
			});
			_g._socket.on(model_SocketConstants.PROFILE_UPDATE,function(data2) {
				_g.updateProfile(data2);
				_g.updateSelection(data2);
			});
			_g._socket.on(model_SocketConstants.TOP_RESULTS,function(arr) {
			});
			_g._socket.on(model_SocketConstants.SEARCH_RESULTS,function(arr1) {
				_g.updateList(arr1);
				_g.isLoader(false);
			});
			_g._socket.on(model_SocketConstants.CURRENT,function(artist) {
				_g.updateCurrent(artist);
			});
			_g._socket.on(model_SocketConstants.PLAYER,function(url) {
				console.log(MainClient.CLIENT + "[" + model_SocketConstants.PLAYER + "] " + "url: " + url);
				if(url == "/sfx/chime_tone.mp3") _g.initStartScreen();
			});
			_g._socket.on(model_SocketConstants.YOU_PLAYER,function(url1) {
				console.log(MainClient.CLIENT + "[" + model_SocketConstants.YOU_PLAYER + "] " + "url: " + url1);
				_g.updateIframePlayer(decodeURIComponent(url1.split("+").join(" ")));
			});
		});
		this._youtubeStuff.build("sQiI5k8FS7A");
		this._youtubeStuff.set_socket(this._socket);
		$(".track-play").click(function(e) {
			_g._youtubeStuff.playVideo();
		});
		$(".track-next").click(function(e1) {
			var s = new model_SearchVO();
			_g._socket.emit(model_SocketConstants.NEXT_TRACK,s);
		});
		$(".track-previous").click(function(e2) {
			var s1 = new model_SearchVO();
			_g._socket.emit(model_SocketConstants.PREV_TRACK,s1);
		});
		$(".search-icon").click(function(e3) {
			var bottom = Std.parseInt($("#bottomslidein").css("bottom"));
			if(bottom < 0) $("#bottomslidein").animate({ 'bottom' : "0px"},500); else $("#bottomslidein").animate({ 'bottom' : "-40px"},500);
		});
		this._inputSearch.onkeydown = function(e4) {
			if(e4.keyCode == 13) {
				e4.preventDefault();
				_g.onSubmit(_g._inputSearch.value);
				return false;
			} else return true;
		};
		this._submitBtn.onclick = function(e5) {
			e5.preventDefault();
			_g.onSubmit(_g._inputSearch.value);
		};
	}
	,initStartScreen: function() {
		var _g = this;
		this._doc.getElementById("start").style.display = "inline";
		var _submitBtn2 = window.document.getElementById("submitBtn2");
		var _inputSearch2;
		_inputSearch2 = js_Boot.__cast(window.document.getElementById("inputSearch2") , HTMLInputElement);
		var temp = ["M.I.A.","Mystikal","Skrillex","Naughty by Nature"];
		_inputSearch2.value = temp[Math.round(Math.random() * temp.length - 1)];
		_inputSearch2.onkeydown = function(e) {
			if(e.keyCode == 13) {
				e.preventDefault();
				_g.onSubmit(_inputSearch2.value);
				return false;
			} else return true;
		};
		_submitBtn2.onclick = function(e1) {
			e1.preventDefault();
			_g.onSubmit(_inputSearch2.value);
		};
	}
	,onSubmit: function(str) {
		this._doc.getElementById("start").style.display = "none";
		var _searchVO = new model_SearchVO();
		_searchVO.name = decodeURIComponent(str.split("+").join(" "));
		this._socket.emit(model_SocketConstants.SEARCH,_searchVO);
		this.isLoader(true);
		this.isSearch(false);
	}
	,updateIframePlayer: function(id) {
		this._youtubeStuff.loadVideoById(id);
	}
	,updateSelection: function(toptrack) {
		var _artist = toptrack.artists[0];
		var _id = _artist.id;
		var arr = $(".artist-list-item");
		var _g1 = 0;
		var _g = arr.length;
		while(_g1 < _g) {
			var i = _g1++;
			if($(arr[i]).hasClass("selected")) $(arr[i]).removeClass("selected");
			if($(arr[i]).data("artistid") == _id) {
				var scrollTo = $(arr[i]);
				var container = $("#playlist");
				scrollTo.addClass("selected");
				container.animate({ 'scrollTop' : scrollTo.offset().top - container.offset().top + container.scrollTop()});
			}
		}
	}
	,updateProfile: function(toptrack) {
		if(toptrack == null) {
			var s = new model_SearchVO();
			this._socket.emit(model_SocketConstants.NEXT_TRACK,s);
			return;
		}
		var _artist = toptrack.artists[0];
		var _album = toptrack.album;
		this._inputSearch.value = _artist.name;
		var _temp = 0;
		var _url = "images/icons/no-profile.jpg";
		if(_album.images != null) {
			if(_album.images.length != 0) {
				var _g1 = 0;
				var _g = _album.images.length;
				while(_g1 < _g) {
					var i = _g1++;
					var img = _album.images[i];
					if(img.height > _temp) {
						_temp = img.height;
						_url = img.url;
					}
				}
			}
		}
		var _popularity;
		if(toptrack.popularity != null) _popularity = toptrack.popularity; else _popularity = 0;
		var _html = "";
		_html += "<h1>" + decodeURIComponent(_artist.name.split("+").join(" ")) + "</h1>";
		_html += "<h2>" + _album.name + "</h2>";
		_html += "<h3>" + toptrack.name + "</h3>";
		_html += "<!--<p>" + _popularity + "</p>-->";
		this._trackinfo.innerHTML = _html;
		this._cover.style.backgroundImage = "url(" + _url + ")";
	}
	,updateList: function(arr) {
		var _g = this;
		var _html = "<ul>";
		var _g1 = 0;
		var _g2 = arr.length;
		while(_g1 < _g2) {
			var i = _g1++;
			var _artist = arr[i];
			var _url = "";
			if(_artist.images.length != 0) _url = _artist.images[0].url;
			var liClass = "even";
			if(i % 2 == 0) liClass = "odd";
			_html += "<li data-id=\"" + i + "\" data-artistid=\"" + _artist.id + "\" class=\"" + liClass + " artist-list-item\">";
			_html += "\t<a href=\"#\">";
			_html += "\t\t<span class=\"playlist-nr\">" + (i + 1) + ".</span>";
			_html += "\t\t<span class=\"playlist-artist\">" + decodeURIComponent(_artist.name.split("+").join(" ")) + "</span>";
			_html += "\t\t<div class=\"playlist-img\" style=\"background-image:url(" + _url + ")\" ></div>";
			_html += "\t</a>";
			_html += "</li>";
		}
		_html += "</ul>";
		this._playlist.innerHTML = _html;
		this.updatePlaylistHeight();
		$("li.artist-list-item").click(function(e) {
			var _id = $(e.currentTarget).data("id");
			var _artist1 = arr[_id];
			_g._inputSearch.value = decodeURIComponent(_artist1.name.split("+").join(" "));
			_g.updateCurrent(_artist1);
			_g.isLoader(true);
			var _searchVO = new model_SearchVO();
			_searchVO.name = encodeURIComponent(_artist1.name);
			_searchVO.id = _artist1.id;
			_searchVO.spotifyArtist = _artist1;
			_g._socket.emit(model_SocketConstants.SEARCH_WITH_ID,_searchVO);
		});
	}
	,updateCurrent: function(artist) {
		if(artist == null) this._current.innerHTML = "<p>Current playlist is based upon <b>*</b></p>"; else this._current.innerHTML = "<p>Current playlist is based upon <b><a href=\"" + artist.external_urls.spotify + "\" target=\"_blank\"><!--<img src=\"/images/icons/Spotify-icon.png\" style=\"width:15px;height:15px\" -->" + decodeURIComponent(artist.name.split("+").join(" ")) + "</a></b></p>";
	}
	,updatePlaylistHeight: function() {
		var h = this._win.innerHeight - this._playlist.offsetTop;
		this._playlist.style.height = h + "px";
	}
	,resetAll: function() {
		this._current.innerHTML = "";
		this._trackinfo.innerHTML = "";
		this.isLoader(false);
	}
	,isLoader: function(isVisible) {
		var _loader = $("#loader");
		if(isVisible) _loader.fadeIn(); else _loader.fadeOut();
	}
	,isSearch: function(isVisible) {
		var bottom = Std.parseInt($("#bottomslidein").css("bottom"));
		if(isVisible == null) isVisible = false;
		if(bottom < 0) isVisible = true;
		if(isVisible) $("#bottomslidein").animate({ 'bottom' : "0px"},500); else $("#bottomslidein").animate({ 'bottom' : "-40px"},500);
	}
	,__class__: MainClient
};
Math.__name__ = true;
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
var YoutubeStuff = $hx_exports.YoutubeStuff = function() {
	this._doc = window.document;
};
YoutubeStuff.__name__ = true;
YoutubeStuff.prototype = {
	build: function(id) {
		var tag;
		tag = js_Boot.__cast(this._doc.createElement("script") , HTMLScriptElement);
		tag.src = "https://www.youtube.com/iframe_api";
		var firstScriptTag = this._doc.getElementsByTagName("script")[0];
		firstScriptTag.parentNode.insertBefore(tag,firstScriptTag);
		var tag2;
		tag2 = js_Boot.__cast(this._doc.createElement("script") , HTMLScriptElement);
		tag2.id = "youtubestuff";
		tag2.innerHTML = "\nvar player;\nvar yt = new YoutubeStuff();\nfunction onYouTubeIframeAPIReady() {\n\t// console.log('>> onYouTubeIframeAPIReady');\n\tplayer = new YT.Player('player', {\n\t\twidth: '325',\n\t\theight: '325',\n\t\tvideoId: '" + id + "',\n\t\tplayerVars: { \n\t\t\t'autoplay': 1, \n\t\t\t'controls': 1, \n\t\t\t'fs' : 0,\n\t\t\t'iv_load_policy' : 0,\n\t\t\t'modestbranding' : 0,\n\t\t\t'rel' : 0,\n\t\t\t'showinfo' : 0\n\t\t},\n\t\tevents: {\n\t\t\t'onReady': onPlayerReady,\n\t\t\t'onStateChange': onPlayerStateChange\n\t\t}\n\t});\n}\n\nfunction onPlayerStateChange(e) \n{\n\tyt.onPlayerStateChangeHandler(e);\n}\n\nfunction onPlayerReady (e)\n{\n\tyt.onPlayerReadyHandler(e);\n}\n\t\t\t";
		firstScriptTag.parentNode.insertBefore(tag2,firstScriptTag);
	}
	,onPlayerReadyHandler: function(e) {
		console.log("YoutubeStuff.onPlayerReadyHandler");
		YoutubeStuff._player = e.target;
		if(YoutubeStuff._id != null) this.loadVideoById(YoutubeStuff._id);
	}
	,onPlayerStateChangeHandler: function(e) {
		console.log("YoutubeStuff.onPlayerStateChangeHandler e.data: " + e.data);
		if(e.data == "0") {
			console.log("the current track/video is ended, get next");
			var s = new model_SearchVO();
			YoutubeStuff._socket.emit(model_SocketConstants.NEXT_TRACK,s);
		}
	}
	,loadVideoById: function(id) {
		console.log("YoutubeStuff.loadVideoById() id: " + id);
		if(YoutubeStuff._player == null) {
			console.log("ohhhhh, too fast, let youtube do it's stuff, let's wait for it..");
			YoutubeStuff._id = id;
		} else YoutubeStuff._player.loadVideoById(id);
	}
	,playVideo: function() {
		YoutubeStuff._player.playVideo();
	}
	,set_socket: function(value) {
		return YoutubeStuff._socket = value;
	}
	,__class__: YoutubeStuff
};
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
js_Boot.__cast = function(o,t) {
	if(js_Boot.__instanceof(o,t)) return o; else throw new js__$Boot_HaxeError("Cannot cast " + Std.string(o) + " to " + Std.string(t));
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
var model_AppConstants = function() { };
model_AppConstants.__name__ = true;
var model_SearchVO = function() {
};
model_SearchVO.__name__ = true;
model_SearchVO.prototype = {
	__class__: model_SearchVO
};
var model_SocketConstants = function() { };
model_SocketConstants.__name__ = true;
String.prototype.__class__ = String;
String.__name__ = true;
Array.__name__ = true;
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
MainClient.CLIENT = "[CLIENT] : ";
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
model_SocketConstants.PROFILE_UPDATE = "profileupdate";
model_SocketConstants.TOP_RESULTS = "topresults";
model_SocketConstants.SEARCH_RESULTS = "searchresults";
model_SocketConstants.SEARCH_WITH_ID = "search_with_id";
model_SocketConstants.PLAYER = "player";
model_SocketConstants.YOU_PLAYER = "you_player";
model_SocketConstants.SEARCH = "search";
model_SocketConstants.NEXT_TRACK = "next-track";
model_SocketConstants.PREV_TRACK = "prev-track";
model_SocketConstants.CURRENT = "current";
MainClient.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : exports, typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);

//# sourceMappingURL=client.js.map