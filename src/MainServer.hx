package ;


import api.spotify.SpotifyApi;
import api.spotify.AST;
import api.youtube.YoutubeApi;
import api.youtube.AST;

import js.Node;
import js.node.http.*;
import js.node.Http;
import js.node.Path;
import js.node.Fs;
import js.node.ChildProcess;
import js.node.Os;

import js.npm.Mkdirp;
import js.npm.Express;
import js.npm.Jade;
import js.npm.express.*;
import js.npm.express.Favicon;
import js.npm.NeDB;

import model.AppConstants;
import model.SearchVO;
import model.StoreVO;
import model.SocketConstants;

import utils.ShellUtil;
import utils.CheckInstall;


/**
 * @author Matthijs Kamstra aka [mck]
 */
class MainServer
{
	private static var SERVER : String = "[SERVER] : ";

	private var _socket : Dynamic;

	private var spotify : SpotifyApi;
	private var youtube : YoutubeApi;

	private var _dbRelatedArtists : NeDB;
	private var _dbTopTracks : NeDB;
	private var _dbCurrentArtist : NeDB;
	private var _dbPlaylist : NeDB;
	private var _dbConfig : NeDB;

	private var currentPlaylistID:Int = 0;
	private var currentPlaylistRound:Int = 0;

	public function new()
	{		
		// little help to see if server is restarted
		
		trace("\n\n\n\n\n\n\n\n\n\n");
		trace("\n--------------- " + Date.now() +" --------------- \n");
		trace("Express website: open browser at " + AppConstants.IP + ":" + AppConstants.PORT);
		trace("Stop node.js : CTRL + c");

		spotify = new SpotifyApi();
		youtube = new YoutubeApi();

		var checkInstall = new CheckInstall();

		var app 	= new js.npm.Express();
		var server 	= js.node.Http.createServer( cast app );
		var io 		= new js.npm.socketio.Server(server);


		// database
		var options : DataStoreOptions = { filename : Path.join(Node.__dirname, '/public/_db/relatedartists.ddb'), autoload : true };
		_dbRelatedArtists = new NeDB(options);

		var options : DataStoreOptions = { filename : Path.join(Node.__dirname, '/public/_db/toptracks.ddb'), autoload : true };
		_dbTopTracks = new NeDB(options);

		var options : DataStoreOptions = { filename : Path.join(Node.__dirname, '/public/_db/currentartist.ddb'), autoload : true };
		_dbCurrentArtist = new NeDB(options);

		var options : DataStoreOptions = { filename : Path.join(Node.__dirname, '/public/_db/playlist.ddb'), autoload : true };
		_dbPlaylist = new NeDB(options);

		var options : DataStoreOptions = { filename : Path.join(Node.__dirname, '/public/_db/config.ddb'), autoload : true, timestampData : true };
		_dbConfig = new NeDB(options);

		

		// api
		spotify.on(SpotifyApi.ERROR, function(str:String){
			trace(SERVER + 'oeps ERROR : ' + str);
			_socket.emit(SocketConstants.ERROR);
		});


		// all environments
		app.set('port', AppConstants.PORT);
		app.set('views', Node.__dirname + '/public/views');
		app.set('view engine', 'jade');
		app.use(new Favicon(Node.__dirname + '/public/favicon.ico'));
		app.use(new Morgan('dev'));
		app.use(BodyParser.json());
		app.use(BodyParser.urlencoded({ extended: true }));
		app.use(new Static(Path.join(Node.__dirname, 'public')));

		//Routes
		app.get('/', function (req:Dynamic,res:Response) {
			res.sendfile(Node.__dirname + '/public/index_advanced.html');
		});

		app.use(function(req, res, next) {
			res.status(404).send('404');
			// res.status(404).send(output);
		});

		io.on('connection', function (socket) {

			_socket = socket;

			socket.emit('message', { message: 'welcome to Party Playrr' });

			socket.on('send', function (data) {
				io.sockets.emit('message', data);
		
			});

			socket.on(SocketConstants.SCREEN, function (e) {
				// [mck] first reaction from the client
				trace (SERVER + 'hello from client');
				resetInterface();
				lastTrackPlayed();
				lastPlaylist();
			});

			socket.on(SocketConstants.SEARCH , function (data : model.SearchVO) {
				// [mck] this is search button action
				getArtistProfileList(data);
			});

			socket.on(SocketConstants.SEARCH_WITH_ID , function (data : model.SearchVO) {
				// [mck] IMPORTANT this is when somebody forces to change the playlist!!!!
				trace(SERVER + "## YOYYOOOO" );

				currentPlaylistID = 1;

				var vo : model.StoreVO = new model.StoreVO(data);
				vo._id = 1;

				// [mck] clear the database and place a new related artist in there
				_dbPlaylist.remove({ }, { multi: true }, function (err, numRemoved) {
					_dbPlaylist.loadDatabase(function (err) {
						// done
					});
				});
				_dbPlaylist.insert (vo);

				noIdeaHowToCallThisFunction (data.id);
			});

			socket.on(SocketConstants.NEXT_TRACK, function (e: model.SearchVO) {
				trace(SERVER + ":: NEXT TRACK :: TODO :: -------------- e: " + e);

				// [mck] hacking
				// if (e.name.indexOf("sfx/chime_tone.mp3") != -1){
				// 	trace(SERVER + "just one is good enough");
				// }

				
				trace(SERVER + "currentPlaylistID: " + currentPlaylistID );
				currentPlaylistID++;


				_dbPlaylist.find({_id : currentPlaylistID}, function (err:Dynamic, docs:Array<StoreVO>) 
				{
					trace( " | docs.length: " + docs.length );
					trace( " | docs[0]: " + docs[0] );

					if(docs.length <= 0){
						trace(SERVER + "ERROR > WHAT TO DO NEXT?");
						currentPlaylistID = 0;
						var s = new model.SearchVO();
						io.sockets.emit(SocketConstants.NEXT_TRACK, s);



						return;
					}

					getArtistTopTracks(docs[0].id);

				});



				#if(debug)
				// io.sockets.emit (SocketConstants.PLAYER, "/sfx/chime_tone.mp3" );
				#end
			});

			socket.on(SocketConstants.PREV_TRACK, function (e:model.SearchVO) {
				trace(SERVER + ":: PREVIOUS TRACK :: TODO :: -------------- e: " + e);
			});

			// socket.on('getprofile' , function (data : model.SearchVO) {
			// 	trace( "socket 'getprofile' data: " + data );
			// 	// getGetProfile(data);
			// });
			
		});

		trace (SERVER + "Listening on port " + AppConstants.PORT);

		server.listen(app.get('port'), function(){
			trace(SERVER + 'Express server listening on port ' + app.get('port'));
		});

		// server.listen(AppConstants.PORT);		
	} 

