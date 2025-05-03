local GRAPHICS = "__material-storage-2__/graphics/items/"
local ENTITIES = "__material-storage-2__/graphics/entities/"

local function createHardDrive (entityId, linkId)
    return {
        type = "linked-container",
        name = entityId,
        icon = GRAPHICS .. entityId .. ".png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {
            mining_time = 0.5,
            results = {
                { type = "item", name = entityId, amount = 1}
            }
        },
        max_health = 250,
        corpse = "iron-chest-remnants",
        dying_explosion = "iron-chest-explosion",
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
        resistances = {
            {type = "fire", percent = 90},
            {type = "explosion", percent = 30},
            {type = "impact", percent = 30}
        },
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        picture = {
            layers = {
                {
                    filename = ENTITIES .. entityId .. ".png",
                    priority = "extra-high",
                    width = 66,
                    height = 76,
                    shift = util.by_pixel(-0.5, -0.5),
                    scale = 0.5
                },
                {
                    filename = ENTITIES .. "small-chest-shadow.png",
                    priority = "extra-high",
                    width = 110,
                    height = 50,
                    shift = util.by_pixel(10.5, 6),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },
        link_id = linkId,
        inventory_size = 2048,
        inventory_type = "normal",
        gui_mode = "none",
        circuit_connector = circuit_connector_definitions["chest"],
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
        close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75}
    }
end

local function generateMaterialCombinator (prototype)
    prototype.sprites = make_4way_animation_from_spritesheet({
        layers = {
            {
                scale = 0.5,
                filename = ENTITIES .. "ms-material-combinator.png",
                width = 114,
                height = 102,
                frame_count = 1,
                shift = util.by_pixel(0, 5)
            },
            {
                scale = 0.5,
                filename = ENTITIES .. "material-combinator-shadow.png",
                width = 98,
                height = 66,
                frame_count = 1,
                shift = util.by_pixel(8.5, 5.5),
                draw_as_shadow = true
            }
        }
    })
    prototype.activity_led_sprites = {
        north = util.draw_as_glow({
            scale = 0.5,
            filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
            width = 14,
            height = 12,
            frame_count = 1,
            shift = util.by_pixel(9, -11.5)
        }),
        east = util.draw_as_glow({
            scale = 0.5,
            filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png",
            width = 14,
            height = 14,
            frame_count = 1,
            shift = util.by_pixel(7.5, -0.5)
        }),
        south = util.draw_as_glow({
            scale = 0.5,
            filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png",
            width = 14,
            height = 16,
            frame_count = 1,
            shift = util.by_pixel(-9, 2.5)
        }),
        west = util.draw_as_glow({
            scale = 0.5,
            filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png",
            width = 14,
            height = 16,
            frame_count = 1,
            shift = util.by_pixel(-7, -15)
        })
    }
    prototype.circuit_wire_connection_points = {
        {
            shadow = {red = util.by_pixel(7, -6), green = util.by_pixel(23, -6)},
            wire = {red = util.by_pixel(-8.5, -17.5), green = util.by_pixel(7, -17.5)}
        },
        {
            shadow = {red = util.by_pixel(32, -5), green = util.by_pixel(32, 8)},
            wire = {red = util.by_pixel(16, -16.5), green = util.by_pixel(16, -3.5)}
        },
        {
            shadow = {red = util.by_pixel(25, 20), green = util.by_pixel(9, 20)},
            wire = {red = util.by_pixel(9, 7.5), green = util.by_pixel(-6.5, 7.5)}
        },
        {
            shadow = {red = util.by_pixel(1, 11), green = util.by_pixel(1, -2)},
            wire = {red = util.by_pixel(-15, -0.5), green = util.by_pixel(-15, -13.5)}
        }
    }
    return prototype
end

for entityId, metadata in pairs(require("memory-modules")) do
    data:extend({
        createHardDrive(entityId, metadata.inventoryId)
    })
end

