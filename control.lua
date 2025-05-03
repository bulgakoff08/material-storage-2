local HARD_DRIVES = require("prototypes.memory-modules")
local CLOUD_ACCESS_MODULE = "ms-cloud-access-module"
local MATERIAL_STORAGE_MODULE = "ms-material-access-module"

-- creates table with contents of inventory filter with qualities
local function createPlan (inventory)
    local result = {}
    local buffer = {}
    if inventory.is_filtered() then
        for index = 1, #inventory do
            local filter = inventory.get_filter(index)
            if filter ~= nil then
                local itemId = filter.name
                local stackSize = prototypes.item[itemId].stack_size
                local quality = filter.quality
                if not buffer[quality] then
                    buffer[quality] = {}
                end
                if buffer[quality][itemId] == nil then
                    buffer[quality][itemId] = stackSize
                else
                    buffer[quality][itemId] = buffer[quality][itemId] + stackSize
                end
            end
        end
        for quality, items in pairs(buffer) do
            for itemId, count in pairs(items) do
                table.insert(result, {itemId = itemId, count = count, quality = quality})
            end
        end
    end
    return result
end

local function takeItemFromInventories (itemId, requestAmount, quality, inventories)
    local itemsTaken = 0
    for _, inventory in pairs(inventories) do
        if inventory.get_item_count({name = itemId, quality = quality}) > 0 then
            local intention = requestAmount - itemsTaken
            itemsTaken = itemsTaken + inventory.remove({type = "item", name = itemId, count = intention, quality = quality})
            if itemsTaken == requestAmount then
                return itemsTaken
            end
        end
    end
    return itemsTaken
end

-- tries to take desired amount of items across all cloud chests and machine inventories
local function requestItemFromInventories (itemId, requestAmount, quality, chestInventories, machineInventories)
    local itemsTaken = takeItemFromInventories(itemId, requestAmount, quality, chestInventories)
    if itemsTaken < requestAmount then
        itemsTaken = itemsTaken + takeItemFromInventories(itemId, requestAmount - itemsTaken, quality, machineInventories)
    end
    return itemsTaken
end

-- tries to put specific amount of item into hard drive inventories and return amount actually placed into
local function putItemOnHardDrives (itemId, amount, quality, hardDrives)
    local result = 0
    local itemsLeft = amount
    for _, drive in pairs(hardDrives) do
        result = result + drive.insert({type = "item", name = itemId, quality = quality, count = itemsLeft})
        itemsLeft = amount - result
        if itemsLeft <= 0 then
            return result
        end
    end
    return result
end

-- insert items into machine according to its crafting speed and recipe demand
local function insertItem (machine, itemId, count, quality, multiplier, chestInventories, machineInventories)
    local required = count * multiplier
    if required > prototypes.item[itemId].stack_size then
        if count > prototypes.item[itemId].stack_size then
            required = count
        else
            required = prototypes.item[itemId].stack_size
        end
    end
    local inventory = machine.get_inventory(defines.inventory.assembling_machine_input)
    required = required - inventory.get_item_count({name = itemId, quality = quality})
    if required > 0 then
        if inventory.can_insert({type = "item", name = itemId, count = required, quality = quality}) then
            local requested = requestItemFromInventories(itemId, required, quality, chestInventories, machineInventories)
            if requested > 0 then
                inventory.insert({type = "item", name = itemId, count = requested, quality = quality})
            end
        end
    end
end

-- serves recipe inputs for a single machine
local function serveMachine (machine, chestInventories, machineInventories)
    local recipe
    local quality = "normal"
    if machine.type == "assembling-machine" or machine.type == "rocket-silo" then
        recipe, quality = machine.get_recipe()
    end
    if machine.type == "furnace" and machine.previous_recipe then
        recipe = machine.previous_recipe.name
        quality = machine.previous_recipe.quality
    end
    if recipe then
        local ingredients = recipe.ingredients
        local craftMultiplier = math.ceil(1 / recipe.energy * (machine.crafting_speed or 1)) -- * 2
        for _, ingredient in pairs(ingredients) do
            if ingredient.type == "item" then
                insertItem(machine, ingredient.name, ingredient.amount, quality, craftMultiplier, chestInventories, machineInventories)
            end
        end
    end
