function draw_text_shadow(x, y, text)
{
	draw_set_font(fnt_main);
	var c = draw_get_color();
	draw_set_color(c_black);
	draw_text(x + 1, y + 1, text);
	draw_text(x + 2, y + 2, text);
	draw_set_color(c);
	draw_text(x, y, text);
}

function draw_grid(alpha, offset, w, h)
{
	if (alpha < 0.05)
		return;
	draw_set_alpha(alpha);
	draw_set_color(c_black);
	var camLeft = camera_get_view_x(view_camera[0]);
	var camTop = camera_get_view_y(view_camera[0]);
	var camRight = camLeft + camera_get_view_width(view_camera[0]);
	var camBottom = camTop + camera_get_view_height(view_camera[0]);
	for (var _x = floor(camLeft); _x < camRight; _x += offset)
		draw_line(_x, floor(camTop - 1), _x, ceil(camBottom));
	for (var _y = floor(camTop); _y < camBottom; _y += offset)
		draw_line(floor(camLeft), _y, ceil(camRight), _y);
	draw_set_alpha(1);
}