data:extend({
    {
        type = "container",
        name = "ms-cloud-chest",
        icon = GRAPHICS .. "ms-cloud-chest.png",
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.2, result = "ms-cloud-chest"},
        max_health = 200,
        corpse = "iron-chest-remnants",
        dying_explosion = "iron-chest-explosion",
        open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43},
        close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43},
        resistances = {
            {type = "fire", percent = 80},
            {type = "impact", percent = 30}
        },
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        fast_replaceable_group = "container",
        inventory_size = 32,
        impact_category = "metal",
        icon_draw_specification = {scale = 0.7},
        inventory_type = "with_filters_and_bar",
        gui_mode = "none",
        picture = {
            layers = {
                {
                    filename = ENTITIES .. "ms-cloud-chest.png",
                    priority = "extra-high",
                    width = 66,
                    height = 76,
                    shift = util.by_pixel(-0.5, -0.5),
                    scale = 0.5
                },
                {
                    filename = ENTITIES .. "small-chest-shadow.png",
                    priority = "extra-high",
                    width = 110,
                    height = 50,
                    shift = util.by_pixel(10.5, 6),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },
        circuit_connector = circuit_connector_definitions["chest"],
        circuit_wire_max_distance = default_circuit_wire_max_distance
    },
    {
        type = "container",
        name = "ms-cloud-export-chest",
        icon = GRAPHICS .. "ms-cloud-export-chest.png",
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.2, result = "ms-cloud-export-chest"},
        max_health = 200,
        corpse = "iron-chest-remnants",
        dying_explosion = "iron-chest-explosion",
        open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43},
        close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43},
        resistances = {
            {type = "fire", percent = 80},
            {type = "impact", percent = 30}
        },
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        fast_replaceable_group = "container",
        inventory_size = 32,
        impact_category = "metal",
        icon_draw_specification = {scale = 0.7},
        inventory_type = "with_filters_and_bar",
        gui_mode = "none",
        picture = {
            layers = {
                {
                    filename = ENTITIES .. "ms-cloud-export-chest.png",
                    priority = "extra-high",
                    width = 66,
                    height = 76,
                    shift = util.by_pixel(-0.5, -0.5),
                    scale = 0.5
                },
                {
                    filename = ENTITIES .. "small-chest-shadow.png",
                    priority = "extra-high",
                    width = 110,
                    height = 50,
                    shift = util.by_pixel(10.5, 6),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },
        circuit_connector = circuit_connector_definitions["chest"],
        circuit_wire_max_distance = default_circuit_wire_max_distance
    },
    {
        type = "logistic-container",
        name = "ms-cloud-logistic-chest",
        icon = GRAPHICS .. "ms-cloud-logistic-chest.png",
        icon_size = 64,
        flags = {"placeable-player", "player-creation"},
        minable = {mining_time = 0.5, result = "ms-cloud-logistic-chest"},
        max_health = 350,
        corpse = "iron-chest-remnants",
        dying_explosion = "buffer-chest-explosion",
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        resistances = {
            {type = "fire", percent = 90},
            {type = "impact", percent = 60}
        },
        fast_replaceable_group = "container",
        inventory_size = 48,
        inventory_type = "with_filters_and_bar",
        gui_mode = "none",
        logistic_mode = "buffer",
        open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43},
        close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43},
        animation_sound = {
            {filename = "__base__/sound/passive-provider-chest-open-1.ogg", volume = 0.3},
            {filename = "__base__/sound/passive-provider-chest-open-2.ogg", volume = 0.3},
            {filename = "__base__/sound/passive-provider-chest-open-3.ogg", volume = 0.3},
            {filename = "__base__/sound/passive-provider-chest-open-4.ogg", volume = 0.3},
            {filename = "__base__/sound/passive-provider-chest-open-5.ogg", volume = 0.3}
        },
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
        opened_duration = 7,
        animation = {
            layers = {
                {
                    filename = ENTITIES .. "ms-cloud-logistic-chest.png",
                    priority = "extra-high",
                    width = 66,
                    height = 72,
                    frame_count = 7,
                    shift = util.by_pixel(0, -2),
                    scale = 0.5
                },
                {
                    filename = ENTITIES .. "large-chest-shadow.png",
                    priority = "extra-high",
                    width = 112,
                    height = 46,
                    repeat_count = 7,
                    shift = util.by_pixel(12, 4.5),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },
        circuit_connector = circuit_connector_definitions["chest"],
        circuit_wire_max_distance = default_circuit_wire_max_distance
    },
    {
        type = "linked-container",
        name = "ms-material-hub-chest",
        icon = GRAPHICS .. "ms-material-hub-chest.png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, results = {{type = "item", name = "ms-material-hub-chest", amount = 1}}},
        max_health = 250,
        corpse = "iron-chest-remnants",
        dying_explosion = "iron-chest-explosion",
        resistances = {
            {type = "fire", percent = 90},
            {type = "explosion", percent = 30},
            {type = "impact", percent = 30}
        },
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        picture = {
            layers = {
                {
                    filename = ENTITIES .. "ms-material-hub-chest.png",
                    priority = "extra-high",
                    width = 66,
                    height = 74,
                    shift = util.by_pixel(-0.5, -0.5),
                    scale = 0.5
                },
                {
                    filename = ENTITIES .. "large-chest-shadow.png",
                    priority = "extra-high",
                    width = 112,
                    height = 46,
                    shift = util.by_pixel(12, 4.5),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },
        link_id = 4950,
        inventory_size = 150,
        inventory_type = "with_filters_and_bar",
        gui_mode = "none",
        circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
        circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
        open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
        close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75}
    },
    {
        type = "container",
        name = "ms-material-chest",
        icon = GRAPHICS .. "ms-material-chest.png",
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.2, result = "ms-material-chest"},
        max_health = 200,
        corpse = "iron-chest-remnants",
        dying_explosion = "iron-chest-explosion",
        open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43},
        close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43},
        resistances = {
            {type = "fire", percent = 80},
            {type = "impact", percent = 30}
        },
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        fast_replaceable_group = "container",
        inventory_size = 32,
        impact_category = "metal",
        icon_draw_specification = {scale = 0.7},
        inventory_type = "with_filters_and_bar",
        gui_mode = "none",
        picture = {
            layers = {
                {
                    filename = ENTITIES .. "ms-material-chest.png",
                    priority = "extra-high",
                    width = 66,
                    height = 76,
                    shift = util.by_pixel(-0.5, -0.5),
                    scale = 0.5
                },
                {
                    filename = ENTITIES .. "small-chest-shadow.png",
                    priority = "extra-high",
                    width = 110,
                    height = 50,
                    shift = util.by_pixel(10.5, 6),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },
        circuit_connector = circuit_connector_definitions["chest"],
        circuit_wire_max_distance = default_circuit_wire_max_distance
    }
})