end

-- takes excess items from all material chests and then refills them according to plan with items from hard drives
local function serveMaterialChests (chests, hardDrives)
    for _, chest in pairs(chests) do
        for _, wrapper in pairs(chest.get_contents()) do
            if HARD_DRIVES[wrapper.name] == nil then
                local stored = putItemOnHardDrives(wrapper.name, wrapper.count, wrapper.quality, hardDrives)
                if stored > 0 then
                    chest.remove({type = "item", name = wrapper.name, count = stored, quality = wrapper.quality})
                end
            end
        end
        for _, metadata in pairs(createPlan(chest)) do
            local requestAmount = metadata.count - chest.get_item_count({name = metadata.itemId, quality = metadata.quality})
            if requestAmount > 0 and chest.can_insert({type = "item", name = metadata.itemId, count = requestAmount, quality = metadata.quality}) then
                local itemsTaken = takeItemFromInventories(metadata.itemId, metadata.count, metadata.quality, hardDrives)
                if itemsTaken > 0 then
                    chest.insert({type = "item", name = metadata.itemId, count = itemsTaken, quality = metadata.quality})
                end
            end
        end
    end
end

-- serves recipe outputs for a single machine into inventories
local function serveFilteredOutput (output, inventoryPlanPairs)
    for _, metadata in pairs(output.get_contents()) do
        local itemId = metadata.name
        local itemsLeft = metadata.count
        local quality = metadata.quality
        for _, inventoryPlanPair in pairs(inventoryPlanPairs) do
            for _, planItem in pairs(inventoryPlanPair.plan) do
                if planItem.itemId == itemId and planItem.quality == quality then
                    local storable = planItem.count - inventoryPlanPair.inventory.get_item_count({ name = itemId, quality = quality})
                    if storable > 0 then
                        local intention = itemsLeft
                        if storable < intention then
                            intention = storable
                        end
                        inventoryPlanPair.inventory.insert({ type = "item", name = itemId, count = intention, quality = quality})
                        itemsLeft = itemsLeft - output.remove({ type = "item", name = metadata.name, count = intention, quality = quality})
                    end
                end
            end
            if itemsLeft <= 0 then
                break
            end
        end
    end
end

local function serveOutput (output, inventories)
    for _, metadata in pairs(output.get_contents()) do
        local itemId = metadata.name
        local itemsLeft = metadata.count
        local quality = metadata.quality
        for _, inventory in pairs(inventories) do
            local inserted = inventory.insert({ type = "item", name = itemId, count = itemsLeft, quality = quality})
            if inserted > 0 then
                itemsLeft = itemsLeft - output.remove({ type = "item", name = metadata.name, count = inserted, quality = quality})
            end
            if (itemsLeft <= 0) then
                break
            end
        end
    end
end

local function isModuleInstalled (machine, moduleId)
    return (machine and machine.valid and machine.get_module_inventory() and machine.get_module_inventory().get_item_count(moduleId) > 0)
end

local function createContext (chests, exportChests, machines)
    local context = {
        fullCloudChests = {}, -- non-empty chest inventories (used to refill and output results)
        fullCloudMachines = {}, -- non-empty output inventories (used to refill only)
        fullExportChests = {}, -- non-empty export chest inventories
        cloudMachines = {}, -- list of machines with cloud access module
        inventoryPlanPairs = {} -- chests inventories with filters
    }
    for _, chest in pairs(chests) do
        if chest and chest.valid then
            local inventory = chest.get_inventory(defines.inventory.chest)
            if not inventory.is_empty() then
                table.insert(context.fullCloudChests, inventory)
            end
            local plan = createPlan(inventory)
            if #plan > 0 then
                table.insert(context.inventoryPlanPairs, {inventory = inventory, plan = plan})
            end
        end
    end
    for _, exportChest in pairs(exportChests) do
        if exportChest and exportChest.valid then
            local inventory = exportChest.get_inventory(defines.inventory.chest)
            if not inventory.is_empty() then
                table.insert(context.fullExportChests, inventory)
            end
        end
    end
    for _, machine in pairs(machines) do
        if isModuleInstalled(machine, CLOUD_ACCESS_MODULE) then
            table.insert(context.cloudMachines, machine)
            if not machine.get_output_inventory().is_empty() then
                table.insert(context.fullCloudMachines, machine.get_output_inventory())
            end
        end
    end
    return context
