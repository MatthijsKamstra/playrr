package js.npm;

/**

https://www.npmjs.com/package/youtube-node

var YouTube = require('youtube-node');

var youTube = new YouTube();

youTube.setKey('xxxx');

youTube.search('World War z Trailer', 2, function(error, result) {
  if (error) {
    console.log(error);
  }
  else {
    console.log(JSON.stringify(result, null, 2));
  }
});

 */




extern class YoutubeNode
implements npm.Package.Require<"youtube-node","^1.3.0">
{
	public function new ();
	public function setKey(key:String):Void;

	public function search (query : String, maxResults:Int, callback:Dynamic):Void;

	public function getById (id : String, callback:Dynamic):Void;

	public function related(id:String , maxResults : Int, callback : Dynamic):Void;

	public function addParam (key : String, value: String):Void;
}		