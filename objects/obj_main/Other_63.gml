switch (step)
{
	case stepkind.numframes:
		step = stepkind.numframespr;
		numFrames = async_load[? "value"];
		get_integer_async("Frames per row (0 if only one row)", 0);
		break;
	case stepkind.numframespr:
		step = stepkind.numhorz;
		framesPerRow = async_load[? "value"];
		get_integer_async("Horizontal spacing", 2);
		break;
	case stepkind.numhorz:
		step = stepkind.numvert;
		horzSpace = async_load[? "value"];
		get_integer_async("Vertical spacing", 2);
		break;
	case stepkind.numvert:
		step = stepkind.finaltweak;
		vertSpace = async_load[? "value"];
		
		// Generate all the boxes
		var first = selectRects[| 0];
		var xAdvance = first.w + horzSpace;
		var yAdvance = first.h + vertSpace;
		var _x = first.x;
		var _y = first.y;
		var currRowCounter = 1;
		for (var i = 1; i < numFrames; i++)
		{
			if (framesPerRow > 0 && currRowCounter++ >= framesPerRow)
			{
				currRowCounter = 1;
				_x = first.x;
				_y += yAdvance;
			} else
				_x += xAdvance;
			ds_list_add(selectRects, new global.SelectRect(_x, _y, first.w, first.h));
		}
		break;
}