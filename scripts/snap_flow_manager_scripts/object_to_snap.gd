@tool
extends BaseTagGraphNode


func configure_slots(tag: Control) -> void:
	set_slot(tag.get_index(), false, 1, Color(0.846, 0.399, 0.0), true, 1, Color(0.846, 0.399, 0.0))
