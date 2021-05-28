zoom = 1;
dragging = false;
dragX = 0;
dragY = 0;

step = stepkind.selectframeTL;
selectRects = ds_list_create();
bgcolor = 0;
bgcolor2 = 0;

global.mouseDragging = false;

var loading = true;
var attempts = 0;
while (loading)
{
	if (attempts++ >= 4)
	{
		game_end();
		break;
	}
	
	var fname = get_open_filename("PNG files|*.png", "");
	if (fname != "")
	{
		image = sprite_add(fname, 1, false, false, 0, 0);
		if (sprite_exists(image))
		{
			loading = false;
			var basew = sprite_get_width(image);
			var baseh = sprite_get_height(image);
			room_set_width(room, basew);
			room_set_height(room, baseh);
			if (1024 < basew)
			{
				var factor = basew / 1024;
				camBaseW = 1024 * factor;
				camBaseH = 768 * factor;
				camera_set_view_size(view_camera[0], camBaseW, camBaseH);
			} else
			{
				camBaseW = 1024;
				camBaseH = 768;
			}
		}
	}
}

enum stepkind
{
	selectframeTL, // top left
	selectframeBB, // adjust bounding box
	selectbgcolor,
	numframes, // # of frames
	numframespr, // # frames per row
	numhorz, // horz
	numvert, // vert space
	finaltweak,
}

global.Vector2 = function(_x, _y) constructor
{
	x = _x;
	y = _y;
};

global.SelectRectCorner = function(_parent, _posFunction, _dragFunction) constructor
{
	parent = _parent;
	posFunction = _posFunction;
	dragFunction = _dragFunction;
	lastDidDrag = false;
	pos = noone;
	
	static update = function()
	{
		var mX = mouse_x, mY = mouse_y;
		pos = posFunction(self);
		if (mX >= pos.x && mX <= pos.x + 2 && mY >= pos.y && mY <= pos.y + 2)
		{
			lastDidDrag = mouse_check_button(mb_left) && (!global.mouseDragging || lastDidDrag);
			if (lastDidDrag)
			{
				global.mouseDragging = true;
				dragFunction(self);
				pos = posFunction(self);
			} else
				global.mouseDragging = false;
		} else if (lastDidDrag)
		{
			lastDidDrag = !mouse_check_button_released(mb_left);
			if (lastDidDrag)
			{
				global.mouseDragging = true;
				dragFunction(self);
				pos = posFunction(self);
			} else
				global.mouseDragging = false;
		}
	};
	
	static draw = function()
	{
		draw_set_color(lastDidDrag ? c_red : c_yellow);
		draw_rectangle(pos.x, pos.y, pos.x + 2, pos.y + 2, false);
	};
	
	update();
};

