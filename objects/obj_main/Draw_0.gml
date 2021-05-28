draw_sprite(image, 0, 0, 0);
draw_grid(clamp((zoom - 1) * 0.05, 0, 0.3), 1, room_width, room_height);

var s = ds_list_size(selectRects);
for (var i = 0; i < s; i++)
{
	selectRects[| i].draw(i);
}