package ;

import model.AppConstants;

import jQuery.*;
import js.Browser;
import js.html.*;

import api.spotify.AST;
import api.spotify.SpotifyApi;

import model.SearchVO;
import model.SocketConstants;

/**
 * @author Matthijs Kamstra aka [mck]
 * MIT
 * http://www.matthijskamstra.nl
 */
class MainClient
{
	private static var CLIENT : String = "[CLIENT] : ";

	private var _doc = js.Browser.document;
	private var _win = js.Browser.window;

	private var _trackinfo : Element;
	private var _search : Element;
	private var _player : Element;
	private var _playlist : Element;
	private var _current : Element;
	private var _cover : Element;
	
	private var _submitBtn : Element;
	private var _inputSearch : InputElement;

	private var _socket : Dynamic;

	private var _youtubeStuff = new YoutubeStuff();


	/**
	 * 
	 */
	public function new ()
	{
		new JQuery(Browser.document).ready ( function ()
		{
			trace (CLIENT + "MainClient document ready!"); 
			init();
		});
	}


	// ____________________________________ init stuff ____________________________________

	private function init():Void
	{
		// [mck] for debugging purposses
		#if(debug)
		// [mck] somewhat more nice to watch at when debuggin in browser
		var _mock = _doc.getElementById("mock");
		_mock.classList.add("mock");
		#end

		_submitBtn   = js.Browser.document.getElementById("submitBtn");
		_inputSearch = cast (js.Browser.document.getElementById("inputSearch"), js.html.InputElement);

		_trackinfo   = js.Browser.document.getElementById("trackinfo");
		_cover       = js.Browser.document.getElementById("cover");
		_search      = js.Browser.document.getElementById("search");
		_player      = js.Browser.document.getElementById("player");
		_playlist    = js.Browser.document.getElementById("playlist");
		_current     = js.Browser.document.getElementById("current");

		// defaults
		resetAll();

		// [mck] force the playlist height to take up the rest of the window-height
		updatePlaylistHeight();

		// socket
		_socket = js.browser.SocketIo.connect(AppConstants.IP + ":" + AppConstants.PORT);
		_socket.on('connect', function(data)
		{
			_socket.emit('screen');
			
			_socket.on('message' , function ( data : Dynamic) {
				trace(CLIENT+"hello from server: " + data.message);
			});
			
			_socket.on(SocketConstants.PROFILE_UPDATE , function ( data : SpotifyArtistTopTracks) {
				// trace(CLIENT + "[" +SocketConstants.PROFILE_UPDATE  + "] " + "data: " + data);
				updateProfile(data);
				updateSelection(data);
			});
			
			_socket.on(SocketConstants.TOP_RESULTS, function ( arr:Array<SpotifyArtistTopTracks>) {
				// TODO do something clever here
				// trace(":: topresults : arr: " + arr);
			});

			_socket.on(SocketConstants.SEARCH_RESULTS , function ( arr:Array<SpotifyArtist>) {
				updateList(arr);
				isLoader(false);
			});

			_socket.on(SocketConstants.CURRENT , function (artist:SpotifyArtist) {
				updateCurrent(artist);
			});

			_socket.on(SocketConstants.PLAYER, function ( url : String ) {
				trace(CLIENT+  "[" +SocketConstants.PLAYER + "] " + "url: " + url );
				if(url == "/sfx/chime_tone.mp3"){
					initStartScreen();
				}
			});


			_socket.on(SocketConstants.YOU_PLAYER, function ( url : String ) {
				trace(CLIENT+  "[" +SocketConstants.YOU_PLAYER + "] " + "url: " + url );
				updateIframePlayer(StringTools.urlDecode(url));
			});
		});


		// [mck] hack hack hack
		_youtubeStuff.build('sQiI5k8FS7A');
		_youtubeStuff.socket = _socket; // feels over the top: investigate!

		
		// [mck] lets try some jquery stuff, just because I can!
		new JQuery('.track-play').click( function(e:Dynamic)
		{
			// _audio.play();
			_youtubeStuff.playVideo();
		});
		new JQuery('.track-next').click( function(e:Dynamic)
		{
			var s = new model.SearchVO();
			// s.name = _audio.currentSrc;
			_socket.emit(SocketConstants.NEXT_TRACK, s);
		});
		new JQuery('.track-previous').click( function(e:Dynamic)
		{
			var s = new model.SearchVO();
			// s.name = _audio.currentSrc;
			_socket.emit(SocketConstants.PREV_TRACK, s);
		});
		new JQuery('.search-icon').click(function (e:Dynamic)
		{
			var bottom : Int = Std.parseInt (new JQuery('#bottomslidein').css('bottom'));
			if(bottom < 0){
				new JQuery('#bottomslidein').animate({'bottom': "0px"}, 500);
			} else {
				new JQuery('#bottomslidein').animate({'bottom': "-40px"}, 500);
			}
		});


		// [mck] back to vanilla js: make sure the enter doesn't refresh the whole page
		_inputSearch.onkeydown = function (e)
		{
			if(e.keyCode == 13) {
				e.preventDefault();
				onSubmit (_inputSearch.value);
				return false;
			} else {
				return true;
			}
		};

		_submitBtn.onclick = function ( e : js.html.MouseEvent )
		{
			e.preventDefault();
			onSubmit (_inputSearch.value);
		}

	}


