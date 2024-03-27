package portable.utils;

import lime.app.Application;

class WinUtil
{
	// This was for the credits but I replaced it with the thank you image for playing
	// lol, no more getUsername function
	/*
		public static function getUsername()
		{
			var envs = Sys.environment();
			
			#if windows
			return envs["USERNAME"];
			#end

			#if linux || mac 
			return envs["USER"]; 
			#end 
			
			return null;
		}
	 */
	public static function changeTitle(text:String)
		openfl.Lib.application.window.title = text;

	public static function changeTitleToDefault()
		openfl.Lib.application.window.title = getDefaultTitle();

	public static function getDefaultTitle()
		return Application.current.meta["name"];

	public static function getVersion()
		return Application.current.meta["version"];
}