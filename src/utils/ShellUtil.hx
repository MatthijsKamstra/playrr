package utils;

import js.node.ChildProcess;
import js.node.stream.Readable;

import js.node.events.EventEmitter;

/**
 * 

		// var test = new utils.ShellUtil('ls',['-lh', '/usr'], dataFunc, endFunc);
		// var test = new utils.ShellUtil('ls',['-lh', '/usr']);
		// var test = new utils.ShellUtil('cd',['/path/to/suff']);

 */


class ShellUtil extends EventEmitter<Dynamic> {



	public static var EVENT_DATA: String = 'data';
	public static var EVENT_END: String = 'end';
	public static var EVENT_ERROR: String = 'error';
	public static var EVENT_CLOSE: String = 'close';

	// private var _spawn:ChildProcess;

	/**
	 * ShellUtil();
	 * @return [description]
	 */
	public function new( cmd : String, args : Array<String>, ?cb : Dynamic, ?end : Dynamic) 
	{

		var out = '';
		for (i in 0 ... args.length) {
			out += ' ' + args[i];
		}

		trace  ( '----> cmd: ' + cmd + out );
		super();

		// //Run and pipe shell script output 
		// function run_shell(cmd, args, cb, end) {
		// 	var spawn = require('child_process').spawn,
		// 	child = spawn(cmd, args),
		// 	me = this;
		// 	child.stdout.on('data', function (buffer) { cb(me, buffer) });
		// 	child.stdout.on('end', end);
		// }



		// var spawn = require('child_process').spawn,
		// var _spawn = ChildProcess.spawn('ls', ['-lh', '/usr']);
		var _spawn = ChildProcess.spawn(cmd, args);

		_spawn.stdout.on(ReadableEvent.Data, function (data) {
			// trace('// stdout: ' + data);
			if(cb != null)cb(data);
			emit(EVENT_DATA,data);
		});

		_spawn.stdout.on(ReadableEvent.End, function () {
			// trace('END');
			// trace(Type.typeof(end));
			if(end != null) end();
			emit(EVENT_END,'end');
		});


		_spawn.stderr.on(ReadableEvent.Data, function (data) {
			trace('** stderr: ' + data);
			emit(EVENT_ERROR,data);
		});

		_spawn.on("close", function (code) {
			trace('child process exited with code ' + code);
			emit(EVENT_CLOSE,code);
		});


	}



}