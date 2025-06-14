package utils;

import flixel.util.FlxStringUtil;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import backend.objects.NovaSprite;

class NovaUtil {
	public static function desaturateSprite(sprite:NovaSprite, brightness:Float) {
		sprite.colorTransform.redOffset = 255;
		sprite.colorTransform.greenOffset = 255;
		sprite.colorTransform.blueOffset = 255;
		sprite.alpha = brightness;
	}
	
	public static function objectToMap(object) {
		var map = new Map<String, Dynamic>();
		map.remove("init");
		for (field in Reflect.fields(object)) {
			map.set(field, Reflect.field(object, field));
		}
		return map;
	}

	inline public static function capitalizeFirstLetter(string:String) {
		var split = string.split("");
		split[0] = split[0].toUpperCase();
		return split.join("");
	}

	public static function isInt(object:Dynamic) {
		return FlxStringUtil.getClassName(object, true) == "Int";
	}

	public static function isString(object:Dynamic) {
		return FlxStringUtil.getClassName(object, true) == "String";
	}
	
	public static function isFloat(object:Dynamic) {
		return FlxStringUtil.getClassName(object, true) == "Float";
	}


}