package guineapiguuhh_stuff;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKeyboard;

class VirtualMouse extends FlxSprite 
{
    public var enabled(default, set):Bool;
    public var mouse_speed(default, never):Float = 5;

    public var checkIfHasGamepads(never, set):Bool;

    public var input(default, never):VirtualMouseInputs = new VirtualMouseInputs();

    public function new(?checkIfHasGamepads:Bool = false)
    {
        super(0, 0, Paths.image('virtualmouse'));

        enabled = false;
        this.checkIfHasGamepads = checkIfHasGamepads;

        screenCenter();
        scale.set(3, 3);
        scrollFactor.set(0, 0);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.TAB)
            enabled = !enabled;

        if (!enabled)
            return;

        y += (input.UP ? -mouse_speed : (input.DOWN ? mouse_speed : 0));
        x += (input.LEFT ? -mouse_speed : (input.RIGHT ? mouse_speed : 0));
    }

    public function set_enabled(value:Bool) {
        enabled = value;

        // Simplify!
        visible = enabled;

        FlxG.mouse.enabled = !enabled;
        FlxG.mouse.visible = !enabled;

        return value;
    }

    public function set_checkIfHasGamepads(value:Bool):Bool {
        enabled = input.hasActive;
        return value;
    }

    public static function return_preset()
        return new VirtualMouse(true);

    /* 🛑WARNING🛑: This is only used for this mod, do not try to use this command before making changes */
    public static function easyadd(bs:Array<MCButton>, isSubstate:Bool = false) {
        var virtualMouse = VirtualMouse.return_preset();
        var instance = (isSubstate ? FlxG.state.subState : FlxG.state);
		for (i in bs)
		{
			i.virtualMouse = virtualMouse;
			instance.add(i);
		}
		instance.add(virtualMouse);
    }
}

class VirtualMouseInputs
{
    /* Accept Key */
    public var ACCEPT(get, never):Bool;

    /* Move Mouse */
    public var LEFT(get, never):Bool;
    public var DOWN(get, never):Bool;
    public var UP(get, never):Bool;
    public var RIGHT(get, never):Bool;

    /* Utils */
    public var hasMoved(get, never):Bool;
    public var hasActive(get, never):Bool;

    public function new() {}

    public function get_hasActive():Bool {
        if (FlxG.gamepads.firstActive != null)
        {
            #if !modFinalBuild
            trace('${FlxG.gamepads.firstActive.model} Gamepad Detected');
            #end
            return true;
        }
        #if !modFinalBuild
        trace('No Gamepad Detected');
        #end
        return false;
    }
    
    public function get_ACCEPT():Bool
        return FlxG.keys.justPressed.ENTER || gamepadkey_justpressed_anticrash([A]);

    public function get_hasMoved():Bool
        return LEFT || DOWN || UP || RIGHT;

    public function get_LEFT():Bool
        return FlxG.keys.pressed.LEFT || gamepadkey_pressed_anticrash([DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT]);

    public function get_DOWN():Bool
        return FlxG.keys.pressed.DOWN || gamepadkey_pressed_anticrash([DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN]);

    public function get_UP():Bool
        return FlxG.keys.pressed.UP ||gamepadkey_pressed_anticrash([DPAD_UP, LEFT_STICK_DIGITAL_UP]);

    public function get_RIGHT():Bool
        return FlxG.keys.pressed.RIGHT || gamepadkey_pressed_anticrash([DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]);

    function gamepadkey_pressed_anticrash(BS:Array<FlxGamepadInputID>)
    {
        if (FlxG.gamepads.firstActive != null)
            return FlxG.gamepads.firstActive.anyPressed(BS);
        return false;
    }

    function gamepadkey_justpressed_anticrash(BS:Array<FlxGamepadInputID>)
    {
        if (FlxG.gamepads.firstActive != null)
            return FlxG.gamepads.firstActive.anyJustPressed(BS);
        return false;
    }
}