	public function resetInterface():Void
	{
		trace( SERVER + "TODO!" );
		// [mck] show the instructions
	}


	public function lastPlaylist():Void
	{

		trace(SERVER + "+ lastPlaylist");

		_dbPlaylist.find({_id : 1}, function (err:Dynamic, docs:Array<StoreVO>) 
		{
			trace( " | err: " + err );
			trace( " | docs.length: " + docs.length );
			trace( " | docs[0]: " + docs[0] );

			if(docs.length == 0 || err != null){
				return;
			}

			// _socket.emit(SocketConstants.CURRENT, docs[0]);
			_socket.emit(SocketConstants.CURRENT, null);

		});

	}

	public function lastTrackPlayed():Void
	{

		trace(SERVER + "+ lastTrackPlayed");

		// send the last search to the player
		// [mck] for some reason _id can't be 0, so when we add _id = (x + 1)
		_dbTopTracks.find({ _id: 1 }, function (err : Dynamic,  docs : Array<SpotifyArtistTopTracks> ) 
		{	
			trace( " | err: " + err );
			trace( " | docs.length: " + docs.length );
			trace( " | docs[0]: " + docs[0] );

			if(docs.length == 0 || err != null){
				trace("NO FIRST TRACK");
				// TODO need some start up screen info, or reset default info
				// play intro sound just once
				_socket.emit (SocketConstants.PLAYER, "/sfx/chime_tone.mp3" );
			} else {
				var track : SpotifyArtistTopTracks = docs[0];
				getRelatedArtists(track.artists[0].id); 
				searchYoutube(track);
				_socket.emit(SocketConstants.PROFILE_UPDATE, track);
			}
		});
	}


	public function noIdeaHowToCallThisFunction (id:String, ?data : SpotifyArtist)
	{
		if(data != null){
			trace(SERVER +  "---------->> data: " + data );
		}
		getRelatedArtists(id); 
		getArtistTopTracks(id);
	}


