package backend.objects.play.game;

import flixel.effects.particles.FlxParticle;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import backend.filesystem.Paths;
using StringTools;

typedef CharacterIcon = {
	var id:String;
	var flipX:Bool;
	var flipY:Bool;
}

typedef CharacterAnimation = {
	var name:String;
	var alias:String;
	var prefix:String;
	var frameIndices:Array<Int>;
	var assetPath:String;
	var offsets:Array<Float>;
	var flipX:Bool;
	var flipY:Bool;
	var looped:Bool;
	var frameRate:Int;
}

// V-Slice Characters.
typedef CharacterData = {
	var name:String;
	var offsets:Array<Int>;
	var renderType:String;
	var assetPath:String;
	var flipX:Bool;
	var flipY:Bool;
	var singTime:Int;
	var animations:Array<CharacterAnimation>;
	var healthIcon:CharacterIcon;
	var danceEvery:Int;
}

class Character extends Bopper {
	public var type:String = "opponent"; // Used for flipx if player

	public var cameraCenter:FlxPoint = new FlxPoint();
	public var cameraOffset:FlxPoint = new FlxPoint();

	public var characterData:CharacterData;

	public function new(id:String, type:String = "opponent", folder:String = "data/characters") {
		this.type = type;
		var jsonData = Paths.parseJson("bf", folder);
		if (Paths.fileExists(Paths.json(id, folder))) {
			jsonData = Paths.parseJson(id, folder);	
		}
		if (jsonData.danceEvery == null)
			jsonData.danceEvery = 2;
		
		/* if (jsonData.offsets != null) {
			this.offset.set(jsonData.offsets[0] ?? 0, jsonData.offsets[1] ?? 0);
			} */
			
		characterData = jsonData;
		var imagePath = Paths.image(characterData.assetPath);
		super(0, 0, Paths.image(characterData.assetPath));

		this.globalOffset.x = characterData.offsets != null ? characterData.offsets[0] : 0;
		this.globalOffset.y = characterData.offsets != null ? characterData.offsets[1] : 0;

		var texture:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(imagePath, imagePath.replace(".png", ".xml"));
		if (characterData.renderType == "multisparrow") {
			for (anim in characterData.animations) {
				if (anim.assetPath != null) {
					texture.addAtlas(
						FlxAtlasFrames.fromSparrow(
							Paths.image(anim.assetPath),
							Paths.image(anim.assetPath).replace(".png", ".xml")
						)
					);
				}
			}
		}
		this.frames = texture;

		for (anim in characterData.animations) {
			var animOffsets = [-anim.offsets[0], -anim.offsets[1]] ?? [0, 0];
			if (this.flipX)
				animOffsets[0] *= -1;
			if (this.flipY)
				animOffsets[1] *= -1;
			switch (getAnimationType(anim)) {
				case "indices":
					this.addAnimIndices(anim.name, anim.prefix, anim.frameIndices, animOffsets, anim.looped ?? false, anim.frameRate ?? 24);
					if (anim.alias != null) {
						this.addAnimIndices(anim.alias, anim.prefix, anim.frameIndices, animOffsets, anim.looped ?? false, anim.frameRate ?? 24);
					}
				case "prefix":
					this.addAnim(anim.name, anim.prefix, animOffsets, anim.looped ?? false, anim.frameRate ?? 24);
					if (anim.alias != null) {
						this.addAnim(anim.alias, anim.prefix, animOffsets, anim.looped ?? false, anim.frameRate ?? 24);
					}
				default:
					log("How did this even run?", ErrorMessage);
			}
		}
		this.dance();

		this.flipX = characterData.flipX ?? false;
		this.flipY = characterData.flipY ?? false;
		if (type == "player")
			this.flipX = !this.flipX;

		cameraCenter = this.getGraphicMidpoint();
	}

	function getAnimationType(animData:CharacterAnimation) {
		if (animData.frameIndices != null && animData.frameIndices != []) {
			return "indices";
		} else {
			return "prefix";
		}
	}

	public function playSingAnim(id:String, suffix:String = "") {
		this.playAnim('$id${suffix != "" ? '-$suffix' : ''}', true);
		this.singTimer = Math.round((this.characterData.singTime ?? 8)/2);
	}

}