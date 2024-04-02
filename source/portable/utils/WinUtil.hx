package portable.utils;

import lime.app.Application;

#if (windows && cpp && DARK_MODE)
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
</target>
')
@:headerCode('#include <dwmapi.h>')
#end
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

	#if (windows && cpp && DARK_MODE)
	/**
	 * Change the Window Theme to Dark Mode
	 */
	@:functionCode('
        int darkMode = enabled ? 1 : 0;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode)))
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        UpdateWindow(window);
    ')
	public static function setDarkMode(enabled:Bool)
	{
		lime.app.Application.current.window.borderless = true;
		lime.app.Application.current.window.borderless = false;
	}
	#end
}
