package portable.objects;

import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;

class MCBar extends FlxSpriteGroup
{
	public var max:Int = 0;

	public var forceInvisible:Bool = false;
	public var heartsAlpha:Float = 1;

	public var valueFunction:() -> Float = null;

	public var backHearts:Array<FlxSprite> = [];
	public var lightHearts:Array<FlxSprite> = [];
	public var frontHearts:Array<FlxSprite> = [];

	public function new(x:Float, y:Float, max:Int, ?skin:String = "default")
	{
		super();
		this.max = max;
		for (i in 0...max)
		{
			var xPos = x + (33 * i);
			var heart_back:FlxSprite = new FlxSprite(xPos, y);
			heart_back.loadGraphic(Paths.image('guineapiguuhh_stuff/hud/hearts/${skin}_back'), true, 9, 9);
			heart_back.antialiasing = false;
			heart_back.scale.set(4, 4);
			heart_back.animation.add("normal", [0], 0, false);
			heart_back.animation.add("light", [1], 0, false);
			heart_back.animation.play('normal');
			add(heart_back);
			backHearts.push(heart_back);

			var heart_light:FlxSprite = new FlxSprite(xPos, y);
			heart_light.loadGraphic(Paths.image('guineapiguuhh_stuff/hud/hearts/${skin}_front'), true, 9, 9);
			heart_light.visible = false;
			heart_light.antialiasing = false;
			heart_light.scale.set(4, 4);
			heart_light.animation.add("normal", [2], 0, false);
			heart_light.animation.play('normal');
			add(heart_light);
			lightHearts.push(heart_light);

			var heart_front:FlxSprite = new FlxSprite(xPos, y);
			heart_front.loadGraphic(Paths.image('guineapiguuhh_stuff/hud/hearts/${skin}_front'), true, 9, 9);
			heart_front.antialiasing = false;
			heart_front.scale.set(4, 4);
			heart_front.animation.add("normal", [0], 0, false);
			heart_front.animation.add("half", [1], 0, false);
			heart_front.animation.add("normal_light", [2], 0, false);
			heart_front.animation.add("half_light", [3], 0, false);
			heart_front.animation.play('normal');
			add(heart_front);
			frontHearts.push(heart_front);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function centerX()
	{
		for (i in [backHearts, lightHearts, frontHearts])
		{
			for (e in 0...i.length)
			{
				var h = i[e];
				h.screenCenter(X);
				h.x = (h.x / 1.325) + (33 * e);
			}
		}
	}

	public function setXY(?axes:FlxAxes = XY, ?x:Float = 0, ?y:Float = 0)
	{
		if (axes.x)
			for (i in [backHearts, lightHearts, frontHearts])
				for (e in 0...i.length)
				{
					var h = i[e];
					h.x = h.x + (33 * e);
				}
		if (axes.y)
			for (i in [backHearts, lightHearts, frontHearts])
				for (e in 0...i.length)
				{
					var h = i[e];
					h.y = y;
				}
	}

	public function addXY(?axes:FlxAxes = XY, ?x:Float = 0, ?y:Float = 0)
	{
		if (axes.x)
			for (i in [backHearts, lightHearts, frontHearts])
				for (e in 0...i.length)
				{
					var h = i[e];
					h.x += x;
				}
		if (axes.y)
			for (i in [backHearts, lightHearts, frontHearts])
				for (e in 0...i.length)
				{
					var h = i[e];
					h.y += y;
				}
	}

	public function checkVars()
	{
		for (i in [backHearts, lightHearts, frontHearts])
		{
			for (e in 0...i.length)
			{
				var h = i[e];
				h.visible = !forceInvisible;
				h.alpha = heartsAlpha;
			}
		}
	}

	public function heartsLight() {}

	public function updateHeartsGui()
	{
		for (i in 0...frontHearts.length)
		{
			var thisHeart = frontHearts[i];

			var daHealth = Math.floor((valueFunction() / 2) * 10000 / 100);
			var heartID = (i + 1) * 10;

			if (heartID <= daHealth)
			{
				if (!forceInvisible)
					thisHeart.visible = true;
				thisHeart.animation.play('normal', true);
			}
			else if (heartID - 5 <= daHealth)
			{
				if (!forceInvisible)
					thisHeart.visible = true;
				thisHeart.animation.play('half', true);
			}
			else
			{
				thisHeart.visible = false;
			}
		}
	}
}
