-- tries to take desired amount of items from inventory and returns amount actually taken
local function extractFromInventory (inventory, itemId, intention, leaveOne)
    if leaveOne then
        local available = inventory.get_item_count(itemId) - 1
        if available == 0 then
            return 0
        end
        if available < intention then
            return inventory.remove({type = "item", name = itemId, count = available})
        end
    end
    return inventory.remove({type = "item", name = itemId, count = intention})
end

-- tries to take desired amount of items across all chests and machine inventories
-- TODO: make this accept list of inventories so it can be reused for hard drives
-- TODO: non empty machines inventories should be generated on previous step
local function requestItems (context, itemId, requestAmount)
    local itemsTaken = 0
    for _, chest in pairs(context.nonEmptyChests) do
        if chest.get_item_count(itemId) > 1 then
            local intention = requestAmount - itemsTaken
            itemsTaken = itemsTaken + extractFromInventory(chest, itemId, intention, true)
            if itemsTaken == requestAmount then
                return itemsTaken
            end
        end
    end
    for _, machine in pairs(context.nonEmptyMachines) do
        if machine.get_item_count(itemId) > 0 then
            local intention = requestAmount - itemsTaken
            itemsTaken = itemsTaken + extractFromInventory(machine, itemId, intention, false)
            if itemsTaken == requestAmount then
                return itemsTaken
            end
        end
    end
    return itemsTaken
end

-- insert items into machine according to its crafting speed and recipe demand
-- TODO: need to configure this method so it accept either list of cloud chests of list of hard drives depending on module inside
local function insertItem (context, machine, itemId, count, multiplier)
    local required = count * multiplier
    local inventory = machine.get_inventory(defines.inventory.assembling_machine_input)
    if inventory.get_item_count(itemId) < required then
        if inventory.can_insert({type = "item", name = itemId, count = required}) then
            local requested = requestItems(context, itemId, required)
            if requested > 0 then
                inventory.insert({type = "item", name = itemId, count = requested})
            end
        end
    end
end

-- serves recipe inputs for a single machine
-- TODO: need to configure this method so it accept either list of cloud chests of list of hard drives depending on module inside
local function serveMachine (context, machine)
    local recipe
    if machine.type == "assembling-machine" then
        recipe = machine.get_recipe()
    end
    if machine.type == "furnace" and machine.previous_recipe then
        recipe = machine.previous_recipe.name
    end
    if recipe then
        local ingredients = recipe.ingredients
        local craftMultiplier = math.ceil(1 / recipe.energy * (machine.crafting_speed or 1)) * 2
        for _, ingredient in pairs(ingredients) do
            if ingredient.type == "item" then
                insertItem(context, machine, ingredient.name, ingredient.amount, craftMultiplier)
            end
        end
    end
end

-- serves recipe outputs for a single machine
local function serveOutput (context, output)
    for _, item in pairs(output.get_contents()) do
        local itemsLeft = item.count
        for _, chest in pairs(context.nonEmptyChests) do
            if chest.get_item_count(item.name) > 0 then
                local inserted = chest.insert({type = "item", name = item.name, count = itemsLeft})
                if inserted > 0 then
                    itemsLeft = itemsLeft - output.remove({type = "item", name = item.name, count = inserted})
                end
            end
            if itemsLeft <= 0 then
                break
            end
        end
    end
end

-- TODO: context must include available hard drive inventories
-- TODO: add table with available cloud chests and their filters plan, do not include inventories with no plan
local function createContext (chests, machines)
    local context = {
        nonEmptyChests = {}, -- non-empty chest inventories (used to refill and output results)
        nonEmptyMachines = {}, -- non-empty output inventories (used to refill only)
        servedMachines = {} -- list of machines with cloud access module
    }
    for _, chest in pairs(chests) do
        if chest and chest.valid and not chest.get_inventory(defines.inventory.chest).is_empty() then
            table.insert(context.nonEmptyChests, chest.get_inventory(defines.inventory.chest))
        end
    end
    for _, machine in pairs(machines) do
        if machine and machine.valid and machine.get_module_inventory() and machine.get_module_inventory().get_item_count("ms-cloud-access-module") > 0 then
            table.insert(context.servedMachines, machine)
            if not machine.get_output_inventory().is_empty() then
                table.insert(context.nonEmptyMachines, machine.get_output_inventory())
            end
        end
    end
    return context
end

