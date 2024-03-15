package psychlua;

import backend.ClientPrefs;
import flixel.util.FlxSave;
import openfl.utils.Assets;
#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

class MCFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		var game:PlayState = PlayState.instance;

		Lua_helper.add_callback(lua, 'unlockFreeplay', function(value:Bool)
		{
			ClientPrefs.data.freeplayUnlock = value;
			ClientPrefs.saveSettings();
		});
		Lua_helper.add_callback(lua, 'addMCHealth', function(value:Int) game.mcHealth += value);
		Lua_helper.add_callback(lua, 'setMCHealth', function(value:Int) game.mcHealth = value);
		Lua_helper.add_callback(lua, 'getMCHealth', function(value:Int) return game.mcHealth);

		Lua_helper.add_callback(lua, 'addXMCBar', function(value:Float) game.mcBar.addXY(X, value));
	}
}
