package sandsim

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

WINDOW_PADDING :: 10
PANEL_PADDING :: 8.0
PANEL_HEADER :: 25
ITEM_HEIGHT :: 30.0

Panel :: struct {
	rect:               rl.Rectangle,
	padding:            f32,
	items:              [dynamic]Item,
	label:              string,
	content_start_top:  f32,
	content_start_left: f32,
	internal_width:     f32,
}

Item :: struct {
	rect:     rl.Rectangle,
	label:    string,
	type:     ItemType,
	height:   f32,
	value:    ^f32,
	show:     bool,
	callback: proc(),
}

ItemType :: enum {
	Button,
	Label,
	Dropdown,
}

main_panel: Panel
selected_material_idx: i32 = 1
selected_material_active: bool

ui_setup :: proc() {
	rl.GuiLoadStyle("res/style_dark.rgs")

	w: f32 = 200.0
	h: f32 = 100.0
	x := f32(rl.GetScreenWidth()) - w - WINDOW_PADDING
	y: f32 = WINDOW_PADDING
	main_panel = Panel {
		label              = "Material Properties",
		rect               = {x, y, w, h},
		padding            = PANEL_PADDING,
		content_start_left = x + PANEL_PADDING,
		content_start_top  = y + PANEL_PADDING + PANEL_HEADER,
		internal_width     = w - PANEL_PADDING * 2,
	}

	// append(&main_panel.items, Item{label = "Scale", type = .Label, height = ITEM_HEIGHT / 2})
	append(
		&main_panel.items,
		Item{label = "Material Type", type = .Dropdown, height = ITEM_HEIGHT},
	)
}

ui_update :: proc() -> bool {
	if !rl.CheckCollisionPointRec(input.mouse.px_pos, main_panel.rect) {
		return false
	}

	for item, i in main_panel.items {
		if !rl.CheckCollisionPointRec(input.mouse.px_pos, item.rect) {
			if item.type == .Dropdown {
				selected_material_active = true
			}
		} else {
			if item.type == .Dropdown {
				selected_material_active = false
			}
		}
	}

	if selected_material_active {
		recalc_panel_dims(
			&main_panel,
			main_panel.internal_width,
			ITEM_HEIGHT * f32(len(main_panel.items) + len(material_options)) + PANEL_PADDING,
		)
	} else {
		recalc_panel_dims(
			&main_panel,
			main_panel.internal_width,
			ITEM_HEIGHT * f32(len(main_panel.items)) + PANEL_PADDING,
		)
	}

	return true
}

ui_draw :: proc() {
	rl.GuiPanel(main_panel.rect, fmt.ctprint(main_panel.label))

	for item, i in main_panel.items {
		switch item.type {
		case .Label:
			rl.GuiLabel(
				{
					main_panel.content_start_left,
					calc_ypos(main_panel.content_start_top, i),
					main_panel.internal_width,
					item.height,
				},
				item.value == nil ? fmt.ctprint(item.label) : fmt.ctprintf("%s %f", item.label, item.value^),
			)

		case .Button:

		case .Dropdown:
			selected_material_active = rl.GuiDropdownBox(
				{
					main_panel.content_start_left,
					calc_ypos(main_panel.content_start_top, i),
					main_panel.internal_width,
					item.height,
				},
				fmt.ctprint(strings.join(material_options, "\n")),
				&selected_material_idx,
				selected_material_active,
			)
		}
	}
}

calc_ypos :: proc(y_from_top: f32, n: int) -> f32 {
	return y_from_top + ((ITEM_HEIGHT + PANEL_PADDING) * f32(n))
}

recalc_panel_dims :: proc(panel: ^Panel, internal_w, internal_h: f32) {
	panel.rect.height = internal_h + PANEL_HEADER + panel.padding * 2
	panel.internal_width = internal_w
	panel.rect.width = panel.internal_width + panel.padding * 2
}
