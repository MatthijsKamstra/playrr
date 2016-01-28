package ;

import jQuery.*;
import js.Browser;
import js.html.*;

import model.SearchVO;
import model.SocketConstants;

@:expose
class YoutubeStuff  {

	private var _doc = js.Browser.document;
	
	// [mck] becoming a static heaven/hell
	private static var _player : Dynamic ;
	private static var _id:String;

	public var socket(get_socket, set_socket):Dynamic;
	private static var _socket:Dynamic;


	// https://developers.google.com/youtube/iframe_api_reference
	// https://developers.google.com/youtube/player_parameters
	public function new () { }


	/**
	 * build with id, not very usefull but needed to start everything
	 * kinda hacky, but will figure out how it should be done in the future
	 * 
	 * @param  id 		youtube id (example '79ZP946eNVQ')
	 */
	public function build(id:String)
	{
		var tag : ScriptElement = cast (_doc.createElement('script') , ScriptElement);
		tag.src = "https://www.youtube.com/iframe_api";
		var firstScriptTag = _doc.getElementsByTagName('script')[0];
		firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);


		var tag2 : ScriptElement = cast (_doc.createElement('script') , ScriptElement);
		tag2.id = 'youtubestuff';
		tag2.innerHTML = "
var player;
var yt = new YoutubeStuff();
function onYouTubeIframeAPIReady() {
	// console.log('>> onYouTubeIframeAPIReady');
	player = new YT.Player('player', {
		width: '325',
		height: '325',
		videoId: '"+id+"',
		playerVars: { 
			'autoplay': 1, 
			'controls': 1, 
			'fs' : 0,
			'iv_load_policy' : 0,
			'modestbranding' : 0,
			'rel' : 0,
			'showinfo' : 0
		},
		events: {
			'onReady': onPlayerReady,
			'onStateChange': onPlayerStateChange
		}
	});
}

function onPlayerStateChange(e) 
{
	yt.onPlayerStateChangeHandler(e);
}

function onPlayerReady (e)
{
	yt.onPlayerReadyHandler(e);
}
			";
	
		firstScriptTag.parentNode.insertBefore(tag2, firstScriptTag);



		// clean iframe id='AdSense'
	}

	// [mck] note: @keep to make sure -dce doesn't remove these

	@:keep
	public function onPlayerReadyHandler (e)
	{
		trace('YoutubeStuff.onPlayerReadyHandler');
		_player = e.target;
		// [mck] now the player is ready, feed it the correct id
		if (_id != null) loadVideoById(_id);
	}

	@:keep
	public function onPlayerStateChangeHandler (e)
	{
		trace('YoutubeStuff.onPlayerStateChangeHandler e.data: ' + e.data);
		if(e.data == '0'){
			trace('the current track/video is ended, get next');
			var s = new model.SearchVO();
			_socket.emit(SocketConstants.NEXT_TRACK, s);
			// _player.loadVideoById ('iTP6Z6ixjiA');
		}
	}	

	@:keep
	public function loadVideoById (id:String)
	{
		trace('YoutubeStuff.loadVideoById() id: $id' );
		if(_player == null) {
			trace ('ohhhhh, too fast, let youtube do it\'s stuff, let\'s wait for it..');
			_id = id;
		} else {
			_player.loadVideoById (id);
		}
	}

	@:keep
	public function playVideo()
	{
		_player.playVideo();
	}


	// ____________________________________ getter/setter ____________________________________


	function get_socket():Dynamic {
		return _socket;
	}
	function set_socket(value:Dynamic):Dynamic {
		return _socket = value;
	}


}		