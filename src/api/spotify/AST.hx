package api.spotify;

class AST
{

	//  abstract syntax tree (AST)


}

typedef SpotifyArtistTopTracks = 
{
	var album : SpotifyArtistAlbum;
	var artists : Array<SpotifyArtist>;
	var available_markets : Array<String>; // ["AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "IE", "IS", "IT", "LI", "LT", "LU", "LV", "MC", "MT", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "RO", "SE", "SG", "SI", "SK", "SV", "TR", "TW", "UY"],
	var disc_number : Int; // 2,
	var duration_ms : Int ; // 456480,
	var explicit : Bool ; // false,
	var external_ids : {
		var isrc : String; // "UK7EF9500001"
	};
	var external_urls : {
		var spotify : String;// "https://open.spotify.com/track/1zsDbmrf4ZkjW5hsSsaDjO"
	};
	var href : String; //https://api.spotify.com/v1/tracks/1zsDbmrf4ZkjW5hsSsaDjO",
	var id : String; //1zsDbmrf4ZkjW5hsSsaDjO",
	var name : String; //Born Slippy (Nuxx)",
	var popularity : Int; // 58,
	var preview_url : String; //https://p.scdn.co/mp3-preview/7a9fb0ae1d6eb65d255161c00b9ba9140550f396",
	var track_number : Int; // 1,
	var type : String; //track",
	var uri : String; //spotify:track:1zsDbmrf4ZkjW5hsSsaDjO"


	// [mck] hacking database 
	@optional var _id : Int;

}

typedef SpotifyArtistAlbum = 
{
	var album_type : String; //album",
	var available_markets : Array<String>;// ["AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "IE", "IS", "IT", "LI", "LT", "LU", "LV", "MC", "MT", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "RO", "SE", "SG", "SI", "SK", "SV", "TR", "TW", "UY"],
	var external_urls : {
		var spotify : String; //https://open.spotify.com/album/43baGAToTn6j7MMy7YU0yT"
	};
	var href : String; //https://api.spotify.com/v1/albums/43baGAToTn6j7MMy7YU0yT",
	var id : String; //43baGAToTn6j7MMy7YU0yT",
	var images : Array<SpotifyImage>;
	var name : String; //1992 - 2012",
	var type : String; //album",
	var uri : String; //spotify:album:43baGAToTn6j7MMy7YU0yT"
};

typedef SpotifyImage = 
{
	var height : Int; // 200,
	var url : String; //https://i.scdn.co/image/f6402db407aa3a5d93b5fc561d0e0d4d44543057",
	var width : Int; // 200
}

// typedef SpotifyArtists = 
// {
// 	var external_urls : {
// 		var spotify : String; //https://open.spotify.com/artist/1PXHzxRDiLnjqNrRn2Xbsa"
// 	};
// 	var href : String; //https://api.spotify.com/v1/artists/1PXHzxRDiLnjqNrRn2Xbsa",
// 	var id : String; //1PXHzxRDiLnjqNrRn2Xbsa",
// 	var name : String; //Underworld",
// 	var type : String; //artist",
// 	var uri : String; //spotify:artist:1PXHzxRDiLnjqNrRn2Xbsa"

// }

typedef SpotifyOptions =
{
	var limit:Int;
	var offset:Int;
}

typedef SpotifyArtist = 
{
	var external_urls : {
        var spotify : String; // "https://open.spotify.com/artist/1PXHzxRDiLnjqNrRn2Xbsa"
    };
	@optional var followers : {
    	var href : String;// null,
    	var total : Int; // 74023
    };
	@optional var genres : Array<String>; // ["big beat", "electronic"],
	var href : String; // "https://api.spotify.com/v1/artists/1PXHzxRDiLnjqNrRn2Xbsa",
	var id : String; //1PXHzxRDiLnjqNrRn2Xbsa",
	@optional var images : Array<SpotifyImage>;
	var name : String; // "Underworld",
	@optional var popularity : Int ; // 57,
	var type : String; // artist",
	var uri : String; // "spotify:artist:1PXHzxRDiLnjqNrRn2Xbsa"

	// [mck] hacking 
	@optional var _id : Int;
	@optional var name_urlencode : String; // "Underworld",
}

//typedef SpotifyImage = {
//	var height : Int; // 200,
//	var url : String; //https://i.scdn.co/image/f6402db407aa3a5d93b5fc561d0e0d4d44543057",
//	var width : Int; // 200
//
//}