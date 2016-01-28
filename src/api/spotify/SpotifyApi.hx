package api.spotify;


import js.node.Fs;
import js.Node;

import js.npm.SpotifyWebApiNode;

import model.AppConstants;

import js.node.events.EventEmitter;

class SpotifyApi extends EventEmitter<Dynamic>
{

	public static inline var DEBUG : Bool = false;


	public static inline var SEARCH_ARTISTS : String = 'searchArtists';
	public static inline var GET_ARTIST : String = 'getArtist';
	public static inline var GET_ARTIST_TOP_TRACKS : String = 'getArtistTopTracks';
	public static inline var GET_ARTIST_RELATED_ARTISTS : String = 'getArtistRelatedArtists';
	public static inline var ERROR : String = 'error';

	private var spotifyApi:SpotifyWebApiNode;

	public function new()
	{
		trace('Start SpotifyApi');
		super();

		var obj = {
			clientId : AppConstants.SPOTIFY_CLIENT_ID,
			clientSecret : AppConstants.SPOTIFY_CLIENT_SECRET
		}
		spotifyApi = new SpotifyWebApiNode(obj);
	}


	/**
	 * Get all artist with the name 
	 *
	 * @example		var _spotifyApi : SpotifyApi = new SpotifyApi();
	 *           	_spotifyApi.searchArtists('underworld' , { limit : 5 });
	 *
	 * @param		q 			the name to look for
	 * @param		?options 	options the refine the search
	 *
	 * @return
	 */
	public function searchArtists(q:String, ?options:AST.SpotifyOptions ):Void
	{
		if(options == null) options = { limit: 50, offset: 0 };

		spotifyApi.searchArtists(q, options, function(err, data)
		{
			if (err != null)
			{
				trace('Something went wrong!' + err);
				emit(ERROR,'searchArtists : error: ' + err);
			} else
			{
				// trace('data: '+haxe.Json.stringify(data));
				var _json : Dynamic = data;
				var arr : Array<AST.SpotifyArtist> = _json.body.artists.items;

				// clean up raw data
				urlEncodeArtistArray (arr);

				if(DEBUG) Fs.writeFile(Node.__dirname + '/_debug/spotify_searchArtists.json', haxe.Json.stringify(data), null);

				emit(SEARCH_ARTISTS, arr);
			}
		});
	}

	/**
	 * getArtist(artist.id);
	 * 
	 * [getArtist description]
	 * @param  id [description]
	 * @return    [description]
	 */
	public function getArtist(id:String):Void
	{

		spotifyApi.getArtist(id, function(err, data)
		{
			if (err != null)
			{
				trace('Something went wrong!' + err);
				emit(ERROR,'getArtists : error: ' + err);
			} else
			{
				// trace('data: '+haxe.Json.stringify(data));
				var _json : Dynamic = data;
				// var arr : Array<SpotifyArtist> = _json.body.artists.items;
				// trace( "arr.length: " + arr.length );

				var artist : AST.SpotifyArtist = _json.body;

				// clean up raw data
				urlEncodeArtist(artist);


				if(DEBUG) Fs.writeFile(Node.__dirname + '/_debug/spotify_getArtist.json', haxe.Json.stringify(data),null);
				
				emit(GET_ARTIST, artist);
			}
		});
	}


	/**
	* getArtistRelatedArtists(artist.id);
	**/
	public function getArtistRelatedArtists(id:String):Void
	{
		spotifyApi.getArtistRelatedArtists(id, function(err, data)
		{
			if (err != null)
			{
				trace('Something went wrong!' + err);
				emit(ERROR,'getArtistRelatedArtists : error: ' + err);
			} else
			{
				// trace('data: '+haxe.Json.stringify(data));
				var _json : Dynamic = data;
				var arr : Array<AST.SpotifyArtist> = _json.body.artists;

				// clean up raw data
				urlEncodeArtistArray (arr);

				if(DEBUG) Fs.writeFile(Node.__dirname + '/_debug/spotify_getArtistRelatedArtists.json', haxe.Json.stringify(data),null);

				emit(GET_ARTIST_RELATED_ARTISTS,_json,arr);
			}
		});
	}

	public function getArtistTopTracks(id:String, ?iso:String = "NL"):Void
	{
		// ISO 3166-2:NL
		spotifyApi.getArtistTopTracks(id, "NL", function (err, data)
		{
			if(err != null){
				trace('Something went wrong!' + err);
				emit(ERROR,'getArtistTopTracks : error: ' + err);
			} else {
				// trace('getArtistTopTracks data: '+haxe.Json.stringify(data));
				var _json : Dynamic = data;
				var arr : Array<AST.SpotifyArtistTopTracks> = _json.body.tracks;

				
				// clean up raw data
				urlEncodeArtistTopTrackArray (arr);
				
				if(DEBUG) Fs.writeFile(Node.__dirname + '/_debug/spotify_getArtistTopTracks.json', haxe.Json.stringify(data),null);

				emit(GET_ARTIST_TOP_TRACKS, _json,arr);
			}
		});
	    
	}

	// ____________________________________ converters ____________________________________


	private function urlEncodeArtistTopTrackArray (arr : Array<AST.SpotifyArtistTopTracks> )
	{
		// [mck] I get un-encode text, but that doesn't work for me 
		for (i in 0 ... arr.length) 
		{
			var toptracks : AST.SpotifyArtistTopTracks = arr[i];

			// var artist : AST.SpotifyArtist = arr[i];
			// urlEncodeArtist ( artist );
		}
	}

	private function urlEncodeArtistArray (arr : Array<AST.SpotifyArtist> )
	{
		// [mck] I get un-encode text, but that doesn't work for me 
		for (i in 0 ... arr.length) {
			var artist : AST.SpotifyArtist = arr[i];
			urlEncodeArtist ( artist );
		}
	}


	private function urlEncodeArtist ( artist : AST.SpotifyArtist ) 
	{
		artist.name_urlencode = StringTools.urlEncode(artist.name);
	}

}


