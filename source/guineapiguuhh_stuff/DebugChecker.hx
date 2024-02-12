package guineapiguuhh_stuff;

class DebugChecker
{
	static var debug_list:Array<String> = ["mod", "states"];

	public static function get(name):Bool
	{
		if (debug_list.contains(name))
		{
			if (FileSystem.exists(name + ".debug"))
				return true;
			else
				return false;
		}
		trace("ERROR: .debug File don't in List");
		return false;
	}
}
