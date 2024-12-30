local GRAPHICS = "__material-storage-2__/graphics/items/"
local utils = require("commons")

local function items (...)
    local arguments = {...}
    local result = {}
    for index = 1, #arguments, 2 do
        if arguments[index + 1] < 1 then
            table.insert(result, {
                type = utils.itemType(arguments[index]),
                name = arguments[index],
                probability = arguments[index + 1],
                amount = 1
            })
        else
            table.insert(result, {
                type = utils.itemType(arguments[index]),
                name = arguments[index],
                amount = arguments[index + 1]
            })
        end
    end
    return result
end

local function recipe (category, craftingTime, recipeId, inputs, outputs, productivity)
    return {
        type = "recipe",
        name = recipeId,
        category = category,
        ingredients = inputs,
        results = outputs,
        energy_required = craftingTime,
        allow_productivity = productivity or false
    }
end

for itemId, _ in pairs(require("memory-modules")) do
    data:extend({
        recipe("crafting", 1, itemId, items("ms-resonating-quartz", 1, "ms-resonating-crystal", 1, "electronic-circuit", 5, "steel-chest", 5), items(itemId, 1))
    })
    if mods["material-storage"] then
        data:extend({
            {
                type = "recipe",
                name = itemId .. "-convert",
                category = "crafting",
                ingredients = items("ms-memory-module-t3", 1),
                results = items(itemId, 1),
                energy_required = 0.1
            },
            {
                type = "recipe",
                name = itemId .. "-convert-2",
                category = "crafting",
                ingredients = items("ms-memory-subnet-card", 1),
                results = items(itemId, 1),
                energy_required = 0.1
            }
        })
    end
end

data:extend({
    recipe("crafting", 1, "ms-material-hub-chest", items("ms-resonating-quartz", 10, "ms-resonating-crystal", 10, "steel-chest", 5, "processing-unit", 20), items("ms-material-hub-chest", 1)),
    recipe("crafting", 1, "ms-material-access-module", items("ms-resonating-crystal", 1, "advanced-circuit", 5, "processing-unit", 5), items("ms-material-access-module", 1)),
    recipe("crafting", 1, "ms-material-chest", items("ms-resonating-crystal", 1, "iron-chest", 1), items("ms-material-chest", 1)),
})

if not mods["material-storage"] then
    for fluidId, digitalFluidId in pairs(require("fluid-map")) do
        data:extend({
            recipe("crafting-with-fluid", 1, digitalFluidId, items(fluidId, 100), items(digitalFluidId, 100)),
            recipe("crafting-with-fluid", 1, "ms-" .. fluidId, items(digitalFluidId, 100), items(fluidId, 100))
        })
    end
    data:extend({
        recipe("crafting", 1, "ms-material-combinator", items("ms-resonating-quartz", 1, "constant-combinator", 1), items("ms-material-combinator", 1)),
        recipe("crafting", 1, "ms-material-logistic-chest", items("ms-resonating-crystal", 1, "buffer-chest", 1), items("ms-material-logistic-chest", 1)),
        recipe("crafting", 20, "ms-resonating-crystal", items("ms-material-crystal", 1, "advanced-circuit", 5), items("ms-resonating-crystal", 1), true),
        {
            type = "recipe",
            name = "ms-material-crystal",
            icon = GRAPHICS .. "ms-material-crystal.png",
            subgroup = "ms-details",
            category = "advanced-crafting",
            energy_required = 5,
            allow_quality = false,
            ingredients = {
                {type = "item", name = "stone", amount = 10}
            },
            results = {
                {type = "item", name = "stone", amount = 5, probability = 0.75},
                {type = "item", name = "ms-material-crystal", amount = 1, probability = 0.25}
            }
        }
    })
else
    data:extend({
        recipe("crafting", 0.1, "ms-resonating-crystal", items("ms-material-crystal-charged", 1), items("ms-resonating-crystal", 1))
    })
end

if mods["cloud-crafting"] then
    data:extend({
        recipe("crafting", 0.1, "ms-cloud-access-module", items("cc-cloud-access-module", 1), items("ms-cloud-access-module", 1)),
        recipe("crafting", 0.1, "ms-cloud-chest", items("cc-cloud-chest", 1), items("ms-cloud-chest", 1)),
        recipe("crafting", 0.1, "ms-cloud-logistic-chest", items("cc-cloud-logistic-chest", 1), items("ms-cloud-logistic-chest", 1)),
        recipe("crafting", 0.1, "ms-resonating-quartz", items("cc-resonating-crystal", 1), items("ms-resonating-quartz", 1)),
        recipe("crafting", 0.1, "ms-fine-quartz", items("cc-fine-quartz", 1), items("ms-fine-quartz", 1)),
    })
else
    data:extend({
        recipe("crafting", 1, "ms-cloud-access-module", items("ms-resonating-quartz", 1, "electronic-circuit", 5), items("ms-cloud-access-module", 1)),
        recipe("crafting", 1, "ms-cloud-chest", items("ms-resonating-quartz", 1, "iron-chest", 1), items("ms-cloud-chest", 1)),
        recipe("crafting", 1, "ms-cloud-logistic-chest", items("ms-resonating-quartz", 1, "storage-chest", 1), items("ms-cloud-logistic-chest", 1)),
        recipe("crafting", 20, "ms-resonating-quartz", items("ms-fine-quartz", 1, "copper-cable", 20), items("ms-resonating-quartz", 1), true),
        {
            type = "recipe",
            name = "ms-fine-quartz",
            icon = GRAPHICS .. "ms-fine-quartz.png",
            subgroup = "ms-details",
            category = "advanced-crafting",
            energy_required = 5,
            allow_quality = false,
            auto_recycle = false,
            ingredients = {
                {type = "item", name = "stone", amount = 10}
            },
            results = {
                {type = "item", name = "stone", amount = 5, probability = 0.75},
                {type = "item", name = "ms-fine-quartz", amount = 1, probability = 0.25}
            }
        },
    })
end