(function (console) { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.prototype = {
	match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,matched: function(n) {
		if(this.r.m != null && n >= 0 && n < this.r.m.length) return this.r.m[n]; else throw new js__$Boot_HaxeError("EReg::matched");
	}
};
var Main = function() {
	this._nav = window.navigator;
	this._doc = window.document;
	var _g = this;
	$(window.document).ready(function() {
		console.log("Playrr website ready");
		_g.init();
	});
};
Main.main = function() {
	var main = new Main();
};
Main.prototype = {
	init: function() {
		this._btn = this._doc.getElementById("download-btn");
		this._screenshot = this._doc.getElementById("screenshot");
		var r = new EReg("Win|Mac|Linux","");
		var str = this._nav.platform;
		r.match(str);
		var os = r.matched(0);
		var r1 = new EReg("x86_64|Win64|WOW64","");
		var str1 = this._nav.userAgent;
		var arch = "x32";
		if(r1.match(str1)) arch = "x64";
		switch(os) {
		case "Mac":
			console.log("mac");
			arch = "x64";
			break;
		case "Win":
			console.log("win");
			break;
		case "Linux":
			console.log("linux");
			break;
		default:
			console.log("unclear");
		}
		this._btn.classList.add(os + "_" + arch);
	}
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
});
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}});
