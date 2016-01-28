package js.npm;

/**
 * https://github.com/thelinmichael/spotify-web-api-node
 */

extern class SpotifyWebApiNode
implements npm.Package.Require<"spotify-web-api-node" , "^2.1.0">
{

	public function new (credentials:{clientId:String, clientSecret:String, ?redirectUri:String});

	/**
	* Search for an artist.
	* @param {string} query The search query.
	* @param {Object} [options] The possible options, e.g. limit, offset.
	* @param {requestCallback} [callback] Optional callback method to be called instead of the promise.
	* @example searchArtists('David Bowie', { limit : 5, offset : 1 }).then(...)
	* @returns {Promise|undefined} A promise that if successful, returns an object containing the
	*          search results. The result is paginated. If the promise is rejected,
	*          it contains an error object. Not returned if a callback is given.
	*/
	public function searchArtists (query:String, options:{?limit:Int, ?offset:Int}, callback:String -> Null<Dynamic> -> Void):Void;
	
	public function searchAlbums (query:String, options:{?limit:Int, ?offset:Int}, callback:String -> Null<Dynamic> -> Void):Void;

	public function searchTracks (query:String, options:{?limit:Int, ?offset:Int}, callback:String -> Null<Dynamic> -> Void):Void;

	public function searchPlaylists (query:String, options:{?limit:Int, ?offset:Int}, callback:String -> Null<Dynamic> -> Void):Void;
	
	public function getArtist (artistId:String, callback:String -> Null<Dynamic> -> Void):Void;

	public function getArtists (artistIds:Array<String>, callback:String -> Null<Dynamic> -> Void):Void;

	public function getArtistAlbums (artistId:String,  options:{?limit:Int, ?offset:Int},  callback:String -> Null<Dynamic> -> Void):Void;


	// https://developer.spotify.com/web-api/get-artists-top-tracks/
	// https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
	/**
	* Get an artist's top tracks.
	* @param {string} artistId The artist's ID.
	* @param {string} country The country/territory where the tracks are most popular. (format: ISO 3166-1 alpha-2)
	* @param {requestCallback} [callback] Optional callback method to be called instead of the promise.
	* @example getArtistTopTracks('0oSGxfWSnnOXhD2fKuz2Gy', 'GB').then(...)
	* @returns {Promise|undefined} A promise that if successful, returns an object containing the
	*          artist's top tracks in the given country. If the promise is rejected,
	*          it contains an error object. Not returned if a callback is given.
	*/
	public function getArtistTopTracks (artistId:String,  country:String,  callback:String -> Null<Dynamic> -> Void):Void;

	/**
	* Get related artists.
	* @param {string} artistId The artist's ID.
	* @param {requestCallback} [callback] Optional callback method to be called instead of the promise.
	* @example getArtistRelatedArtists('0oSGxfWSnnOXhD2fKuz2Gy').then(...)
	* @returns {Promise|undefined} A promise that if successful, returns an object containing the
	*          related artists. If the promise is rejected, it contains an error object. Not returned if a callback is given.
	*/
	public function getArtistRelatedArtists (artistId:String, callback:String -> Null<Dynamic> -> Void):Void;

	public function getAlbumTracks (albumId:String,  options:{?limit:Int, ?offset:Int},  callback:String -> Null<Dynamic> -> Void):Void;

	public function getTrack (trackId:String,  options:{?limit:Int, ?offset:Int}, callback:String -> Null<Dynamic> -> Void):Void;

	public function getTracks (trackId:Array<String>,  options:{?limit:Int, ?offset:Int}, callback:String -> Null<Dynamic> -> Void):Void;

	public function getAlbum (albumId:String,  options:{?limit:Int, ?offset:Int}, callback:String -> Null<Dynamic> -> Void):Void;



	// incomplete externs

}		