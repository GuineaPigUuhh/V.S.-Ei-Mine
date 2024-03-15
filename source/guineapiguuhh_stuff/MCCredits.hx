package guineapiguuhh_stuff;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxObject;
import openfl.Assets;
import states.MainMenuState;
import guineapiguuhh_stuff.WinUtil;

using StringTools;

// More Simple
typedef Marker = FlxTextFormatMarkerPair;
typedef TxtFormat = FlxTextFormat;

class MCCredits extends MusicBeatState
{
    var camObject:FlxObject;

    override function create()
    {
        super.create();

        camObject = new FlxObject(0, 20, 0, 0);
        camObject.screenCenter(X);

        var grass = new FlxBackdrop(Paths.image("guineapiguuhh_stuff/ilovegrass"));
        grass.scrollFactor.set(0.8, 0.8);
        add(grass);

        var logo:FlxSprite = new FlxSprite(0, 10).loadGraphic(Paths.image('guineapiguuhh_stuff/logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.scrollFactor.set(0.4, 0.4);
		logo.scale.set(0.65, 0.65);
		logo.updateHitbox();
		logo.screenCenter(X);
		add(logo);

        var credits = new FlxText(0, logo.y + 265, 0, Assets.getText(Paths.txt('credits')));
        credits.text = credits.text.replace("[username]", WinUtil.getUsername());
        credits.setFormat(Paths.font("minecraft.ttf"), 20, FlxColor.WHITE, CENTER, SHADOW, 0xFF383838);
        credits.borderSize = 2;
        credits.screenCenter(X);
        credits.scrollFactor.set(0.4, 0.4);
        credits.applyMarkup(credits.text, [
            new Marker(new TxtFormat(FlxColor.YELLOW, false, false, 0xFF3C4114), "*"),
        ]);
        add(credits);

        var backButton = new MCButton("<", 10, FlxG.height - 60, SQUARE);
		backButton.callback = function(self) 
        {
            MusicBeatState.switchState(new MainMenuState());
        }
        backButton.scrollFactor.set();
        add(backButton);

        FlxG.camera.follow(camObject, LOCKON, 60);
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(controls.BACK)
            MusicBeatState.switchState(new MainMenuState());

        final slide_keys = FlxG.keys.anyPressed([SPACE, ENTER]);
        camObject.y += 0.8 * (slide_keys ? 1 : 2);
    }    
}