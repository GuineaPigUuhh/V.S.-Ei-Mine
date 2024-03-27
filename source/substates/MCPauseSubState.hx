package substates;

import backend.Highscore;
import backend.Song;
import backend.WeekData;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxStringUtil;
import options.OptionsState;
import states.FreeplayState;
import states.StoryMenuState;
import portable.utils.WinUtil;
import portable.objects.MCButton;
import portable.VirtualMouse;

class MCPauseSubState extends MusicBeatSubstate
{
	var pauseMusic:FlxSound;
	var practiceText:FlxText;

	var pauseCam:FlxCamera;

	public static var songName:String = null;

	override function create()
	{
		pauseCam = new FlxCamera();
		pauseCam.bgColor.alpha = 0;
		FlxG.cameras.add(pauseCam, false);

		cameras = [pauseCam];

		pauseMusic = new FlxSound();
		pauseMusic.loadEmbedded(Paths.music('Musica_do_ei_mine_kekek'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, PlayState.SONG.song, 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("minecraft.ttf"), 25);
		levelInfo.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF383838, 2, 1);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, Difficulty.getString().toUpperCase(), 32);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('minecraft.ttf'), 25);
		levelDifficulty.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF383838, 2, 1);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var logo:FlxSprite = new FlxSprite(0, 30).loadGraphic(Paths.image('guineapiguuhh_stuff/logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.scrollFactor.set(0, 0);
		logo.scale.set(0.65, 0.65);
		logo.updateHitbox();
		logo.screenCenter(X);
		add(logo);

		createMCButtons((logo.y + logo.height) + 50);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		logo.y = -200;
		FlxTween.tween(logo, {y: 30}, 0.4, {ease: FlxEase.expoOut});
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		super.create();
	}

	function createMCButtons(distanceY)
	{
		var distanceButtons = 60;
		var resumeButton = new MCButton("Back to Game", 0, distanceY, LARGE);
		resumeButton.callback = function(self) close();
		resumeButton.screenCenter(X);
		resumeButton.cameras = [pauseCam];

		var restartButton = new MCButton("Restart Song", 391.5, distanceButtons + resumeButton.y, SMALL);
		restartButton.callback = function(self) restartSong();
		restartButton.cameras = [pauseCam];

		var optionsButton = new MCButton("Options...", 645.5, distanceButtons + resumeButton.y, SMALL);
		optionsButton.callback = function(self)
		{
			PlayState.instance.paused = true; // For lua
			PlayState.instance.vocals.volume = 0;
			WinUtil.changeTitleToDefault();
			MusicBeatState.switchState(new OptionsState());
			if (ClientPrefs.data.pauseMusic != 'None')
			{
				FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
				FlxG.sound.music.time = pauseMusic.time;
			}
			OptionsState.onPlayState = true;
		}
		optionsButton.cameras = [pauseCam];

		var exitButton = new MCButton("Quit to Title", 0, (distanceButtons * 2) + optionsButton.y, LARGE);
		exitButton.callback = function(self)
		{
			#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
			WinUtil.changeTitleToDefault();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			Mods.loadTopMod();
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			FlxG.camera.followLerp = 0;
		}
		exitButton.cameras = [pauseCam];
		exitButton.screenCenter(X);

		VirtualMouse.add([resumeButton, restartButton, optionsButton, exitButton], true);
	}

	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if (formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none'))
			return null;

		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;

	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (controls.BACK)
		{
			close();
			return;
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if (noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}
}