	private function initStartScreen():Void
	{
		_doc.getElementById('start').style.display = "inline";

		var _submitBtn2   = js.Browser.document.getElementById("submitBtn2");
		var _inputSearch2 = cast (js.Browser.document.getElementById("inputSearch2"), js.html.InputElement);

		var temp = ["M.I.A.", "Mystikal", "Skrillex", 'Naughty by Nature'];
		_inputSearch2.value = temp[Math.round(Math.random() * temp.length-1)];

		_inputSearch2.onkeydown = function (e)
		{
			if(e.keyCode == 13) {
				e.preventDefault();
				onSubmit (_inputSearch2.value);
				return false;
			} else {
				return true;
			}
		};

		_submitBtn2.onclick = function ( e : js.html.MouseEvent )
		{
			e.preventDefault();
			onSubmit (_inputSearch2.value);
		}

	}

	private function onSubmit (str:String)
	{
		// [mck] hide start screen... little brute force
		_doc.getElementById('start').style.display = "none";

		var _searchVO = new model.SearchVO();
		_searchVO.name = StringTools.urlDecode(str);

		_socket.emit(SocketConstants.SEARCH, _searchVO );

		isLoader(true);
		isSearch(false);
	}


	// ____________________________________ update section ____________________________________
	
	private function updateIframePlayer(id:String):Void
	{
		_youtubeStuff.loadVideoById(id);
	}
	

	public function updateSelection(toptrack : SpotifyArtistTopTracks):Void 
	{
		var _artist : SpotifyArtist = toptrack.artists[0];
		var _id  = _artist.id;
		var arr = new JQuery('.artist-list-item');
		// trace(arr);
		for (i in 0 ... arr.length) 
		{
			// [mck] remove previous set "selected" styling
			if(new JQuery(arr[i]).hasClass('selected')){
				new JQuery(arr[i]).removeClass('selected');
			}
			if (new JQuery(arr[i]).data("artistid") == _id ){
				// trace("found it!");
				var scrollTo = new JQuery(arr[i]);
				var container = new JQuery('#playlist');
				scrollTo.addClass('selected');
				container.animate({'scrollTop': scrollTo.offset().top - container.offset().top + container.scrollTop()});
			}
		}
	}

	public function updateProfile(toptrack : SpotifyArtistTopTracks):Void
	{
		if(toptrack == null) {
			var s = new model.SearchVO();
			// s.name = _audio.currentSrc;
			_socket.emit(SocketConstants.NEXT_TRACK, s);
			return;
		}

		var _artist : SpotifyArtist = toptrack.artists[0];
		var _album : SpotifyArtistAlbum = toptrack.album;

		_inputSearch.value = _artist.name;

		var _temp = 0;
		var _url = 'images/icons/no-profile.jpg';

		if(_album.images != null)
		{
			if (_album.images.length != 0)
			{
				for (i in 0 ... _album.images.length) 
				{
					var img : SpotifyImage = _album.images[i];
					if(img.height > _temp){
						_temp = img.height;
						_url = img.url;
					}
				}
			}
		}

		var _popularity = (toptrack.popularity != null) ? toptrack.popularity : 0;
		var _html = '';
		// _html += '<span class="user pull-left" style="background-image:url(\''+_url+'\')"></span>';
		_html += '<h1>'+StringTools.urlDecode(_artist.name)+'</h1>';
		_html += '<h2>'+_album.name+'</h2>';
		_html += '<h3>'+toptrack.name+'</h3>';
		_html += '<!--<p>'+_popularity+'</p>-->';

		_trackinfo.innerHTML = _html;

		// change big background image
		_cover.style.backgroundImage = "url("+_url+")";
	}


