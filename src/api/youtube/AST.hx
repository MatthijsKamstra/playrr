package api.youtube;

class AST  {

	//  abstract syntax tree (AST)

	public function new () 
	{
	}

}		

typedef YoutubeSearchResults = 
{

	var kind : String; //"youtube#searchListResponse",
	var etag : String; // "\"0KG1mRN7bm3nResDPKHQZpg5-do/2ID_xW1pPElHvhGeqDLdcDI61Fw\"",
	var nextPageToken : String; // "CAoQAA",
	var pageInfo : {
		var totalResults : Int;
		var resultsPerPage : Int;// 10
	};
	var items : Array<YoutubeItem>;
}


typedef YoutubeItem = 
{
	var kind : String; //youtube#searchResult",
	var etag : String; //\"0KG1mRN7bm3nResDPKHQZpg5-do/a_TKtSFObs-s2BhvMsg4-urp-nQ\"",
	var id : YoutubeID;
	var snippet : YoutubeSnippet;  
} 

typedef YoutubeID = {
	var kind : String;
	var videoId : String;
}

typedef YoutubeSnippet = 
{
	var publishedAt : String; //2013-03-30T13:23:52.000Z",
	var channelId : String; //UCubNtSi1kd9sqKQuDtg1weg",
	var title : String; //M.I.A. paper plans (afrikan boy, rey rey remix) official",
	var description : String; //"",
	var thumbnails : {
		var _default : {
			var url : String; //": "https://i.ytimg.com/vi/1sVrg5FxNf8/default.jpg"
		};
		var medium : {
			var url : String; //"https://i.ytimg.com/vi/1sVrg5FxNf8/mqdefault.jpg"
		};
		var high : {
			var url : String; //"https://i.ytimg.com/vi/1sVrg5FxNf8/hqdefault.jpg"
		};
	};
	var channelTitle : String; //Leander250",
	var liveBroadcastContent : String; //none"
}

typedef YoutubeThumbnails = {

}

