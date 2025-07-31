local otherPlayerStates = {}

-- 自分のstateを更新
CreateThread(function()
    while true do
        Wait(50)

        local ped = PlayerPedId()
        local flashlightOn = IsFlashLightOn(ped)
        local coords = GetEntityCoords(ped)
        local camRot = GetGameplayCamRot(2)

        LocalPlayer.state:set("flashlight", {
            state = flashlightOn,
            coords = coords,
            rotation = camRot
        }, true)
    end
end)

-- 他人のstatebag変化を検知
AddStateBagChangeHandler("flashlight", nil, function(bagName, key, value, _unused, replicated)
    if not value or type(value) ~= "table" then return end

    local netId = tonumber(bagName:match("player:(%d+)"))
    if not netId then return end

    otherPlayerStates[netId] = value
end)

-- DrawCorona の描画処理
CreateThread(function()
    while true do
        Wait(0)
        local myPed = PlayerPedId()
        for serverId, data in pairs(otherPlayerStates) do
            local target = GetPlayerFromServerId(serverId)
            if target and NetworkIsPlayerActive(target) then
                local targetPed = GetPlayerPed(target)
                if targetPed ~= myPed and data.state then
                    local boneId = GetPedBoneIndex(targetPed, 57005)
                    local boneCoords = GetWorldPositionOfEntityBone(targetPed, boneId)

                    local pitch = math.rad(data.rotation.x or 0)

                    local forward = GetEntityForwardVector(targetPed)
                    local direction = vector3(
                        forward.x,
                        forward.y,
                        math.tan(pitch)
                    )
                    direction = direction / #(direction)

                    local weaponHash = GetSelectedPedWeapon(targetPed)
                    local isFlashlight = (weaponHash == GetHashKey("WEAPON_FLASHLIGHT"))
                    local zOffset = isFlashlight and 0.0 or 0.125

                    local coronaPos = boneCoords + direction * 0.5 + vector3(0.0, 0.0, zOffset)

                    DrawCorona(
                        coronaPos.x, coronaPos.y, coronaPos.z,
                        3.5,
                        255, 255, 200,
                        255,
                        15.0,
                        0.2,
                        direction.x, direction.y, direction.z,
                        1.0, 0.0, 90.0,
                        2
                    )
                end
            end
        end
    end
end)