if not mods["material-storage"] then
    data:extend({
        {
            type = "logistic-container",
            name = "ms-material-logistic-chest",
            icon = GRAPHICS .. "ms-material-logistic-chest.png",
            icon_size = 64,
            flags = {"placeable-player", "player-creation"},
            minable = {mining_time = 0.5, result = "ms-material-logistic-chest"},
            max_health = 350,
            corpse = "iron-chest-remnants",
            dying_explosion = "buffer-chest-explosion",
            collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            resistances = {
                {type = "fire", percent = 90},
                {type = "impact", percent = 60}
            },
            fast_replaceable_group = "container",
            inventory_size = 48,
            inventory_type = "with_filters_and_bar",
            gui_mode = "none",
            logistic_mode = "buffer",
            open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43},
            close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43},
            animation_sound = {
                {filename = "__base__/sound/passive-provider-chest-open-1.ogg", volume = 0.3},
                {filename = "__base__/sound/passive-provider-chest-open-2.ogg", volume = 0.3},
                {filename = "__base__/sound/passive-provider-chest-open-3.ogg", volume = 0.3},
                {filename = "__base__/sound/passive-provider-chest-open-4.ogg", volume = 0.3},
                {filename = "__base__/sound/passive-provider-chest-open-5.ogg", volume = 0.3}
            },
            vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
            opened_duration = 7,
            animation = {
                layers = {
                    {
                        filename = ENTITIES .. "ms-material-logistic-chest.png",
                        priority = "extra-high",
                        width = 66,
                        height = 72,
                        frame_count = 7,
                        shift = util.by_pixel(0, -2),
                        scale = 0.5
                    },
                    {
                        filename = ENTITIES .. "large-chest-shadow.png",
                        priority = "extra-high",
                        width = 112,
                        height = 46,
                        repeat_count = 7,
                        shift = util.by_pixel(12, 4.5),
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            },
            circuit_connector = circuit_connector_definitions["chest"],
            circuit_wire_max_distance = default_circuit_wire_max_distance
        },
        generateMaterialCombinator({
            type = "constant-combinator",
            name = "ms-material-combinator",
            icon = GRAPHICS .. "ms-material-combinator.png",
            icon_size = 64,
            flags = {"placeable-neutral", "player-creation"},
            minable = {mining_time = 0.1, result = "ms-material-combinator"},
            max_health = 120,
            corpse = "constant-combinator-remnants",
            dying_explosion = "constant-combinator-explosion",
            collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            fast_replaceable_group = "constant-combinator",
            activity_led_light_offsets = {
                {0.296875, -0.40625},
                {0.25, -0.03125},
                {-0.296875, -0.078125},
                {-0.21875, -0.46875}
            },
            item_slot_count = 2000,
            circuit_wire_max_distance = default_circuit_wire_max_distance,
            vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
            open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
            close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75}
        })
    })
