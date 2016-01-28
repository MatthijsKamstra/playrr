package api.youtube;


import api.youtube.AST;

import js.node.Fs;
import js.Node;
import js.npm.YoutubeNode;

import model.AppConstants;

import js.node.events.EventEmitter;

class YoutubeApi extends EventEmitter<Dynamic>
{

	public static inline var DEBUG : Bool = false;


	public static inline var SEARCH_ARTISTS : String = 'SEARCH_ARTISTS';
	public static inline var ERROR : String = 'error';

	
	private var youTube : YoutubeNode = new YoutubeNode();


	public function new():Void
	{
		trace('Start YoutubeApi');
		super();

		youTube.setKey(AppConstants.YOUTUBE_API_KEY);

		// youTube.addParam("order", "rating"); //  Resources are sorted from highest to lowest number of views.
		// youTube.addParam("type", "video"); //  The type parameter restricts a search query to only retrieve a particular type of resource

		
	}

	/**
	 * Get all artist with the name 

	 * @example		var _youtubeApi : YoutubeApi = new YoutubeApi();
	 *           	_youtubeApi.search('underworld' , 10 });
	 *  
	 * @param  q      		the name to look for
	 * @param  ?limit 		how many results we want back
	 */
	public function search(q:String, ?limit:Int = 10):Void
	{
	    
		youTube.search(q, limit, function(err, data) 
		{
			if (err != null)
			{
				trace('Something went wrong!' + err);
				emit(ERROR,'youtube search : error: ' + err);
			} else
			{
				// trace(haxe.Json.stringify(data));
				var _json : Dynamic = data;
				// var _json : AST.YoutubeSearchResults = data;
				var arr : Array<AST.YoutubeItem> = _json.items;
				// trace( "arr.length: " + arr.length );

				// var artist : AST.SpotifyArtist = arr[0];


//				trace(artist.name);
//				trace(artist.id);

				// getArtistRelatedArtists(artist.id);
				// getArtistTopTracks(artist.id);

				if(DEBUG) Fs.writeFile(Node.__dirname + '/_debug/youtube_searchArtists.json', haxe.Json.stringify(data), null);

				emit(SEARCH_ARTISTS, _json, arr);
			}


	
		});

	}


}