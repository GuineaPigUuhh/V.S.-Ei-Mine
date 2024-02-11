package guineapiguuhh_stuff;

import openfl.Assets;

class CoolPhrases
{
    public static function randomPhrase():String
    {		
        var coolPhrases:String = Assets.getText(Paths.txt('phrases'));
        var separedPhrases:Array<String> = coolPhrases.split('\n');

        return FlxG.random.getObject(separedPhrases);
    }    
}