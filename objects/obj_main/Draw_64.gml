display_set_gui_size(1024, 768);

draw_set_font(fnt_main);
draw_set_color(c_red);
switch (step)
{
	case stepkind.selectframeTL:
		draw_text_shadow(8, 8, "Select top left of first frame");
		break;
	case stepkind.selectframeBB:
		draw_text_shadow(8, 8, "Adjust bounding box, then hit ENTER");
		break;
	case stepkind.selectbgcolor:
		draw_text_shadow(8, 8, "Select BG color to clear, then hit ENTER\n(hold SHIFT for second color)");
		break;
	case stepkind.finaltweak:
		draw_text_shadow(8, 8, "Tweak positions of frames, then hit ENTER\nto export sprites (or hold SHIFT\nand press ENTER to export\nsprite strip)\n\nR to restart the process");
		break;
}

draw_set_color(bgcolor);
draw_rectangle(1024 - 24, 768 - 24, 1024, 768, false);
draw_set_color(bgcolor2);
draw_rectangle(1024 - 24, 768 - 48, 1024, 768 - 24, false);