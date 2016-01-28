package model;

import api.spotify.AST;

class SearchVO {

	public var name : String;
	public var id : String;
	public var spotifyArtist : SpotifyArtist;



	public function new():Void
	{
	    
	}
	
	public function toString():String
	{
		var _str = '';
		_str += '{'; 
		_str += 'name: ' + name + ', '; 
		_str += 'id: ' + id + ', '; 
		_str += 'spotifyArtist: ' + spotifyArtist + ', '; 
		_str += '}'; 
		return _str;
	}

}