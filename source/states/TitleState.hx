package states;

import backend.WeekData;
import backend.Highscore;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import shaders.ColorSwap;
import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;
import portable.states.InitState;
import portable.objects.MCButton;

typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Float
}

class TitleState extends InitState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	override public function create():Void
	{
		super.create();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// IGNORE THIS!!!
		titleJSON = tjson.TJSON.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if (FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
		{
			if (initialized)
				startIntro();
			else
				new FlxTimer().start(1, function(tmr:FlxTimer) startIntro());
		}
	}

	var logoBl:FlxSprite;
	var eimine:FlxSprite;
	var enterButton:MCButton;

	function createAmbient(size:Float)
	{
		var bg:FlxSprite = new FlxSprite();
		bg.antialiasing = false;
		bg.loadGraphic(Paths.image('guineapiguuhh_stuff/title/cenario'));
		bg.screenCenter();
		bg.scale.set(size, size);
		add(bg);

		eimine = new FlxSprite(0, 0);
		eimine.frames = Paths.getSparrowAtlas('guineapiguuhh_stuff/title/ei_mane');
		eimine.antialiasing = false;
		eimine.animation.addByPrefix('bump', 'idle', 24);
		eimine.animation.play("bump");
		eimine.scale.set(size, size);
		eimine.updateHitbox();
		eimine.screenCenter();
		add(eimine);
	}

	function createTitleUI()
	{
		for (i in 0...2)
		{
			var blackbar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 85, FlxColor.BLACK);
			if (i == 1)
				blackbar.y = FlxG.height - blackbar.height;
			add(blackbar);
		}

		enterButton = new MCButton("Pressione Enter para Jogar", 0, FlxG.height - 75, LARGE);
		enterButton.callback = function(self)
		{
			self.disabled = true;
			FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1, function() {}, true);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new MainMenuState());
				closedState = true;
			});
		}
		enterButton.clickSound = 'confirmMenu';
		enterButton.screenCenter(X);
		add(enterButton);

		logoBl = new FlxSprite(45, -100, Paths.image('guineapiguuhh_stuff/logo'));
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.screenCenter(Y);
		logoBl.scale.set(0.75, 0.75);
		logoBl.updateHitbox();
		add(logoBl);

		FlxTween.tween(logoBl, {angle: logoBl.angle + 5}, 0.7, {ease: FlxEase.quadInOut, type: PINGPONG});
		logoBl.angle -= 5;
	}

	function startIntro()
	{
		if (!initialized)
		{
			if (FlxG.sound.music == null)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}

		Conductor.bpm = titleJSON.bpm;
		persistentUpdate = true;

		createAmbient(1.7);
		createTitleUI();

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		Paths.clearUnusedMemory();
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt', Paths.getSharedPath());
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		var pressedEnter:Bool = controls.ACCEPT;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		#if mobile
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				pressedEnter = true;
		#end

		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
			if (gamepad.justPressed.START #if switch || gamepad.justPressed.B #end)
				pressedEnter = true;

		if (newTitle)
		{
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2)
				titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);
			}

			if (pressedEnter)
				enterButton.callback(enterButton);
		}

		if (initialized && pressedEnter && !skippedIntro)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if (credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if (textGroup != null && credGroup != null)
		{
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

	public static var closedState:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		eimine.animation.play("bump");
		if (!closedState)
		{
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					addMoreText('Ei Mané Company');
				case 4:
					addMoreText('Apresenta');
				case 5:
					deleteCoolText();
				case 6:
					createCoolText(['Nada associado', 'com a'], -40);
				case 8:
					addMoreText('Newgrounds', -40);
					ngSpr.visible = true;
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				case 10:
					createCoolText([curWacky[0]]);
				case 12:
					addMoreText(curWacky[1]);
				case 13:
					deleteCoolText();
				case 14:
					addMoreText("FNF':");
				case 15:
					addMoreText('V.S.');
				case 16:
					addMoreText('Ei Mine');
				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 2);
			skippedIntro = true;

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
	}
}
