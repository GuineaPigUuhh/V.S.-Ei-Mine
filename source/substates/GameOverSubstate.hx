package substates;

import backend.WeekData;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import objects.Character;
import states.FreeplayState;
import flixel.effects.FlxFlicker;
import states.StoryMenuState;
import guineapiguuhh_stuff.WinUtil;

class GameOverSubstate extends MusicBeatSubstate
{
	var playingDeathSound:Bool = false;
	var stageSuffix:String = "";

	var boyfriend:FlxSprite; // temp
	var gameOverCam:FlxCamera;

	public var hardCore:Bool = false;

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	public static function resetVariables()
	{
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';

		var _song = PlayState.SONG;
		if (_song != null)
		{
			if (_song.gameOverChar != null && _song.gameOverChar.trim().length > 0)
				characterName = _song.gameOverChar;
			if (_song.gameOverSound != null && _song.gameOverSound.trim().length > 0)
				deathSoundName = _song.gameOverSound;
			if (_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0)
				loopSoundName = _song.gameOverLoop;
			if (_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0)
				endSoundName = _song.gameOverEnd;
		}
	}

	override function create()
	{
		instance = this;

		WinUtil.changeTitleToDefault();

		gameOverCam = new FlxCamera();
		gameOverCam.bgColor.alpha = 0;
		FlxG.cameras.add(gameOverCam, false);

		cameras = [gameOverCam];

		Conductor.songPosition = 0;

		hardCore = Difficulty.getString() == 'hardcore';

		var red:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
		red.screenCenter();
		red.scrollFactor.set(0, 0);
		red.alpha = 0.5;
		add(red);

		var gameOverTxt:FlxText = new FlxText(0, 100, 0, hardCore ? 'Game over!' : 'You Died!');
		gameOverTxt.setFormat(Paths.font("minecraft.ttf"), 45);
		gameOverTxt.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF383838, 3, 1);
		gameOverTxt.screenCenter(X);
		add(gameOverTxt);

		var player = (PlayState.instance.boyfriend.curCharacter.startsWith("bf") ? "Boyfriend.xml" : "Player");
		var motiveTxt:FlxText = new FlxText(0, 180, 0, player + ' ' + 'died because he was really bad at rap');
		motiveTxt.setFormat(Paths.font("minecraft.ttf"), 20);
		motiveTxt.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF383838, 2, 1);
		motiveTxt.screenCenter(X);
		add(motiveTxt);

		var scoreTxt:FlxText = new FlxText(0, 220, 0, 'Score: ' + PlayState.instance.songScore);
		scoreTxt.setFormat(Paths.font("minecraft.ttf"), 22);
		scoreTxt.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF383838, 2, 1);
		scoreTxt.screenCenter(X);
		scoreTxt.applyMarkup('Score: *${PlayState.instance.songScore}*', [
			new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.YELLOW, false, false, 0xFF3C4114), "*")
		]);
		add(scoreTxt);

		createMCButtons();
		deadEffects();

		PlayState.instance.setOnScripts('inGameOver', true);
		PlayState.instance.callOnScripts('onGameOverStart', []);

		super.create();
	}

	public var startedDeath:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			backToMenu();
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	function createMCButtons()
	{
		var distanceY = 280;
		var respawnButton:MCButton = new MCButton("Respawn", 0, distanceY, LARGE);
		respawnButton.callback = function(self) endBullshit();
		respawnButton.screenCenter(X);
		respawnButton.disabled = true;
		respawnButton.collisionCam = gameOverCam;

		var backButton:MCButton = new MCButton("Title Screen", 0, distanceY + 60, LARGE);
		backButton.callback = function(self) backToMenu();
		backButton.screenCenter(X);
		backButton.disabled = true;
		backButton.collisionCam = gameOverCam;

		VirtualMouse.easyadd([respawnButton, backButton], true);

		new FlxTimer().start(1, (timer) -> {
			if (!hardCore || (hardCore && !PlayState.isStoryMode))
			    respawnButton.disabled = false;
			backButton.disabled = false;
		});
	}

	function deadEffects() {
		var p = PlayState.instance;

		/* Player Animation */
		p.boyfriend.color = 0xFF5959; 
		FlxFlicker.flicker(p.boyfriend, 0.5, 0.1, false);

		/* Cam Shit */
		FlxTween.tween(p.camGame, {angle: p.camGame.angle + 0.5, zoom: p.camGame.zoom + 0.05}, 2);
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function backToMenu()
	{
		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		FlxG.sound.music.stop();
		PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;
		PlayState.chartingMode = false;

		Mods.loadTopMod();
		if (PlayState.isStoryMode)
			MusicBeatState.switchState(new StoryMenuState());
		else
			MusicBeatState.switchState(new FreeplayState());

		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.volume = 0;
			PlayState.instance.vocals.volume = 0;

			MusicBeatState.resetState();

			PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
		}
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
