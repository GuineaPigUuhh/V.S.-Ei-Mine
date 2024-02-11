package substates;

import backend.WeekData;

import objects.Character;
import flixel.FlxObject;
import flixel.FlxSubState;

import states.StoryMenuState;
import states.FreeplayState;

class GameOverSubstate extends MusicBeatSubstate
{
	var playingDeathSound:Bool = false;
	var stageSuffix:String = "";

	var boyfriend:FlxSprite; // temp

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';

		var _song = PlayState.SONG;
		if(_song != null)
		{
			if(_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) characterName = _song.gameOverChar;
			if(_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) deathSoundName = _song.gameOverSound;
			if(_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0) loopSoundName = _song.gameOverLoop;
			if(_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0) endSoundName = _song.gameOverEnd;
		}
	}
	override function create()
	{
		instance = this;

		Conductor.songPosition = 0;

		var red:FlxSprite = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.RED);
		red.screenCenter();
		red.scrollFactor.set(0,0);
		red.alpha = 0.5;
		add(red);

		var distanceY = 200;
		var respawnButton:MCButton = new MCButton("Respawn", 0, distanceY, LARGE);
		respawnButton.onClick = function(){endBullshit();}
		respawnButton.buttonScreenCenter(X);
		respawnButton.staticButton();
		add(respawnButton);

		var backButton:MCButton = new MCButton("Title Screen", 0, distanceY + 60, LARGE);
		backButton.onClick = function(){backToMenu();}
		backButton.buttonScreenCenter(X);
		backButton.staticButton();
		add(backButton);

		FlxG.sound.play(Paths.sound(deathSoundName));
		
		PlayState.instance.setOnScripts('inGameOver', true);
		PlayState.instance.callOnScripts('onGameOverStart', []);

		cameras = [PlayState.instance.camOther];

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