	public function getArtistProfileList(searchVO : model.SearchVO ):Void
	{
		trace(SERVER +  "getArtistProfileList :: name: " + searchVO.name );
		spotify.searchArtists( searchVO.name , { limit : AppConstants.SPOTIFY_SEARCH_LIMIT, offset : 0 });
		spotify.once(SpotifyApi.SEARCH_ARTISTS, function (arr : Array<SpotifyArtist>) 
		{
			_socket.emit(SocketConstants.SEARCH_RESULTS, arr);
			trace('\n--------- Search for artist ----------');
			for (i in 0 ... arr.length)
			{
				var artist : SpotifyArtist = arr[i];
				trace('$i. ' + StringTools.urlDecode(artist.name) + ' - ' + artist.id);
			}
			trace('\n');

			// [mck] if there is only one artist.. just start the process
			if(arr.length == 1) 
			{
				var data : SpotifyArtist = arr[0];
				noIdeaHowToCallThisFunction (data.id , data);
			}
		});
	} 

	private function getRelatedArtists(	id:String ):Void
	{
		trace(SERVER +  "getRelatedArtists :: id: " + id );
		
		// [mck] clear the database and place a new related artist in there
		_dbRelatedArtists.remove({ }, { multi: true }, function (err, numRemoved) {
			_dbRelatedArtists.loadDatabase(function (err) {
				// done
			});
		});

		spotify.getArtistRelatedArtists(id);
		spotify.once(SpotifyApi.GET_ARTIST_RELATED_ARTISTS, function(json:Dynamic, arr:Array<SpotifyArtist>)
		{
			_socket.emit(SocketConstants.SEARCH_RESULTS, arr);
			trace('\n--------- Related artists ----------');
			// Fs.writeFile(_dbRelatedArtists.get'/path/to/file', '', function(){console.log('done')})
			for (i in 0 ... arr.length)
			{
				var artist : SpotifyArtist = arr[i];
				trace('$i. ' + artist.name + ' - ' + artist.id);
				artist._id = (i+1);
				_dbRelatedArtists.insert (artist);

				var _vo : model.StoreVO = new model.StoreVO();
				_vo.name = artist.name;
				_vo.id = artist.id;
				_vo._id = (i + 2);
				_vo.spotifyArtist = artist;

				_dbPlaylist.insert(_vo);
			}
			trace('\n');
		});
	}

	private function getArtistTopTracks(id:String):Void
	{
		trace(SERVER +  "getArtistTopTracks :: id: " + id );

		// [mck] clear the database and place a new related artist in there
		_dbTopTracks.remove({ }, { multi: true }, function (err, numRemoved) {
			_dbTopTracks.loadDatabase(function (err) {
				// done
			});
		});

		spotify.getArtistTopTracks(id);
		spotify.once(SpotifyApi.GET_ARTIST_TOP_TRACKS, function(json:Dynamic, arr:Array<SpotifyArtistTopTracks>)
		{
			_socket.emit(SocketConstants.TOP_RESULTS, arr);
			trace('\n--------- Artist Top Tracks ----------');
			for (i in 0 ... arr.length)
			{
				var track : SpotifyArtistTopTracks = arr[i];
				trace('$i. ' + StringTools.urlDecode (track.name) + ' - ' + track.id);

				track._id = (i + 1);

				_dbTopTracks.insert(track);
			}

			// store latest artist // also the first in the _dbTopTracks database
			_dbCurrentArtist.insert(arr[0]);

			// [mck] update the visual
			_socket.emit(SocketConstants.PROFILE_UPDATE, arr[0]);
			
			trace('\n');
			searchYoutube(arr[0]);
		});
	}


