local flashlightStates = {}

RegisterNetEvent("flashlight:updateState", function(state, coords, rotation)
    local src = source
    flashlightStates[src] = {
        state = state,
        coords = coords,
        rotation = rotation
    }

    TriggerClientEvent("flashlight:updateAll", -1, flashlightStates)
end)

AddEventHandler("playerDropped", function()
    flashlightStates[source] = nil
    TriggerClientEvent("flashlight:updateAll", -1, flashlightStates)
end)