package portable.objects;

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
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import portable.objects.MCText;

/**
 * Possible Minecraft Image Buttons
 */
enum ButtonType
{
	LARGE;
	MEDIUM;
	SMALL;
	SQUARE;
	YOUTUBE;
	GITHUB;
}

/**
 * like Minecraft Button
 */
class MCButton extends FlxSpriteGroup
{
	public var text(default, set):String;

	public var clickSound:String = "click";

	public var button:FlxSprite;
	public var label:MCText;

	public var callback:Null<(MCButton) -> Void> = null;

	public var disabled(default, set):Bool = false;
	public var disabled_visual(default, set):Bool = false;
	public var disabled_callback(default, set):Bool = false;

	public var mouseParent:VirtualMouse;

	public static final DEFAULT_SIZE:Float = 2.5;

	public function new(text:String, x:Float = 0.0, y:Float = 0.0, type:ButtonType = LARGE)
	{
		FlxG.mouse.enabled = FlxG.mouse.visible = true;

		var graphic = Paths.image("guineapiguuhh_stuff/ui/button_" + Std.string(type).toLowerCase());
		setupSprite(graphic);
		setupText(text);

		super(x, y);
		add(button);
		add(label);
	}

	private function setupSprite(graphic:FlxGraphic)
	{
		button = new FlxSprite();
		button.loadGraphic(graphic, true, graphic.width, Std.int(graphic.height / 3));
		button.animation.add("idle", [0], 0, false);
		button.animation.add("selected", [1], 0, false);
		button.animation.add("blank", [2], 0, false);
		button.scale.set(DEFAULT_SIZE, DEFAULT_SIZE);
		button.updateHitbox();
		button.antialiasing = false;
		button.scrollFactor.set(0, 0);
		button.animation.play("idle");
	}

	private function setupText(text:String)
	{
		label = new MCText(0, 0, button.width, '');
		label.scrollFactor.set(0, 0);
		label.alignment = CENTER;
		this.text = text;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (checkOverlaps() && !disabled)
		{
			button.animation.play("selected");
			if ((callback != null && !disabled_callback)
				&& (FlxG.mouse.justPressed || (mouseParent != null && mouseParent.enabled && FlxG.gamepads.lastActive.justPressed.A)))
			{
				callback(this);
				FlxG.sound.play(Paths.sound(clickSound));
			}
		}
		else if (!disabled_visual && button.animation.curAnim.name != "idle")
			button.animation.play("idle");
	}

	private function set_text(value:String):String
		return label.text = text = value;

	private function set_disabled(value:Bool):Bool
	{
		return disabled = disabled_visual = disabled_callback = value;
	}

	private function set_disabled_visual(value:Bool)
	{
		disabled_visual = value;
		button.animation.play(disabled_visual ? "blank" : "idle");
		label.color = disabled_visual ? FlxColor.GRAY : FlxColor.WHITE;
		label.borderSize = disabled_visual ? 0 : 1.5;
		return disabled_visual;
	}

	private function set_disabled_callback(value:Bool)
		return disabled_callback = value;

	override private function set_x(value:Float):Float
	{
		super.set_x(value);
		label.x = button.x;
		return x = value;
	}

	override private function set_y(value:Float):Float
	{
		super.set_y(value);
		label.y = button.y + ((button.height - label.height) / 2);
		return y = value;
	}

	private function checkOverlaps():Bool
	{
		var logic:Bool = false;
		if (FlxG.mouse.enabled)
			logic = FlxG.mouse.overlaps(button, cameras[0]);
		else if (mouseParent != null && mouseParent.enabled)
			logic = mouseParent.overlaps(button, false, cameras[0]);
		return logic;
	}
}