	private function searchYoutube(track : SpotifyArtistTopTracks ):Void
	{
		trace( SERVER +  "searchYoutube :: track.artists[0].name: " + track.artists[0].name );
		trace( SERVER +  "searchYoutube :: track.name: " +  StringTools.urlDecode(track.name) );
		youtube.search( track.artists[0].name + " " + StringTools.urlDecode(track.name), AppConstants.YOUTUBE_SEARCH_LIMIT);
		youtube.once(YoutubeApi.SEARCH_ARTISTS, function(json:Dynamic, arr:Array<YoutubeItem>){
			trace('\n--------- Youtube search results ----------');

			if(arr.length == 0){
				trace( "OHHHHH no search");
			}

			var count = 0;
			var notUndefinend : Array<YoutubeItem> = [];
			// [mck] Rye Rye gives some strange videoId == 'undefined'
			// make sure we download something
			for (i in 0 ... arr.length) {
				var searchItem : YoutubeItem = arr[i];
				trace('$i. ' + searchItem.snippet.title + ' - ' + searchItem.id.videoId);
				if(searchItem.id.videoId != null) notUndefinend.push (searchItem);
			}
			trace("\n");
			// downloadFromYoutube(track, arr[count].id.videoId);
			// downloadFromYoutube(track, notUndefinend[count].id.videoId);
			// 
			// 
			_socket.emit(SocketConstants.YOU_PLAYER , StringTools.urlEncode (notUndefinend[count].id.videoId));
		});
	}




/*
	private function downloadFromYoutube(track:SpotifyArtistTopTracks,id : String):Void
	{
		createFolder(track);
		
		var artistName = track.artists[0].name;
		var albumName = track.album.name;
		// Skrillex & Diplo - Skrillex and Diplo Present Jack Ü (iTunes) [2015]
		//  01. Don't Do Drugs Just Take Some Jack Ü.m4a
		var tackName = StringTools.lpad(Std.string(track.track_number), "0", 2) + ". " + StringTools.urlDecode (track.name); 
		var folderName = artistName + " - " + albumName;
		var url = "http://www.youtube.com/watch?v="+id;

		// var path = "/_cache/" + folderName + '/'+tackName+'.mp3';
		var path = "/_cache/" + folderName + '/' + tackName;

		trace(SERVER + "path: " + path);

		// [mck] TODO there is a pattern down here, cut it up in function or classes 
		// [mck] check if files exists, if not download otherwise play existing
		Fs.open(Node.__dirname + "/public" + path + '.mp3', FsOpenFlag.Read,  function (err, fd){
			if(err == null){
				_socket.emit(SocketConstants.PLAYER , StringTools.urlEncode(path+'.mp3'));
				trace( "fd: " + fd );
			} else {
				trace( "err: " + err );
				trace( "path: " + path );


				// [mck] only works for osx, but will work in the future
				var osFolder = 'osx';
				switch (Os.platform()) {
					case 'darwin' 	: osFolder = 'osx';
					case 'freebsd' 	: osFolder = 'osx';
					case 'linux' 	: osFolder = 'osx';
					case 'sunos' 	: osFolder = 'osx';
					case 'win32' 	: osFolder = 'osx';
					default			: osFolder = 'osx';
				}

				/ *		
				var youtubedl = new utils.ShellUtil( Node.__dirname + '/public/app/' + osFolder + '/youtube-dl',['--version']);
				youtubedl.on (ShellUtil.EVENT_DATA, function (e:String){
					trace(ShellUtil.EVENT_DATA + " :: e: " + e );
				});
				* /
				
				// [mck] use the local youtube-dl version
				var shellUtil = new utils.ShellUtil( Node.__dirname + '/public/app/' + osFolder + '/youtube-dl',['-o', Node.__dirname + '/public' + path + '.%(ext)s','-f','bestaudio', '-x', '--audio-format' , 'mp3', '--ffmpeg-location' , Node.__dirname + '/public/app/' + osFolder , url]);
				// var shellUtil = new utils.ShellUtil( Node.__dirname + '/public/app/' + osFolder + '/youtube-dl',['-o', Node.__dirname + '/public' + path + '.%(ext)s','-f','bestaudio', '-x', '--audio-format' , 'mp3', '--ffmpeg-location' , Node.__dirname + '/public/app/' + osFolder , '-k', url]);
				// var shellUtil = new utils.ShellUtil('youtube-dl',['-o', Node.__dirname + '/public' + path + '.%(ext)s','-f','bestaudio', '-x', '--audio-format' , 'mp3',  '-k', url]);
				// var shellUtil = new utils.ShellUtil('youtube-dl',['-o', Node.__dirname + "/public" + path + '.%(ext)s','-f','bestaudio', '-x', '--verbose', '-k', url]);
				// var shellUtil = new utils.ShellUtil('youtube-dl',['-o', Node.__dirname + "/public" + path + '.%(ext)s','-f','18/22', '-x', '--verbose', '--audio-format' , 'mp3', '-k', url]);
				// var shellUtil = new utils.ShellUtil('youtube-dl',['-o', Node.__dirname + path,'-f','18/22', '-x', '--audio-format' , 'mp3', url]);
				shellUtil.on (ShellUtil.EVENT_DATA, function (e:String){

					trace(ShellUtil.EVENT_DATA + " :: e: " + e );

					if(e.toString().indexOf("[download]") != -1) 
					{
						// [mck] cleaning up the output
						var _clean = e.toString().split("\t").join("").split("   ").join(" ").split("  ").join(" ");
						var _cleanArray = _clean.split(" ");

						var _percentage = _cleanArray[1];
						var _totalMib = _cleanArray[3];
						var _speedMib = _cleanArray[5];
						var _time = _cleanArray[7];

						var _percentageFloat : Float = cast (_percentage.split("%").join(""));

						_socket.emit(SocketConstants.PERCENTAGE , _percentageFloat);

						if(_cleanArray.length == 8) trace('[mck] $_percentage of $_totalMib at $_speedMib ETA $_time');
					}


					if(e.toString().indexOf("[ffmpeg]") != -1) 
					{
						_socket.emit(SocketConstants.CONVERT , "Converting video to music...");
					}

					if(e.toString().indexOf("[youtube]") != -1) 
					{
						_socket.emit(SocketConstants.CONVERT , "Getting data from youtube...");
					}

				});
				shellUtil.on (ShellUtil.EVENT_END, function (e){
					trace(SERVER + ShellUtil.EVENT_END +  " :: e: " + e );
					Fs.open(Node.__dirname + "/public" + path +'.mp3', FsOpenFlag.Read, function (err, fd){
						if(err == null){
							_socket.emit(SocketConstants.PLAYER , StringTools.urlEncode (path+'.mp3'));
						} else {
							trace(SERVER + "oeps");
						}
					});
				});

				shellUtil.on (ShellUtil.EVENT_ERROR, function (e){
					trace("[" + ShellUtil.EVENT_ERROR + "] "  +  " :: e: " + e );
				});

				shellUtil.on (ShellUtil.EVENT_CLOSE, function (e){
					trace(ShellUtil.EVENT_CLOSE  + " :: e: " + e );
				});
			
			}

		});		


	}

	private function createFolder(track : SpotifyArtistTopTracks):Void
	{
		var artistName = track.artists[0].name;
		var albumName = track.album.name;
 
		var folderName = artistName + " - " + albumName;

		trace(SERVER + "path: " + Node.__dirname + '/public/_cache/' + folderName);

		Mkdirp.mkdirp(Node.__dirname + '/public/_cache/' + folderName, function (err:Dynamic, made:String) 
		{
			if (err != null) 
				trace (SERVER + 'err : $err');
			else if(made != null)
				trace(SERVER + 'created folder : $made');
		});   
	}

	*/

