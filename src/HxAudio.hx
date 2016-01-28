package ;

import js.html.AudioElement;
import js.html.Element;
import js.html.MouseEvent;

/**
 * @author Matthijs Kamstra  aka [mck]
 * MIT
 * http://www.matthijskamstra.nl
 */
class HxAudio
{


	private var doc = js.Browser.document;
	private var win = js.Browser.window;

	private var audio : AudioElement;

	public var onClickHandler(get_onClickHandler, set_onClickHandler):Dynamic;
	private var _onClickHandler:Dynamic;

	function get_onClickHandler():Dynamic {
		return _onClickHandler;
	}
	function set_onClickHandler(value:Dynamic):Dynamic {
		return _onClickHandler = value;
	}


	public var onEndedHandler(get_onEndedHandler, set_onEndedHandler):Dynamic;
	private var _onEndedHandler:Dynamic;

	function get_onEndedHandler():Dynamic {
		return _onEndedHandler;
	}
	function set_onEndedHandler(value:Dynamic):Dynamic {
		return _onEndedHandler = value;
	}




	public function new():Void
	{
	}

	// ____________________________________ init (static) html  ____________________________________

	public function init(id:String):Void
	{
		var wrapper = doc.getElementById(id);

		if(wrapper.getElementsByTagName('audio')[0] == null) {
			trace("no <audio> tag in element $id");
			return;
		}

		var audio 		= cast (wrapper.getElementsByTagName('audio')[0], AudioElement);
		var btn 		= wrapper.getElementsByClassName('play-pause')[0];
		var playhead 	= wrapper.getElementsByClassName('playhead')[0];
		var progress	= wrapper.getElementsByClassName('progress')[0];
		var loaded 		= wrapper.getElementsByClassName('loaded')[0];
		var duration 	= wrapper.getElementsByClassName('duration')[0];
		var played 		= wrapper.getElementsByClassName('played')[0];
		var scrubber 	= wrapper.getElementsByClassName('scrubber')[0];

		btn.onclick = function(e : MouseEvent)
		{
			if(audio.paused){
				audio.play();
			} else {
				audio.pause();
			}
		}

		scrubber.onclick = function (e : MouseEvent)
		{	
			// preloading of audio is false, should do something clever
			if(Math.isNaN(audio.duration))
			{
				trace("start loading data?");
				return;
			}
			var relativeLeft = e.clientX - getLeftOffset(scrubber);
			var percent = relativeLeft / scrubber.offsetWidth;
			audio.currentTime = audio.duration * percent;
		}

		audio.ontimeupdate = function (e)
		{
			var percent =  (audio.currentTime / audio.duration);

			var p = audio.duration * percent;
			var m = Math.floor(p / 60);
			var s = Math.floor(p % 60);
			played.innerHTML = ((m<10?'0':'')+m+':'+(s<10?'0':'')+s);

			progress.style.width = (100 *percent) + '%';
			playhead.style.marginLeft = (100 *percent) + "%";

			if(audio.paused){
				btn.className = "play-pause play";
			} else {
				btn.className = "play-pause pause";
			}

			if(onClickHandler != null) Reflect.callMethod(this, onClickHandler,[audio.paused]);

			onTimeUpdate(e);
		}

		audio.onended = function (e)
		{
			if(onEndedHandler != null) Reflect.callMethod(this, onEndedHandler,[]);

			btn.className = "play-pause play";

			onEnded(e);
		}

		audio.onloadstart = function (e)
		{
			onLoadStart(e);
		}

		/**
		 * doesn't work yet
		 */
		audio.onprogress = function (e)
		{
			if(audio.buffered.length == 0) return;
			var bufferedEnd = audio.buffered.end(audio.buffered.length - 1);
			var duration =  audio.duration;
			
			if (duration > 0) 
				loaded.style.width = ((bufferedEnd / duration)*100) + "%";

			onProgress(e);
		}

		/**
		 * this doesn't work for some reason
		 */
		audio.onerror = function (e)
		{
			trace( "## debug" );
			btn.className = "play-pause error";

			onError(e);
		}

		/**
		 * the duration is only available when audio is loaded
		 */
		audio.onloadeddata = function (e)
		{
			var m = Math.floor(audio.duration / 60);
			var s = Math.floor(audio.duration % 60);
			duration.innerHTML = ((m<10?'0':'')+m+':'+(s<10?'0':'')+s);	

			onLoadedData(e);
		}

	}

	// ____________________________________ util ____________________________________

	private function getLeftOffset(el : Element):Int
	{
		var _leftOffset = 0;
		do{			
			_leftOffset += el.offsetLeft;
			el = el.offsetParent;
		}
		while (el.offsetParent != null);
		return _leftOffset;
	}


	// ____________________________________ external audio function (override)  ____________________________________


	public function onTimeUpdate(e):Void { }
	public function onEnded(e):Void { }
	public function onLoadStart(e):Void { }
	public function onProgress(e):Void { }
	public function onError(e):Void { }
	public function onLoadedData(e):Void { }


	

}