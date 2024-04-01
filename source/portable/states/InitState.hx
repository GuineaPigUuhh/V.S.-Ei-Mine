package portable.states;

import backend.Highscore;
import flixel.system.scaleModes.FillScaleMode;
import flixel.system.scaleModes.FixedScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.system.scaleModes.RelativeScaleMode;
import portable.utils.WinUtil;

class InitState extends MusicBeatState
{
	override public function create():Void
	{
		Paths.clearStoredMemory();

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

		// FlxG.scaleMode = new PixelPerfectScaleMode();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data != null && FlxG.save.data.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;

		if (persistentUpdate == false)
			persistentUpdate = true;
		if (persistentDraw == false)
			persistentDraw = true;

		if (FlxG.save.data.weekCompleted != null)
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		#if (windows && cpp)
		WinUtil.setDarkMode(true);
		#end

		super.create();
	}
}
