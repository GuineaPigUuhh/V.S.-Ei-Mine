package portable.objects;

class MCText extends FlxText
{
	private var specialColor = FlxColor.YELLOW;
	private var specialBorderColor = 0xFF3C4114;

	override public function new(x = 0.0, y = 0.0, daWidth = 0.0, text = "", size = 20, hasBorder = true)
	{
		super(x, y, daWidth, text, size);

		// FlxTextAlign.CENTER
		font = Paths.font("minecraft.ttf");
		color = FlxColor.WHITE;
		if (hasBorder)
		{
			// To remember
			// Style, Color, Size, Quality
			setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF383838, 1.5, 1);
			shadowOffset.set(1.75, 1.75);
		}
		antialiasing = false;
	}

	public function specialText()
	{
		color = specialColor;
		borderColor = specialBorderColor;
	}

	public function addSpecialPart(index:String = "*")
	{
		applyMarkup(text, [
			new FlxTextFormatMarkerPair(new FlxTextFormat(specialColor, false, false, specialBorderColor), index)
		]);
	}
}
