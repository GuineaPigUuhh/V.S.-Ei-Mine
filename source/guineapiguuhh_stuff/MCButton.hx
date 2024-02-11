package guineapiguuhh_stuff;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxAxes;

@:enum abstract ButtonTypes(String)
{
	public var LARGE = "large";
	public var MEDIUM = "medium";
	public var SMALL = "small";
	public var SQUARE = "square";
	// Custom Types
	public var YOUTUBE = "youtube";
}

class MCButton extends FlxSpriteGroup
{
	var text = "";

	public var mcText:FlxText;
	public var mcButton:FlxSprite;

	public var onClick = null;
	public var disabled = false;

	public static var default_size = 2.5;

	public function new(text:String, x:Float, y:Float, type:ButtonTypes)
	{
		super();
		this.text = text;

		var graphicSizeX = 98;
		if (type == MEDIUM)
			graphicSizeX = 150;
		else if (type == LARGE)
			graphicSizeX = 200;
		else if (type == SQUARE || type == YOUTUBE)
			graphicSizeX = 20;

		mcButton = new FlxSprite(x, y);
		mcButton.loadGraphic(Paths.image("guineapiguuhh_stuff/ui/button_" + type), true, graphicSizeX, 20);
		mcButton.animation.add("idle", [0], 0, false);
		mcButton.animation.add("selected", [1], 0, false);
		mcButton.animation.add("blank", [2], 0, false);
		mcButton.scale.set(default_size, default_size);
		mcButton.animation.play("idle");
		add(mcButton);

		mcText = new FlxText(0, 0, mcButton.width, text);
		mcText.setFormat(MCHelper.font, 20, FlxColor.WHITE, FlxTextAlign.CENTER);
		mcText.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF383838, 2, 1);
		add(mcText);

		buttonUpdateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (disabled)
		{
			mcButton.animation.play("blank");
			mcText.color = FlxColor.GRAY;
			mcText.borderSize = 0;
		}
		else
		{
			mcButton.animation.play("idle");
			mcText.color = FlxColor.WHITE;
			mcText.borderSize = 2;
		}
		if (onClick != null && !disabled)
		{
			if (FlxG.mouse.overlaps(mcButton))
			{
				mcButton.animation.play("selected");
				if (FlxG.mouse.justPressed)
				{
					onClick();
					if (text == "Story mode")
						FlxG.sound.play(Paths.sound('confirmMenu'));
					else
						FlxG.sound.play(Paths.sound('click'));
				}
			}
		}
		mcText.x = mcButton.x;
		mcText.y = mcButton.y + 8;
	}

	public function buttonUpdateHitbox()
	{
		mcButton.updateHitbox();
		mcText.updateHitbox();
	}

	public function staticButton()
	{
		mcButton.scrollFactor.set(0, 0);
		mcText.scrollFactor.set(0, 0);
	}

	public function buttonScreenCenter(axes:FlxAxes = XY)
	{
		if (axes.x)
			mcButton.screenCenter(X);
		if (axes.y)
			mcButton.screenCenter(Y);
		return this;
	}

	public function setButtonSize(x, y)
	{
		mcButton.scale.set(x, y);
		mcButton.updateHitbox();
		mcText.fieldWidth = mcButton.width;
		mcText.fieldHeight = mcButton.height;
	}
}
