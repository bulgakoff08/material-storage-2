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

for itemId, metadata in pairs(require("memory-modules")) do
    data:extend({
        recipe("crafting", 0.5, itemId, items(), items(itemId, 1))
    })
end

for fluidId, digitalFluidId in pairs(require("fluid-map")) do
    data:extend({
        recipe("crafting-with-fluid", 1, digitalFluidId, items(fluidId, 100), items(digitalFluidId, 100)),
        recipe("crafting-with-fluid", 1, "ms-" .. fluidId, items(digitalFluidId, 100), items(fluidId, 100))
    })
end

data:extend({
    recipe("crafting", 0.5, "ms-cloud-access-module", items(), items("ms-cloud-access-module", 1)),
    recipe("crafting", 0.5, "ms-cloud-chest", items(), items("ms-cloud-chest", 1)),
    recipe("crafting", 0.5, "ms-cloud-logistic-chest", items(), items("ms-cloud-logistic-chest", 1)),
    recipe("crafting", 0.5, "ms-fine-quartz", items(), items("ms-fine-quartz", 1)),
    recipe("crafting", 0.5, "ms-material-combinator", items(), items("ms-material-combinator", 1)),
    recipe("crafting", 0.5, "ms-material-crystal", items(), items("ms-material-crystal", 1)),
    recipe("crafting", 0.5, "ms-material-hub-chest", items(), items("ms-material-hub-chest", 1)),
    recipe("crafting", 0.5, "ms-material-logistic-chest", items(), items("ms-material-logistic-chest", 1)),
    recipe("crafting", 0.5, "ms-resonating-crystal", items(), items("ms-resonating-crystal", 1)),
    recipe("crafting", 0.5, "ms-resonating-quartz", items(), items("ms-resonating-quartz", 1))
})