script.on_nth_tick(60, function()
    for _, surface in pairs(storage.surfaces or {}) do
        local context = createContext(surface.cloudChests, surface.machines)
        for _, output in pairs(context.nonEmptyMachines) do
            serveOutput(context, output)
        end
        for _, machine in pairs(context.servedMachines) do
            serveMachine(context, machine)
        end
    end
end)

local function isEntityCloudChest (entity)
    return entity.name == "ms-cloud-chest" or entity.name == "ms-cloud-logistic-chest"
end

local function isEntityMaterialChest (entity)
    return entity.name == "ms-material-chest" or entity.name == "ms-material-logistic-chest"
end

local function isEntityCombinator (entity)
    return entity.name == "ms-material-combinator"
end

local function isEntityMachine (entity)
    if entity.type == "assembling-machine" or entity.type == "furnace" then
        return entity.can_insert({name = "ms-cloud-access-module"}) or entity.can_insert({name = "ms-material-access-module"})
    end
end

local function entityPlacementHandler (entity)
    if entity ~= nil and entity.valid then
        local surfaceIndex = entity.surface.index
        if storage.materialChests == nil then
            storage.materialChests = {}
        end
        if isEntityMaterialChest(entity) then
            table.insert(storage.materialChests, entity)
            game.get_player(1).print("Registered material chest or material logistic chest (" .. #storage.materialChests .. ")")
            return
        end
        if storage.combinators == nil then
            storage.combinators = {}
        end
        if isEntityCombinator(entity) then
            table.insert(storage.combinators, entity)
            game.get_player(1).print("Registered combinator (" .. #storage.combinators .. ")")
            return
        end
        if storage.surfaces == nil then
            storage.surfaces = {}
        end
        if storage.surfaces[surfaceIndex] == nil then
            storage.surfaces[surfaceIndex] = {cloudChests = {}, machines = {}}
        end
        if isEntityCloudChest(entity) then
            table.insert(storage.surfaces[surfaceIndex].cloudChests, entity)
            game.get_player(1).print("Registered cloud chest or cloud logistic chest (" .. #storage.surfaces[surfaceIndex].cloudChests .. ")")
            return
        end
        if isEntityMachine(entity) then
            table.insert(storage.surfaces[surfaceIndex].machines, entity)
            game.get_player(1).print("Registered suitable machine (" .. #storage.surfaces[surfaceIndex].machines .. ")")
            return
        end
    end
end

script.on_event(defines.events.on_built_entity, function(event) entityPlacementHandler(event.entity, event.player) end)
script.on_event(defines.events.on_robot_built_entity, function(event) entityPlacementHandler(event.entity, event.player) end)
script.on_event(defines.events.on_entity_cloned, function(event) entityPlacementHandler(event.destination, event.player) end)
script.on_event(defines.events.on_space_platform_built_entity, function(event) entityPlacementHandler(event.entity, event.player) end)

local function removeEntityFromIndex (entityList, entity)
    if entityList then
        for counter = 1, #entityList do
            if entityList[counter] == entity then
                table.remove(entityList, counter)
                return true
            end
        end
    end
    return false
end

local function entityRemovalHandler (event)
    if event.entity and event.entity.valid then
        if isEntityMaterialChest(event.entity) then
            if removeEntityFromIndex(storage.materialChests, event.entity) then
                game.get_player(1).print("Removed material chest or material logistic chest (" .. #storage.materialChests .. ")")
                return
            end
        end
        if isEntityCombinator(event.entity) then
            if removeEntityFromIndex(storage.combinators, event.entity) then
                game.get_player(1).print("Removed material combinator (" .. #storage.combinators .. ")")
                return
            end
        end
        local surfaceIndex = event.entity.surface.index
        if storage.surfaces == nil then
            return
        end
        if storage.surfaces[surfaceIndex] == nil then
            return
        end
        local surface = storage.surfaces[surfaceIndex]
        if isEntityCloudChest(event.entity) then
            if removeEntityFromIndex(surface.cloudChests, event.entity) then
                game.get_player(1).print("Removed cloud chest or cloud logistic chest (" .. #surface.cloudChests .. ")")
                return
            end
        end
        if isEntityMachine(event.entity) then
            if removeEntityFromIndex(surface.machines, event.entity) then
                game.get_player(1).print("Removed machine (" .. #surface.machines .. ")")
                return
            end
        end
    end
end

script.on_event({
    defines.events.on_entity_died,
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.on_space_platform_mined_entity
}, entityRemovalHandler)
