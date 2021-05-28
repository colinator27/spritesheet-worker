function updateCamera()
{
	var rawMouseX = mouse_x;
	var rawMouseY = mouse_y;
 
	camera_set_view_pos(view_camera[0], 
						rawMouseX - ((camBaseW / zoom) * 
							(rawMouseX - camera_get_view_x(view_camera[0])) / camera_get_view_width(view_camera[0])), 
						rawMouseY - ((camBaseH / zoom) * 
							(rawMouseY - camera_get_view_y(view_camera[0])) / camera_get_view_height(view_camera[0])));
	camera_set_view_size(view_camera[0], camBaseW / zoom, camBaseH / zoom);
}

var spd = (keyboard_check(vk_control) ? 0.75 : 0.2);

if (mouse_wheel_up())
{
	zoom = min(zoom + spd, 100);
	updateCamera();
} else if (mouse_wheel_down())
{
	zoom = max(zoom - spd, 0.5);
	updateCamera();
} else if (dragging)
{    
	camera_set_view_pos(view_camera[0], camera_get_view_x(view_camera[0]) + (dragX - mouse_x),
										camera_get_view_y(view_camera[0]) + (dragY - mouse_y));
}

if (keyboard_check(ord("R")))
	game_restart();
	
if (keyboard_check_pressed(vk_f4))
	window_set_fullscreen(!window_get_fullscreen());

function bgColorPick()
{
	if (mouse_check_button(mb_left))
	{
		var surf = surface_create(1, 1);
		surface_set_target(surf);
		draw_clear_alpha(0, 0);
		draw_sprite_part(image, 0, floor(mouse_x), floor(mouse_y), 1, 1, 0, 0);
		surface_reset_target();
		var buff = buffer_create(4, buffer_fixed, 4);
		buffer_get_surface(buff, surf, 0);
		var col = buffer_peek(buff, 0, buffer_u32);
		if (col != undefined)
		{
			if (keyboard_check(vk_shift))
				bgcolor2 = col;
			else
				bgcolor = col;
		}
		buffer_delete(buff);
		surface_free(surf);
	}
}

switch (step)
{
	case stepkind.selectframeTL:
		if (mouse_check_button_pressed(mb_left))
		{
			var targetX = mouse_x;
			var targetY = mouse_y;
			selectRects[| 0] = new global.SelectRect(targetX, targetY, 16, 16);
			step = stepkind.selectframeBB;
		}
		break;
	case stepkind.selectframeBB:
		selectRects[| 0].update();
		
		if (keyboard_check_pressed(vk_enter))
			step = stepkind.selectbgcolor;
		break;
	case stepkind.selectbgcolor:
		bgColorPick();
		
		if (keyboard_check_pressed(vk_enter))
		{
			step = stepkind.numframes;
			get_integer_async("Number of frames", 1);
		}
		break;
	case stepkind.finaltweak:
		for (var i = 0; i < ds_list_size(selectRects); i++)
		{
			selectRects[| i].updateFullDrag(i);
		}
		
		if (keyboard_check(vk_tab))
			bgColorPick();
		
		if (keyboard_check_pressed(vk_enter))
		{
			if (keyboard_check(vk_shift))
			{
				// Export as sprite strip
				var fname = get_save_filename("PNG files|*.png", "");
				if (fname != "")
				{
					var first = selectRects[| 0];
					var surf = surface_create(first.w * numFrames, first.h);
					surface_set_target(surf);
				
					draw_clear_alpha(0, 0);

					shader_set(shd_exclude2);
					shader_set_uniform_f_array(shader_get_uniform(shd_exclude2, "excludeColor1"), color_to_array(bgcolor));
					shader_set_uniform_f_array(shader_get_uniform(shd_exclude2, "excludeColor2"), color_to_array(bgcolor2));
				
					for (var i = 0; i < numFrames; i++)
					{
						var frame = selectRects[| i];
						draw_sprite_part(image, 0, frame.x, frame.y, frame.w, frame.h, first.w * i, 0);
					}
				
					shader_reset();
				
					surface_reset_target();
					surface_save(surf, fname);
					surface_free(surf);
				}
			} else
			{
				// Export as many images
				var fname = get_save_filename("PNG files|*.png", "");
				if (fname != "")
				{
					var first = selectRects[| 0];
					var surf = surface_create(first.w, first.h);

					shader_set(shd_exclude2);
					shader_set_uniform_f_array(shader_get_uniform(shd_exclude2, "excludeColor1"), color_to_array(bgcolor));
					shader_set_uniform_f_array(shader_get_uniform(shd_exclude2, "excludeColor2"), color_to_array(bgcolor2));
					
					var baseFName = string_copy(fname, 0, string_last_pos(".", fname) - 1);
					for (var i = 0; i < numFrames; i++)
					{
						surface_set_target(surf);
						draw_clear_alpha(0, 0);
						
						var frame = selectRects[| i];
						draw_sprite_part(image, 0, frame.x, frame.y, frame.w, frame.h, 0, 0);
						
						surface_reset_target();
						surface_save(surf, baseFName + string(i) + ".png");
					}
				
					shader_reset();
					surface_free(surf);
				}
			}
		}
		break;
}