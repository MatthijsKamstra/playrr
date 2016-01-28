package;

import electron.main.App;
import electron.main.BrowserWindow;
import electron.common.CrashReporter;

import js.Node;
import js.npm.Express;

class MainElectron {


	public function new():Void
	{
		// start server/project
		var main = new MainServer();

		// Report crashes to our server.
		// CrashReporter.start({
		// 	companyName : "hxelectron (not a company)",
		// 	submitURL : "https://github.com/fponticelli/hxelectron/issues",
		// });

		// Keep a global reference of the window object, if you don't, the window will
		// be closed automatically when the JavaScript object is garbage collected.
		var mainWindow = null;

		// Quit when all windows are closed.
		App.on( window_all_closed, function() {
			// On OS X it is common for applications and their menu bar
			// to stay active until the user quits explicitly with Cmd + Q
			// if (Node.process.platform != 'darwin')
				App.quit();
		});

		// This method will be called when Electron has finished
		// initialization and is ready to create browser windows.
		App.on( ready, function() {

			// Create the browser window.
			mainWindow = new BrowserWindow({
			#if(debug)
				resizable:true,
				width: 700,
			#else
				resizable:false,
				width: 325,
			#end
				height: 730,
				center:true,
				minWidth:325,
				minHeight:730,
				title:"Playrr"
			});

			// and load the index.html of the app.
			// mainWindow.loadUrl('file://' + Node.__dirname + '/index.html');
			mainWindow.loadURL('http://localhost:3000');

			#if(debug)
			// Open the DevTools.
			mainWindow.webContents.openDevTools();
			#end

			// Emitted when the window is closed.
			mainWindow.on( closed, function() {
				// Dereference the window object, usually you would store windows
				// in an array if your app supports multi windows, this is the time
				// when you should delete the corresponding element.
				mainWindow = null;
			});
		
		});
	    
	}

	static function main() {
		var main = new MainElectron();
	}

}
