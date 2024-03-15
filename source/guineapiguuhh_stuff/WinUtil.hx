package guineapiguuhh_stuff;

import lime.app.Application;

class WinUtil {
    public static function getUsername() {
        var envs = Sys.environment();
        #if windows
        return envs["USERNAME"];
        #end
        #if linux || mac
        return envs["USER"];
        #end
        return null;
    }

    public static function changeTitle(text:String) {
        openfl.Lib.application.window.title = text;
    }

    public static function changeTitleToDefault() {
        openfl.Lib.application.window.title = Application.current.meta["name"];
    }
}