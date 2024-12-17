local GRAPHICS = "__material-storage-2__/graphics/items/"
local EQUIPMENT = "__material-storage-2__/graphics/equipment/"

local function item (subgroup, itemId, stackSize)
    return {
        type = "item",
        name = itemId,
        icon = GRAPHICS .. itemId .. ".png",
        icon_size = 64,
        subgroup = subgroup,
        order = "a[" .. itemId .. "]",
        stack_size = stackSize
    }
end

local function machine (subgroup, itemId, stackSize)
    local result = item(subgroup, itemId, stackSize)
    result["place_result"] = itemId
    return result
end

for itemId, _ in pairs(require("memory-modules")) do
    local drive = machine("ms-drives", itemId, 1)
    drive["place_as_equipment_result"] = itemId
    data:extend({
        drive,
        {
            type = "battery-equipment",
            name = itemId,
            sprite = {
                filename = EQUIPMENT .. itemId .. ".png",
                width = 128,
                height = 128,
                scale = 0.5,
                priority = "medium"
            },
            shape = {width = 2, height = 2, type = "full"},
            energy_source = {
                type = "electric", buffer_capacity = "0J", input_flow_limit = "0W",
                output_flow_limit = "0W", usage_priority = "tertiary"
            },
            categories = {"armor"}
        }
    })
end

for _, digitalFluidId in pairs(require("fluid-map")) do
    data:extend({
        item("ms-fluids", digitalFluidId, 1000)
    })
end

data:extend({
    -- machines
    machine("ms-chests", "ms-cloud-chest", 50),
    machine("ms-chests", "ms-cloud-logistic-chest", 50),
    machine("ms-chests", "ms-material-combinator", 50),
    machine("ms-chests", "ms-material-hub-chest", 50),
    machine("ms-chests", "ms-material-chest", 50),
    machine("ms-chests", "ms-material-logistic-chest", 50),

    -- details
    item("ms-details", "ms-fine-quartz", 50),
    item("ms-details", "ms-material-crystal", 50),
    item("ms-details", "ms-resonating-crystal", 50),
    item("ms-details", "ms-resonating-quartz", 50),

    -- module
    {
        type = "module",
        name = "ms-cloud-access-module",
        icon = GRAPHICS .. "ms-cloud-access-module.png",
        icon_size = 64,
        subgroup = "ms-modules",
        category = "efficiency",
        weight = 10000,
        tier = 1,
        order = "a[cloud-access-module]",
        stack_size = 50,
        effect = {
            consumption = 0.5
        },
        beacon_tint = {
            primary = {r = 0.441, g = 0.714, b = 1.000, a = 1.000},
            secondary = {r = 0.388, g = 0.976, b = 1.000, a = 1.000}
        },
        art_style = "vanilla",
        requires_beacon_alt_mode = false
    },
    {
        type = "module",
        name = "ms-material-access-module",
        icon = GRAPHICS .. "ms-material-access-module.png",
        icon_size = 64,
        subgroup = "ms-modules",
        category = "efficiency",
        weight = 10000,
        tier = 1,
        order = "a[material-access-module]",
        stack_size = 50,
        effect = {
            consumption = 0.5
        },
        beacon_tint = {
            primary = {r = 0.441, g = 0.714, b = 1.000, a = 1.000},
            secondary = {r = 0.388, g = 0.976, b = 1.000, a = 1.000}
        },
        art_style = "vanilla",
        requires_beacon_alt_mode = false
    }
})