global.SelectRect = function(_x, _y, _w, _h) constructor
{
	x = _x;
	y = _y;
	w = _w;
	h = _h;
	
	highlight = false;
	drawCorners = true;
	lastDidDrag = false;
	lastMouseX = undefined;
	lastMouseY = 0;
	
	topLeftCorner = new global.SelectRectCorner(self, 
							function(_self)
							{ 
								return new global.Vector2(_self.parent.x - 1, _self.parent.y - 1); 
							},
							function(_self)
							{
								var targetX = mouse_x, targetY = mouse_y;
								_self.parent.w += (_self.parent.x - targetX);
								_self.parent.h += (_self.parent.y - targetY);
								_self.parent.x = targetX;
								_self.parent.y = targetY;
								if (_self.parent.w <= 3)
									_self.parent.w = 3;
								if (_self.parent.h <= 3)
									_self.parent.h = 3;
							});
	topRightCorner = new global.SelectRectCorner(self, 
							function(_self)
							{ 
								return new global.Vector2(_self.parent.x + _self.parent.w - 2, _self.parent.y - 1); 
							},
							function(_self)
							{
								var targetX = mouse_x, targetY = mouse_y;
								_self.parent.w += (targetX - (_self.parent.x + _self.parent.w));
								_self.parent.h += (_self.parent.y - targetY);
								_self.parent.y = targetY;
								if (_self.parent.w <= 3)
									_self.parent.w = 3;
								if (_self.parent.h <= 3)
									_self.parent.h = 3;
							});
	bottomRightCorner = new global.SelectRectCorner(self, 
							function(_self)
							{ 
								return new global.Vector2(_self.parent.x + _self.parent.w - 2, _self.parent.y + _self.parent.h - 1); 
							},
							function(_self)
							{
								var targetX = mouse_x, targetY = mouse_y;
								_self.parent.w += (targetX - (_self.parent.x + _self.parent.w));
								_self.parent.h += (targetY - (_self.parent.y + _self.parent.h));
								if (_self.parent.w <= 3)
									_self.parent.w = 3;
								if (_self.parent.h <= 3)
									_self.parent.h = 3;
							});
	bottomLeftCorner = new global.SelectRectCorner(self, 
							function(_self)
							{ 
								return new global.Vector2(_self.parent.x - 1, _self.parent.y + _self.parent.h - 1); 
							},
							function(_self)
							{
								var targetX = mouse_x, targetY = mouse_y;
								_self.parent.w += (_self.parent.x - targetX);
								_self.parent.h += (targetY - (_self.parent.y + _self.parent.h));
								_self.parent.x = targetX;
								if (_self.parent.w <= 3)
									_self.parent.w = 3;
								if (_self.parent.h <= 3)
									_self.parent.h = 3;
							});
							
	static update = function()
	{
		drawCorners = true;
		
		topLeftCorner.update();
		topRightCorner.update();
		bottomRightCorner.update();
		bottomLeftCorner.update();
	}
		
	static updateFullDrag = function(ind)
	{
		drawCorners = false;
		
		var mX = mouse_x, mY = mouse_y;
		if (lastMouseX != undefined)
		{
			if (mX >= x && mX <= x + w && mY >= y && mY <= y + h)
			{
				if (mouse_check_button_released(mb_right))
				{
					ds_list_delete(obj_main.selectRects, ind);
					obj_main.numFrames--;
					return;
				}
				
				lastDidDrag = mouse_check_button(mb_left) && (!global.mouseDragging || lastDidDrag);
				if (lastDidDrag)
				{
					global.mouseDragging = true;
					x += (mX - lastMouseX);
					y += (mY - lastMouseY);
				} else
					global.mouseDragging = false;
				highlight = true;
			} else if (lastDidDrag)
			{
				lastDidDrag = !mouse_check_button_released(mb_left);
				if (lastDidDrag)
				{
					global.mouseDragging = true;
					x += (mX - lastMouseX);
					y += (mY - lastMouseY);
				} else
					global.mouseDragging = false;
				highlight = true;
			}
		}
		
		lastMouseX = mX;
		lastMouseY = mY;
	}
	
	static draw = function(ind)
	{
		draw_set_alpha(0.6);
		if (drawCorners)
		{
			topLeftCorner.draw();
			topRightCorner.draw();
			bottomRightCorner.draw();
			bottomLeftCorner.draw();
		} else
		{
			draw_set_font(fnt_main);
			draw_set_color(c_black);
			draw_text_transformed(x + 1.25, y + 1.25, string(ind), 0.25, 0.25, 0);
			draw_set_color(c_yellow);
			draw_text_transformed(x + 1, y + 1, string(ind), 0.25, 0.25, 0);
		}
		if (highlight)
		{
			draw_set_color(c_red);
			draw_rectangle(x, y, x + w - 1, y + h - 1, false);
		}
		draw_set_color(c_yellow);
		draw_rectangle(x, y, x + w - 1, y + h - 1, true);
		draw_set_alpha(1);
		
		highlight = false;
	};
};