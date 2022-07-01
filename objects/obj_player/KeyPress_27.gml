//inventory_item_add(SHOTGUN_SHELLS, 5, 0);
//inventory_item_remove_slot(0, true);

//effect_create_screen_fade(c_black, 0.1, 35);

//set_crippled(!isCrippled);
//DEBUG_ADD_MESSAGE(id,	"Hitpoints: " + string(hitpoints) + "/" + string(get_max_hitpoints()) + "\n" +
//						"Stamina: " + string(stamina) + "/" + string(get_max_stamina()));

add_additional_effect(irandom_range(EFFECT_DAMAGE_RESIST, EFFECT_HITPOINT_REGEN), choose(INDEFINITE_EFFECT_DURATION, 6000, 9000, 12000, 15000, 18000));