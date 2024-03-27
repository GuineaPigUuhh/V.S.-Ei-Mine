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
import portable.utils.WinUtil;
import portable.objects.MCButton;
import portable.VirtualMouse;
import portable.objects.MCText;

class GameOverSubstate extends MusicBeatSubstate
{
	var playingDeathSound:Bool = false;
	var stageSuffix:String = "";

	var boyfriend:Character = PlayState.instance.boyfriend; // ShortShit?
	var gameOverCam:FlxCamera;

	public var hardcore:Bool = false;

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

		hardcore = Difficulty.getString() == 'hardcore';

		var red:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
		red.screenCenter();
		red.scrollFactor.set(0, 0);
		red.alpha = 0.5;
		add(red);

		var gameOverTxt:MCText = new MCText(0, 100, FlxG.width, hardcore ? 'Game over!' : 'You Died!', 45);
		gameOverTxt.screenCenter(X);
		gameOverTxt.alignment = CENTER;
		add(gameOverTxt);

		var player = (boyfriend.curCharacter.startsWith("bf") ? "Boyfriend.xml" : "Player");
		var motiveTxt:MCText = new MCText(0, 180, FlxG.width, player + ' ' + 'died because he was really bad at rap');
		motiveTxt.alignment = CENTER;
		add(motiveTxt);

		var scoreTxt:MCText = new MCText(0, 220, FlxG.width, 'Score: *${PlayState.instance.songScore}*', 22);
		scoreTxt.addSpecialPart();
		scoreTxt.alignment = CENTER;
		add(scoreTxt);

		var respawnButton:MCButton = new MCButton("Respawn", 0, 280, LARGE);
		respawnButton.screenCenter(X);
		respawnButton.disabled = true;
		respawnButton.cameras = [gameOverCam];

		var backButton:MCButton = new MCButton("Title Screen", 0, respawnButton.y + 60, LARGE);
		backButton.callback = function(self) backToMenu();
		backButton.screenCenter(X);
		backButton.disabled = true;
		backButton.cameras = [gameOverCam];

		backButton.callback = function(self)
		{
			backButton.disabled = true;
			respawnButton.disabled = true;
			backToMenu();
		};
		respawnButton.callback = function(self)
		{
			backButton.disabled = true;
			respawnButton.disabled = true;

			endBullshit();
		};

		VirtualMouse.add([respawnButton, backButton], true);

		new FlxTimer().start(1, (timer) ->
		{
			if (!hardcore || (hardcore && !PlayState.isStoryMode))
				respawnButton.disabled = false;
			backButton.disabled = false;
		});
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

	private function deadEffects()
	{
		/* Player */
		boyfriend.color = 0xFF5959;
		FlxFlicker.flicker(boyfriend, 0.5, 0.1, false);

		/* Camera */
		FlxTween.tween(PlayState.instance.camGame, {angle: PlayState.instance.camGame.angle + 0.5, zoom: PlayState.instance.camGame.zoom + 0.05}, 2);
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
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		MusicBeatState.resetState();

		PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
