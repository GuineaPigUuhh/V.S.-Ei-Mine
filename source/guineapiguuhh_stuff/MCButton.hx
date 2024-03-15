package guineapiguuhh_stuff;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.display.FlxExtendedMouseSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
import openfl.Lib;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

@:enum abstract ButtonTypes(String)
{
	public var LARGE = "large";
	public var MEDIUM = "medium";
	public var SMALL = "small";
	public var SQUARE = "square";
	public var YOUTUBE = "youtube";
	public var GITHUB = "github";
}

class MCButton extends FlxSpriteGroup
{
	public var text(default, set):String;
	public var clickSound:String = "click";
	public var collisionCam:FlxCamera = FlxG.camera;

	public var mcText:FlxText;
	public var mcButton:FlxSprite;

	public var callback:Null<(MCButton) -> Void> = null;
	public var disabled(default, set) = false;

	public var virtualMouse:VirtualMouse;

	public static final default_size = 2.5;

	public function new(text:String, x:Float = 0.0, y:Float = 0.0, type:ButtonTypes = LARGE)
	{
		if (!FlxG.mouse.enabled) FlxG.mouse.enabled = true;
		if (!FlxG.mouse.visible) FlxG.mouse.visible = true;

		var graphic = Paths.image("guineapiguuhh_stuff/ui/button_" + type);

		mcButton = new FlxSprite();
		mcButton.loadGraphic(graphic, true, graphic.width, 20);
		mcButton.animation.add("idle", [0], 0, false);
		mcButton.animation.add("selected", [1], 0, false);
		mcButton.animation.add("blank", [2], 0, false);
		mcButton.scale.set(default_size, default_size);
		mcButton.updateHitbox();
		mcButton.scrollFactor.set(0, 0);
		mcButton.animation.play("idle");

		mcText = new FlxText(0, 0, mcButton.width, '');
		mcText.setFormat(Paths.font("minecraft.ttf"), 20, FlxColor.WHITE, FlxTextAlign.CENTER);
		mcText.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF383838, 2, 1);
		mcText.updateHitbox();
		mcText.scrollFactor.set(0, 0);

		this.text = text;
		callback = null;

		super(x, y);
		add(mcButton);
		add(mcText);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (localCollision() && !disabled)
		{
			mcButton.animation.play("selected");

			var vmAccept = virtualMouse != null && virtualMouse.enabled && virtualMouse.input.ACCEPT;
			if (callback != null && (FlxG.mouse.justPressed || vmAccept))
			{
				callback(this);
			    FlxG.sound.play(Paths.sound(clickSound));
			}
		}
		else if (!disabled)
			mcButton.animation.play("idle");
	}

	override public function destroy()
	{
		super.destroy();
	}
	
	function set_text(value:String):String return mcText.text = text = value; 

	function set_disabled(value:Bool):Bool
	{
		disabled = value;
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
		return disabled;
	}

	override function set_x(value:Float):Float
	{
		super.set_x(value);
		mcText.x = mcButton.x; 
		return x = value;
	}

	override function set_y(value:Float):Float
	{
		super.set_y(value);
		mcText.y = mcButton.y + ((mcButton.height - mcText.height) / 2); 
		return y = value;
	}

	function localCollision():Bool
	{
		var mouseX:Float = 0;
		var mouseY:Float = 0;
		if (FlxG.mouse.enabled)
		{
			mouseX = FlxG.mouse.getScreenPosition(collisionCam).x;
		    mouseY = FlxG.mouse.getScreenPosition(collisionCam).y;
		}
		else if (virtualMouse != null)
		{
			mouseX = virtualMouse.x;
		    mouseY = virtualMouse.y;
		}
		else
			return false;

		var collisionX = mouseX > mcButton.x && mouseX < mcButton.x + mcButton.width;
		var collisionY = mouseY > mcButton.y && mouseY < mcButton.y + mcButton.height;

		if (collisionX && collisionY)
			return true;
		return false;
	}
}