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
    defines.events.on_robot_mined_entity
}, entityRemovalHandler)
