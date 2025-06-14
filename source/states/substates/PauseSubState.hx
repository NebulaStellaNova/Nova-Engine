package states.substates;

import flixel.math.FlxMath;
import backend.MusicBeatState;
import backend.filesystem.Paths;
import flixel.text.FlxText;
import backend.objects.NovaText;
import backend.objects.NovaSprite;
import backend.audio.Conductor;
import flixel.FlxG;
import flixel.FlxSubState;

class PauseSubState extends FlxSubState {
	var items:Array<FlxText> = [];
	var options:Array<String> = [
		"Resume",
		"Restart",
		"Exit"
	];

	var curSelected:Int = 0;

	override function create() {
		super.create();

		for (i=>txt in options) {
			var text = new FlxText(0, 50 * i, 0, txt);
			text.scrollFactor.set();
			text.setFormat(Paths.font("Tardling v1.1.ttf"), 40);
			text.screenCenter();
			text.y += 50 * (i-((options.length-1)/2));
			text.ID = i;
			items.push(text);
			add(text);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		changeSelection(uiCheck());
		for (item in items) {
			item.alpha = item.ID == curSelected ? 1 : 0.5;
		}
		if (FlxG.keys.justPressed.ENTER) {
			pickOption();
		}
	}

	function uiCheck() {
		if (FlxG.keys.justPressed.UP)
			return -1;
		else if (FlxG.keys.justPressed.DOWN)
			return 1;
		else
			return 0;
	}

	function pickOption() {
		switch (options[curSelected]) {
			case "Resume":
				FlxG.state.persistentUpdate = true;
				Conductor.resume();
				close();
			case "Exit":
				cast (FlxG.state, MusicBeatState).switchState(new FreeplayState());
		}
	}

	public function changeSelection(amt:Int, forceSong:Bool = false) {
		curSelected = FlxMath.wrap(curSelected + amt, 0, options.length-1);
	}
}