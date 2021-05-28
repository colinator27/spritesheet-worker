/// @description color_to_array(color)
/// @param color
// Converts GML color constants to rgb float array

/// Adapted from https://www.reddit.com/r/gamemaker/comments/7lp0cv/color_constant_to_rgb_array/

function color_to_array(quotient)
{
	var hex = array_create(8, 0);
	for (var i = 0; quotient != 0; i++)
	{
		hex[i] = quotient % 16;
		quotient = floor(quotient / 16);
	}
	
	if (array_length(hex) > 8)
		throw "bad color";
	
	var ret = array_create(4, 0);
	for (var i = 0; i < 4; i++)
		ret[i] = ((hex[(i * 2) + 1] * 16) + hex[i * 2]) / 255;
	
	return ret;
}