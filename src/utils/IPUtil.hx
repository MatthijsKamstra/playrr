package utils;


import js.node.Dns;
import js.node.Os;


class IPUtil
{


	/**
	 * [IP description]
	 *
	 * IPUtil.IP()
	 *
	 * 		utils.IPUtil.IP(); 
	 */
	public static function IP():Void
	{
		var _os : Os;
	    var _dns : Dns;

	    trace(Os.hostname());

	  //   Dns.lookup(Os.hostname(), function (str:Dynamic, int:Dynamic){
			// // trace("--------------" + add);
			// trace("--------------" );
			
	  //   });
	}

	public static function getIP ():String
	{

		// trace (js.node.Os.networkInterfaces());

		var json = Os.networkInterfaces();
		return json.en1[1].address;
	}




	public function new():Void
	{
	    
	}

}


