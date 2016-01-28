package;

import jQuery.*;
import js.Browser;
import js.html.*;

class Main {

	private var _doc = js.Browser.document;
	private var _win = js.Browser.window;
	private var _nav = js.Browser.navigator;

	private var _btn : Element;
	private var _screenshot : Element;

	// https://nodejs.org/static/js/download.js
	public function new():Void
	{	
		new JQuery(Browser.document).ready ( function ()
		{
			trace( "Playrr website ready"  );
			init();
		});
	}

	private function init()
	{

		_btn 			= _doc.getElementById('download-btn');
		_screenshot 	= _doc.getElementById('screenshot');



		// [mck] os		
		var r = ~/Win|Mac|Linux/;
		var str = _nav.platform;
		r.match(str);

		var os = r.matched(0);
		// trace(os);

		// [mck] arch
		var r1 = ~/x86_64|Win64|WOW64/;
		var str1 = _nav.userAgent;
		var arch = 'x32';
		if (r1.match(str1)){
			// arch = r1.matched(0);
			arch = 'x64';
		}
		// trace(arch);



		switch (os) {
			case 'Mac': 	trace('mac'); arch = 'x64';
			case 'Win': 	trace('win');
			case 'Linux': 	trace('linux');
			default: 		trace('unclear');
		}		


		 _btn.classList.add(os + "_" + arch);

	}

	/*
	private	function versionIntoHref(nodeList, filename) {
		var linkEls = Array.prototype.slice.call(nodeList);
		var version;
		var el;

		for (var i = 0; i < linkEls.length; i++) {
		version = linkEls[i].getAttribute('data-version');
		el = linkEls[i]

		// Windows 64-bit files for 0.x.x need to be prefixed with 'x64/'
		if (os === 'Win' && (version[1] === '0' && arch === 'x64')) {
		el.href += arch + '/';
		}

		el.href += filename.replace('%version%', version);
		}
		}

		if (downloadHead && buttons) {
		dlLocal = downloadHea_doc.getAttribute('data-dl-local');
		switch (os) {
		case 'Mac':
		versionIntoHref(buttons, 'node-%version%.pkg');
		downloadHead[text] = dlLocal + ' OS X (x64)';
		break;
		case 'Win':
		versionIntoHref(buttons, 'node-%version%-' + arch + '.msi');
		downloadHead[text] = dlLocal + ' Windows (' + arch +')';
		break;
		case 'Linux':
		versionIntoHref(buttons, 'node-%version%-linux-' + arch + '.tar.gz');
		downloadHead[text] = dlLocal + ' Linux (' + arch + ')';
		break;
		}
		}

		// Windows button on download page
		var winButton = _doc.getElementById('windows-downloadbutton');
		if (winButton && os === 'Win') {
		var winText = winButton.getElementsByTagName('p')[0];
		version = winButton.getAttribute('data-version');
		winButton.href = winButton.href.replace(/x(86|64)/, arch);
		winText[text] = winText[text].replace(/x(86|64)/, arch);
		}
	}
	*/
	
	static public function main()
	{
		var main = new Main();
	}


}