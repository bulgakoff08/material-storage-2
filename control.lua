local drives = require("prototypes.memory-modules")

-- creates table with contents of inventory filter
local function createPlan (inventory)
    if inventory.is_filtered() then
        local result = {}
        for index = 1, #inventory do
            local filter = inventory.get_filter(index)
            if filter ~= nil then
                local itemId = filter.name
                if result[itemId] == nil then
                    result[itemId] = prototypes.item[itemId].stack_size
                else
                    result[itemId] = result[itemId] + prototypes.item[itemId].stack_size
                end
            end
        end
        return result
    end
    return false
end

-- tries to take desired amount of items from inventory and returns amount actually taken
local function extractFromInventory (inventory, itemId, intention)
    return inventory.remove({type = "item", name = itemId, count = intention})
end

local function takeItemFromInventories (itemId, requestAmount, inventories)
    local itemsTaken = 0
    for _, inventory in pairs(inventories) do
        if inventory.get_item_count(itemId) > 0 then
            local intention = requestAmount - itemsTaken
            itemsTaken = itemsTaken + extractFromInventory(inventory, itemId, intention)
            if itemsTaken == requestAmount then
                return itemsTaken
            end
        end
    end
    return itemsTaken
end

-- tries to take desired amount of items across all cloud chests and machine inventories
local function requestCloudItems (context, itemId, requestAmount)
    local itemsTaken = takeItemFromInventories(itemId, requestAmount, context.nonEmptyChests)
    if itemsTaken < requestAmount then
        itemsTaken = itemsTaken + takeItemFromInventories(itemId, requestAmount - itemsTaken, context.nonEmptyMachines)
    end
    return itemsTaken
end

-- insert items into machine according to its crafting speed and recipe demand
local function insertItem (context, machine, itemId, count, multiplier)
    local required = count * multiplier
    local inventory = machine.get_inventory(defines.inventory.assembling_machine_input)
    if inventory.get_item_count(itemId) < required then
        if inventory.can_insert({type = "item", name = itemId, count = required}) then
            local requested = requestCloudItems(context, itemId, required)
            if requested > 0 then
                inventory.insert({type = "item", name = itemId, count = requested})
            end
        end
    end
end

-- serves recipe inputs for a single machine
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
        local itemId = item.name
        local itemsLeft = item.count
        for _, chest in pairs(context.filteredChests) do
            if chest.plan[itemId] then
                local storable = chest.plan[itemId] - chest.inventory.get_item_count(itemId)
                if storable > 0 then
                    local intention = itemsLeft
                    if storable < intention then
                        intention = storable
                    end
                    chest.inventory.insert({type = "item", name = itemId, count = intention})
                    itemsLeft = itemsLeft - output.remove({type = "item", name = item.name, count = intention})
                end
            end
            if itemsLeft <= 0 then
                break
            end
        end
    end
end

local function createContext (chests, machines, hardDrives)
    local context = {
        nonEmptyChests = {}, -- non-empty chest inventories (used to refill and output results)
        nonEmptyMachines = {}, -- non-empty output inventories (used to refill only)
        servedMachines = {}, -- list of machines with cloud access module
        filteredChests = {}, -- chests inventories with filters
        hardDrives = hardDrives -- list of active hard drives
    }
    for _, chest in pairs(chests) do
        if chest and chest.valid then
            local inventory = chest.get_inventory(defines.inventory.chest)
            if not inventory.is_empty() then
                table.insert(context.nonEmptyChests, inventory)
            end
            local plan = createPlan(inventory)
            if plan then
                table.insert(context.filteredChests, {inventory = inventory, plan = plan})
            end
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
    local hubInventory = game.get_player(1).force.get_linked_inventory("ms-material-hub-chest", 0)
    local activeHardDrives = {}
    for driveId, _ in pairs(drives) do
        if hubInventory.get_item_count(driveId) > 0 then
            table.insert(activeHardDrives, game.get_player(1).force.get_linked_inventory(driveId, 0))
        end
    end
    for _, surface in pairs(storage.surfaces or {}) do
        local context = createContext(surface.cloudChests, surface.machines, activeHardDrives)
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
