package portable;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKeyboard;
import portable.objects.MCButton;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class VirtualMouse extends FlxSprite
{
	public var enabled(default, set):Bool;

	public function new()
	{
		super(0, 0);

		enabled = false;

		loadGraphic(Paths.image("guineapiguuhh_stuff/ui/virtualmouse"));
		scale.set(1.5, 1.5);
		updateHitbox();
		scrollFactor.set(0, 0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad != null && !enabled && gamepad.anyInput() && !gamepad.pressed.GUIDE)
			enabled = true;

		if (!enabled)
			return;

		if (FlxG.mouse.justMoved)
			enabled = false;

		x = Math.max(0, Math.min(FlxG.width - width, x + gamepad.getXAxis(LEFT_ANALOG_STICK) * 800 * elapsed));
		y = Math.max(0, Math.min(FlxG.height - height, y + gamepad.getYAxis(LEFT_ANALOG_STICK) * 800 * elapsed));
	}

	public function set_enabled(value:Bool)
	{
		enabled = value;
		if (enabled)
			setPosition(FlxG.mouse.x, FlxG.mouse.y);

		// Simplify!
		visible = enabled;
		FlxG.mouse.enabled = !enabled;
		FlxG.mouse.visible = !enabled;

		return value;
	}

	/* 🛑WARNING🛑: This is only used for this mod, do not try to use this command before making changes */
	public static function add(bs:Array<MCButton>, isSubstate:Bool = false)
	{
		var vm = new VirtualMouse();
		var add = (isSubstate ? FlxG.state.subState : FlxG.state).add;
		for (i in bs)
		{
			i.mouseParent = vm;
			add(i);
		}
		add(vm);
	}
}