	// ____________________________________ DEBUG ____________________________________

	/**
	 * [debug description]
	 * @return [description]
	 */
	/*
	static public function debug():Void
	{
		var spotify = new SpotifyApi();
		spotify.searchArtists('underworld');
		spotify.on(SpotifyApi.GET_ARTIST_RELATED_ARTISTS, function(json:Dynamic, arr:Array<SpotifyArtist>){
			trace('\n--------- related artists ----------');
			for (i in 0 ... arr.length)
			{
				var artist : SpotifyArtist = arr[i];
				trace('$i. ' + artist.name + ' - ' + artist.id);
				// generate list with related artist
				// queue download top tracks
			}
		});
		spotify.on(SpotifyApi.GET_ARTIST_TOP_TRACKS, function(json:Dynamic, arr:Array<SpotifyArtistTopTracks>){
			trace('\n--------- top tracks ----------');
			for (i in 0 ... arr.length)
			{
				var track : SpotifyArtistTopTracks = arr[i];
				trace('$i: ' + track.artists[0].name + ' - ' + track.name + ' - ' + track.album.name);
				// generate list with popular
			}
		});
	}



	static public function test ():Void
	{
		trace("TEST...");

		// var _spawn = ChildProcess.spawn(cmd, args);
		var _exec = ChildProcess.exec("youtube-dl http://www.youtube.com/watch?v=1sVrg5FxNf8 --verbose", {}, function (error, stdout, stderr) {
				
				trace("------>");

				trace('stdout: ' + stdout);
				trace('stderr: ' + stderr);
				if (error != null) {
					trace('exec error: ' + error);
				}
			});

	}

	static public function main()
	{
		var main = new MainServer();
		// Main.debug();
		// Main.test();
	}
	*/
}