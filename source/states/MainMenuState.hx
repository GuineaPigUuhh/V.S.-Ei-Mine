package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.util.FlxAxes;
import guineapiguuhh_stuff.*;
import lime.app.Application;
import options.OptionsState;
import states.editors.MasterEditorMenu;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var engineVersion = '0.2.0';

	var bg:FlxSprite; // for debug
	var freeplayButton:MCButton;
	var debug_stage = true;

	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var random_paronama = FlxG.random.int(1, 4);
		bg = new FlxSprite(508).loadGraphic(Paths.image('guineapiguuhh_stuff/backgrounds/final_' + random_paronama));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();
		bg.screenCenter(Y);
		add(bg);
		bg.scale.set(1.5, 1.5);
		FlxTween.tween(bg, {x: -1265}, 50, {type: PINGPONG});

		var logo:FlxSprite = new FlxSprite(0, 50).loadGraphic(Paths.image('guineapiguuhh_stuff/logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.scrollFactor.set(0, 0);
		logo.scale.set(0.65, 0.65);
		logo.updateHitbox();
		logo.screenCenter(X);
		add(logo);

		createMCButtons();

		var coolPhraseForTheDay:FlxText = new FlxText(logo.x + logo.width - 200, logo.y + 170, 320, CoolPhrases.randomPhrase());
		coolPhraseForTheDay.setFormat(MCHelper.font, 25, FlxColor.YELLOW, CENTER, SHADOW, 0xFF3C4114);
		coolPhraseForTheDay.angle = -22;
		coolPhraseForTheDay.borderSize = 2;
		add(coolPhraseForTheDay);
		FlxTween.tween(coolPhraseForTheDay, {"scale.x": 1.08, "scale.y": 1.08}, 0.15, {type: PINGPONG});

		var modVer:FlxText = new FlxText(3, FlxG.height - 30, FlxG.width, "Friday Night Funkin': EiMine Re-Mine " + engineVersion);
		modVer.setFormat(MCHelper.font, 19, FlxColor.WHITE, LEFT, SHADOW, 0xFF383838);
		modVer.borderSize = 2;
		add(modVer);

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		if (debug_stage)
		{
			if (FlxG.keys.justPressed.F1)
				freeplayButton.disabled = !freeplayButton.disabled;
		}

		super.update(elapsed);
	}

	function createMCButtons()
	{
		var distanceButtons = 60;
		var storyButton = new MCButton("Story mode", 0, 0, LARGE);
		storyButton.onClick = function()
		{
			MusicBeatState.switchState(new StoryMenuState());
		}
		storyButton.clickSound = 'confirmMenu';
		storyButton.buttonScreenCenter(XY);

		freeplayButton = new MCButton("Freeplay", 0, storyButton.mcButton.y + distanceButtons, LARGE);
		freeplayButton.onClick = function()
		{
			MusicBeatState.switchState(new FreeplayState());
		}
		freeplayButton.disabled = !ClientPrefs.data.freeplayUnlock;
		freeplayButton.buttonScreenCenter(X);

		var creditsButton = new MCButton("Credits", 0, freeplayButton.mcButton.y + distanceButtons, LARGE);
		creditsButton.onClick = function()
		{
			MusicBeatState.switchState(new CreditsState());
		}
		creditsButton.buttonScreenCenter(X);

		var halfButtons_size = 1.208;
		var optionsButton = new MCButton("Options...", 391.5, creditsButton.mcButton.y + 100, SMALL);
		optionsButton.onClick = function()
		{
			MusicBeatState.switchState(new OptionsState());
			OptionsState.onPlayState = false;
			if (PlayState.SONG != null)
			{
				PlayState.SONG.arrowSkin = null;
				PlayState.SONG.splashSkin = null;
				PlayState.stageUI = 'normal';
			}
		};

		var exitButton = new MCButton("Exit Game", 645.5, creditsButton.mcButton.y + 100, SMALL);
		exitButton.onClick = function()
		{
			Sys.exit(0);
		}

		var canalButton = new MCButton("", optionsButton.mcButton.x - 60, exitButton.mcButton.y, YOUTUBE);
		canalButton.onClick = function()
		{
			CoolUtil.browserLoad("https://www.youtube.com/@lorenzolo2264");
		}

		var secretButton = new MCButton("??", exitButton.mcButton.x + exitButton.mcButton.width + 10, exitButton.mcButton.y, SQUARE);
		secretButton.onClick = function() {}

		add(canalButton);
		add(secretButton);
		add(exitButton);
		add(creditsButton);
		add(optionsButton);
		add(freeplayButton);
		add(storyButton);
	}
}