end

script.on_nth_tick(30, function()
    local hubInventory = game.get_player(1).force.get_linked_inventory("ms-material-hub-chest", 0)

    local driveInventories = {}
    for driveId, _ in pairs(HARD_DRIVES) do
        if hubInventory.get_item_count(driveId) > 0 then
            table.insert(driveInventories, game.get_player(1).force.get_linked_inventory(driveId, 0))
        end
    end
    local materialInventories = {}
    for _, chest in pairs(storage.materialChests or {}) do
        table.insert(materialInventories, chest.get_inventory(defines.inventory.chest))
    end

    local hubInventoryTable = {}
    table.insert(hubInventoryTable, hubInventory)
    serveMaterialChests(hubInventoryTable, driveInventories)

    -- pretending hub chest is an another hard drive with lowest priority
    table.insert(driveInventories, hubInventory)
    serveMaterialChests(materialInventories, driveInventories)
    for _, surface in pairs(storage.surfaces or {}) do
        local context = createContext(
                surface.cloudChests or {},
                surface.exportChests or {},
                surface.machines or {}
        )
        for _, exportChest in pairs(context.fullExportChests) do
            serveFilteredOutput(exportChest, context.inventoryPlanPairs)
        end
        for _, machine in pairs(context.cloudMachines) do
            serveMachine(machine, context.fullCloudChests, context.fullCloudMachines)
        end
        for _, output in pairs(context.fullCloudMachines) do
            serveFilteredOutput(output, context.inventoryPlanPairs)
        end
        for _, machine in pairs(surface.machines) do
            if isModuleInstalled(machine, MATERIAL_STORAGE_MODULE) then
                if machine.type ~= "rocket-silo" then
                    serveOutput(machine.get_output_inventory(), driveInventories)
                end
                serveMachine(machine, driveInventories, {})
            end
        end
    end
end)

local function isEntityCloudChest (entity)
    return entity.name == "ms-cloud-chest" or entity.name == "ms-cloud-logistic-chest"
end

local function isEntityExportChest (entity)
    return entity.name == "ms-cloud-export-chest"
end

local function isEntityMaterialChest (entity)
    return entity.name == "ms-material-chest" or entity.name == "ms-material-logistic-chest"
end

local function isEntityCombinator (entity)
    return entity.name == "ms-material-combinator"
end

local function isEntityMachine (entity)
    if entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "rocket-silo" then
        return entity.can_insert({name = CLOUD_ACCESS_MODULE}) or entity.can_insert({name = MATERIAL_STORAGE_MODULE})
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
            return
        end
        if storage.combinators == nil then
            storage.combinators = {}
        end
        if isEntityCombinator(entity) then
            table.insert(storage.combinators, entity)
            return
        end
        if storage.surfaces == nil then
            storage.surfaces = {}
        end
        if storage.surfaces[surfaceIndex] == nil then
            storage.surfaces[surfaceIndex] = {cloudChests = {}, machines = {}, exportChests = {}}
        end
        if isEntityCloudChest(entity) then
            table.insert(storage.surfaces[surfaceIndex].cloudChests, entity)
            return
        end
        if isEntityMachine(entity) then
            table.insert(storage.surfaces[surfaceIndex].machines, entity)
            return
        end
        if isEntityExportChest(entity) then
            if not storage.surfaces[surfaceIndex].exportChests then
                storage.surfaces[surfaceIndex].exportChests = {}
            end
            table.insert(storage.surfaces[surfaceIndex].exportChests, entity)
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
                return
            end
        end
        if isEntityCombinator(event.entity) then
            if removeEntityFromIndex(storage.combinators, event.entity) then
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
                return
            end
        end
        if isEntityExportChest(event.entity) then
            if removeEntityFromIndex(surface.exportChests or {}, event.entity) then
                return
            end
        end
        if isEntityMachine(event.entity) then
            if removeEntityFromIndex(surface.machines, event.entity) then
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