end

-- migration
if not mods["cloud-crafting"] then
    data:extend({
        {
            type = "container",
            name = "cc-cloud-chest",
            icon = GRAPHICS .. "ms-cloud-chest.png",
            flags = {"placeable-neutral", "player-creation"},
            minable = {mining_time = 0.2, result = "ms-cloud-chest"},
            max_health = 200,
            corpse = "iron-chest-remnants",
            dying_explosion = "iron-chest-explosion",
            open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43},
            close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43},
            resistances = {
                {type = "fire", percent = 80},
                {type = "impact", percent = 30}
            },
            collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            fast_replaceable_group = "container",
            inventory_size = 32,
            impact_category = "metal",
            icon_draw_specification = {scale = 0.7},
            inventory_type = "with_filters_and_bar",
            gui_mode = "none",
            picture = {
                layers = {
                    {
                        filename = ENTITIES .. "ms-cloud-chest.png",
                        priority = "extra-high",
                        width = 66,
                        height = 76,
                        shift = util.by_pixel(-0.5, -0.5),
                        scale = 0.5
                    },
                    {
                        filename = ENTITIES .. "small-chest-shadow.png",
                        priority = "extra-high",
                        width = 110,
                        height = 50,
                        shift = util.by_pixel(10.5, 6),
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            },
            circuit_connector = circuit_connector_definitions["chest"],
            circuit_wire_max_distance = default_circuit_wire_max_distance
        },
        {
            type = "logistic-container",
            name = "cc-cloud-logistic-chest",
            icon = GRAPHICS .. "ms-cloud-logistic-chest.png",
            icon_size = 64,
            flags = {"placeable-player", "player-creation"},
            minable = {mining_time = 0.5, result = "ms-cloud-logistic-chest"},
            max_health = 350,
            corpse = "iron-chest-remnants",
            dying_explosion = "buffer-chest-explosion",
            collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            resistances = {
                {type = "fire", percent = 90},
                {type = "impact", percent = 60}
            },
            fast_replaceable_group = "container",
            inventory_size = 48,
            inventory_type = "with_filters_and_bar",
            gui_mode = "none",
            logistic_mode = "buffer",
            open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43},
            close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43},
            animation_sound = {
                {filename = "__base__/sound/passive-provider-chest-open-1.ogg", volume = 0.3},
                {filename = "__base__/sound/passive-provider-chest-open-2.ogg", volume = 0.3},
                {filename = "__base__/sound/passive-provider-chest-open-3.ogg", volume = 0.3},
                {filename = "__base__/sound/passive-provider-chest-open-4.ogg", volume = 0.3},
                {filename = "__base__/sound/passive-provider-chest-open-5.ogg", volume = 0.3}
            },
            vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
            opened_duration = 7,
            animation = {
                layers = {
                    {
                        filename = ENTITIES .. "ms-cloud-logistic-chest.png",
                        priority = "extra-high",
                        width = 66,
                        height = 72,
                        frame_count = 7,
                        shift = util.by_pixel(0, -2),
                        scale = 0.5
                    },
                    {
                        filename = ENTITIES .. "large-chest-shadow.png",
                        priority = "extra-high",
                        width = 112,
                        height = 46,
                        repeat_count = 7,
                        shift = util.by_pixel(12, 4.5),
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            },
            circuit_connector = circuit_connector_definitions["chest"],
            circuit_wire_max_distance = default_circuit_wire_max_distance
        }
    })
end