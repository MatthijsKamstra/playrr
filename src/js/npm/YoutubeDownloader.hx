package js.npm;


extern class YoutubeDownloader
implements npm.Package.Require<"ytdl-core", "^0.6.0">
{

	public function new():Void;

	// public static inline function construct() : YoutubeDownloader {
	// 	untyped return require('ytdl-core');
	// }

	/**
	 * @param {String} link
	 * @param {Object} options
	 * @return {ReadableStream}
	 */
	
	/*
	
	public function ytdl(link:String, ?options:Dynamic):Dynamic;
	// public function init(link:String, ?options:Dynamic):Dynamic;

	public function downloadFromInfoCallback(info:Dynamic, options:Dynamic, callback:Dynamic):Dynamic;

	public function downloadFromInfo(info:Dynamic, options:Dynamic):Dynamic;
	
	*/
}		