package portable.states;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxObject;
import openfl.Assets;
import states.MainMenuState;
import portable.objects.MCButton;
import portable.objects.MCText;

using StringTools;

class CreditsState extends MusicBeatState
{
	var camObject:FlxObject;
	var credits:MCText;
	var thanks:FlxSprite;
	var backButton:MCButton;

	override function create()
	{
		super.create();

		camObject = new FlxObject(0, 20, 0, 0);
		camObject.screenCenter(X);

		var grass = new FlxBackdrop(Paths.image("guineapiguuhh_stuff/ilovegrass"));
		grass.antialiasing = false;
		grass.scrollFactor.set(0.55, 0.55);
		add(grass);

		final creditsScroll = 0.4;
		var logo:FlxSprite = new FlxSprite(0, 10).loadGraphic(Paths.image('guineapiguuhh_stuff/logo'));
		logo.antialiasing = false;
		logo.scrollFactor.set(creditsScroll, creditsScroll);
		logo.scale.set(0.65, 0.65);
		logo.updateHitbox();
		logo.screenCenter(X);
		add(logo);

		credits = new MCText(0, logo.y + 265, FlxG.width, Assets.getText(Paths.txt('credits')));
		credits.scrollFactor.set(creditsScroll, creditsScroll);
		credits.addSpecialPart();
		credits.alignment = CENTER;
		add(credits);

		thanks = new FlxSprite(0, (credits.y + credits.height) + 800).loadGraphic(Paths.image('guineapiguuhh_stuff/thanksForPlaying'));
		thanks.antialiasing = false;
		thanks.scrollFactor.set(creditsScroll, creditsScroll);
		thanks.scale.set(0.8, 0.8);
		thanks.updateHitbox();
		thanks.screenCenter(X);
		add(thanks);

		backButton = new MCButton("<", 10, FlxG.height - 60, SQUARE);
		backButton.callback = function(self)
		{
			self.disabled = true;
			MusicBeatState.switchState(new MainMenuState());
		};
		backButton.scrollFactor.set();
		add(backButton);

		FlxG.camera.follow(camObject, LOCKON, 60);
	}

	var passed:Bool = false;
	final final_pos:Float = 6503.19999999938;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
			backButton.callback(backButton);

		final slide_keys = FlxG.keys.anyPressed([SPACE, ENTER]) || FlxG.gamepads.lastActive.pressed.A;
		if (!passed)
			camObject.y += 0.8 * (slide_keys ? 4 : 1.6);

		#if !modFinalBuild
		if (FlxG.keys.justPressed.E)
			trace("Cam Y: " + camObject.y);
		#end

		if (!passed && (camObject.y >= final_pos))
		{
			camObject.y = final_pos;
			new FlxTimer().start(5, (timer) -> MusicBeatState.switchState(new MainMenuState()));
			passed = true;
		}
	}
}
