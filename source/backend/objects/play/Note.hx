package backend.objects.play;

import backend.objects.play.NoteSkin.BaseAnimation;
import utils.NovaUtil;
import flixel.util.FlxSort;
import backend.filesystem.Paths;
using StringTools;

class Note extends NovaSprite {
	public static var directionStrings:Array<String> = ["left", "down", "up", "right"];
	public static var colorStrings:Array<String> = ["purple", "blue", "green", "red"];
	public static var swagWidth:Float = 160 * 0.7;

	public var canHit:Bool = true;
	public var canMiss:Bool = true;
	public var badHit:Bool = false;

	public var direction:Int = 0;
	public var typeID:Int = 0;
	public var type:String = "default";
	public var skin(default, set):String;
	function set_skin(value:String):String {
		if (skin != value)
			reloadSkin(value);
		return skin = value;
	}

	public var time:Float = 0;
	// public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var sustainLength:Float = 0;
	public var tail:Array<SustainNote> = [];
	public var strumlineID:Int = 0;
	public var scrollSpeed:Float = 3;
	public var parentStrum:Strum;
	public var skinData:NoteSkin;

	override public function new(parent:Strum, id:Int, time:Float, skin:String = 'default') {
		super();

		this.direction = id;
		this.skin = skin;
		this.parentStrum = parent;
		this.time = time;
	}

	public function reloadSkin(?skin:String) {
		var target = skin ?? this.skin;
		if (!Paths.fileExists(Paths.json('images/game/notes/$skin/meta')))
			target = 'default';

		skinData = Paths.parseJson('images/game/notes/$target/meta');
		this.loadSprite(Paths.image('${skinData.animations.note.base.global.assetPath.replace("./", 'game/notes/$target/')}'));

		animation.destroyAnimations();
		var globalOffset:Array<Float> = skinData.animations.note.base.global.offsets ??= [0, 0];
		var noteAnim:BaseAnimation = switch (this.direction) {
			case 0:
				skinData.animations.note.base.left;
			case 1:
				skinData.animations.note.base.down;
			case 2:
				skinData.animations.note.base.up;
			case 3:
				skinData.animations.note.base.right;
			case _:
				skinData.animations.note.base.left;
		}
		//for (i=>direction in [for (dir in directionStrings) noteAnim.prefix])
		this.addAnim(directionStrings[this.direction], noteAnim.prefix, [noteAnim.offsets[0]+globalOffset[0], noteAnim.offsets[1]+globalOffset[1]]);
		this.playAnim(directionStrings[this.direction]);
		this.scale.set(0.7, 0.7);
		this.updateHitbox();

		for (sustain in tail)
			sustain.reloadSkin();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		tail.sort((a:SustainNote, b:SustainNote) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
	}
}