	private function updateList(arr:Array<SpotifyArtist>):Void
	{
		var _html = "<ul>";
		for (i in 0 ... arr.length) 
		{
			var _artist : SpotifyArtist = arr[i];
			var _url = '';
			// TODO : [mck] get the biggest image, so make this better.
			if(_artist.images.length != 0) _url = _artist.images[0].url;

			var liClass = 'even';			
			if (i % 2 == 0) { liClass  = "odd"; } 

			_html += '<li data-id="'+i+'" data-artistid="'+_artist.id+'" class="'+liClass+' artist-list-item">';
			_html += '	<a href="#">';
			_html += '		<span class="playlist-nr">'+(i+1)+'.</span>';
			_html += '		<span class="playlist-artist">'+StringTools.urlDecode (_artist.name)+'</span>';
			_html += '		<div class="playlist-img" style="background-image:url('+_url+')" ></div>';
			_html += '	</a>';
			_html += '</li>';

		}
		_html += "</ul>";

		_playlist.innerHTML = _html;

		updatePlaylistHeight();

		new JQuery('li.artist-list-item').click( function(e:Dynamic)
		{
			// [mck] IMPORTANT this is when somebody forces to change the playlist!!!!
			var _id = new JQuery(e.currentTarget).data("id");
			var _artist : SpotifyArtist = arr[_id];

			_inputSearch.value = StringTools.urlDecode(_artist.name);
			
			updateCurrent(_artist);
			isLoader(true);

			var _searchVO = new SearchVO();
			_searchVO.name = StringTools.urlEncode(_artist.name);
			_searchVO.id = _artist.id;
			_searchVO.spotifyArtist = _artist;

			// [mck] with a click send this to the server
			_socket.emit(SocketConstants.SEARCH_WITH_ID, _searchVO );
		});
		
	}

	private function updateCurrent(artist : SpotifyArtist = null)
	{
		if (artist == null) {
			_current.innerHTML = '<p>Current playlist is based upon <b>*</b></p>';
		} else {
			_current.innerHTML = '<p>Current playlist is based upon <b><a href="'+artist.external_urls.spotify+'" target="_blank"><!--<img src="/images/icons/Spotify-icon.png" style="width:15px;height:15px" -->'+StringTools.urlDecode (artist.name)+'</a></b></p>';
		}
	}

	// [mck] force the playlist height to take up the rest of the window-height
	private function updatePlaylistHeight()
	{
		var h = _win.innerHeight - _playlist.offsetTop;
		_playlist.style.height = h + "px";
	}

	// ____________________________________ reset ____________________________________

	private function resetAll ()
	{
		// change to default settings
		_current.innerHTML = '';
		_trackinfo.innerHTML = '';
		isLoader(false);
	}

	// ____________________________________ show and hide stuff ____________________________________

	private function isLoader(?isVisible:Bool):Void
	{
		var _loader = new JQuery("#loader");
		if(isVisible){
			_loader.fadeIn();
		} else {
			_loader.fadeOut();
		}

		// TODO : [mck] set a timer, or an error _socket.on('error')
	}

	private function isSearch(?isVisible:Bool) : Void 
	{
		var bottom : Int = Std.parseInt (new JQuery('#bottomslidein').css('bottom'));
		if (isVisible == null) isVisible = false;
		if(bottom < 0) isVisible = true;
		if(isVisible){
			new JQuery('#bottomslidein').animate({'bottom': "0px"}, 500);
		} else {
			new JQuery('#bottomslidein').animate({'bottom': "-40px"}, 500);
		}
	}



	static public function main (){
		var main = new MainClient();
	}
}