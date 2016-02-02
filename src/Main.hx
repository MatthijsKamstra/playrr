package;

import jQuery.*;
import js.Browser;
import js.html.*;

class Main {

	private var _doc = js.Browser.document;
	private var _win = js.Browser.window;
	private var _nav = js.Browser.navigator;

	private var _btn : Element;
	private var _screenshot : ImageElement;
	private var _howtobuild : Element;

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
		_screenshot 	= cast (_doc.getElementById('screenshot'), js.html.ImageElement);
		_howtobuild		= _doc.getElementById('how-to-build');


		changeLink();
		loadData(); // test
	}
	
	public function changeLink():Void
	{
	    /**
	     * 	<a href="https://github.com/MatthijsKamstra/playrr/raw/master/download/Playrr.app.zip" download class="waves-effect waves-light btn-large"><i class="material-icons right">get_app</i>OSX (64bit)</a>
			<br/>
			<a href="https://github.com/MatthijsKamstra/playrr/raw/master/download/" target="_blank" class="right">Other downloads</a>
	     */
	    

		// [mck] os		
		var r = ~/Win|Mac|Linux/;
		var str = _nav.platform;
		r.match(str);

		var os = r.matched(0);
		// trace(os);

		// [mck] arch
		var r1 = ~/x86_64|Win64|WOW64/;
		var str1 = _nav.userAgent;
		var arch = 'ia32';
		if (r1.match(str1)){
			// arch = r1.matched(0);
			arch = 'x64';
		}
		// trace(arch);


		var osName = '';
		var osNiceName = '';
		var img = 'images/playrr_osx.png';


		switch (os) {
			case 'Mac': 	
				trace('mac'); 
				arch = 'x64';
				osName = 'darwin';
				osNiceName = 'OS X';
				img = 'images/playrr_osx.png';
			case 'Win': 	
				trace('win');
				osName = 'win32';
				osNiceName = 'Windows';
				img = 'images/playrr_osx.png';
			case 'Linux': 	
				trace('linux');
				osName = 'linux';
				osNiceName = 'Linux';
				img = 'images/playrr_linux.png';
			default: 		
				trace('unclear');
		}		

		_screenshot.src = img;


		/**
		 * Playrr-darwin-x64
		 * Playrr-linux-ia32
		 * Playrr-linux-x64
		 * Playrr-win32-ia32
		 * Playrr-win32-x64
		 */

		var downloadFolder = "Playrr-" + osName + "-" + arch;
		var description = osNiceName + " (" + arch + ")";


		_btn.classList.add(os + "_" + arch);


		// https://github.com/MatthijsKamstra/playrr/blob/master/download/Playrr-darwin-x64/Playrr.zip?raw=true
		_btn.innerHTML = '<a href="https://github.com/MatthijsKamstra/playrr/raw/master/download/$downloadFolder/Playrr.zip?raw=true" download class="waves-effect waves-light btn-large"><i class="material-icons right">get_app</i>$description</a><br/><a href="https://github.com/MatthijsKamstra/playrr/tree/master/download/" target="_blank" class="right underlined">Other downloads</a>';


	}

	public function loadData():Void
	{
		    
	
		// [mck] test if I could use the data written in markdown
		var req = new haxe.Http('https://raw.githubusercontent.com/MatthijsKamstra/playrr/master/wiki/how_to_build.md');
		req.onData = function (data : String)
		{
		    // Browser.alert('data: $data');
		    _howtobuild.innerHTML = Markdown.markdownToHtml(data);
		}
		req.onError = function (error)
		{
		    // Browser.alert('error: $error');
		}
		req.request(true);
	}


	
	static public function main()
	{
		var main = new Main();
	}


}