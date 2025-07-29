local otherPlayerStates = {}

--RegisterNetEvent

RegisterNetEvent("flashlight:updateAll", function(states)
    otherPlayerStates = states
end)

--フラッシュライトの使用状況の同期
CreateThread(function()
    while true do
        Wait(50)

        local ped = PlayerPedId()
        local flashlightOn = IsFlashLightOn(ped)
        local coords = GetEntityCoords(ped)
        local camRot = GetGameplayCamRot(2)
        TriggerServerEvent("flashlight:updateState", flashlightOn, coords, camRot)
    end
end)

--DrawCorona（フラッシュライトの描画）
CreateThread(function()
    while true do
        Wait(0)
        local myPed = PlayerPedId()

        for playerId, data in pairs(otherPlayerStates) do
            local target = GetPlayerFromServerId(playerId)
            if target and NetworkIsPlayerActive(target) then
                local targetPed = GetPlayerPed(target)
                if targetPed ~= myPed and data.state then
                    local boneId = GetPedBoneIndex(targetPed, 57005)    -- 右手のボーン
                    local boneCoords = GetWorldPositionOfEntityBone(targetPed, boneId)     --ボーンのワールド座標

                    -- プレイヤーの回転から pitch を取得（上下角度）
                    local pitch = math.rad(data.rotation.x or 0)

                    -- direction ベクトルの修正：視線に上下成分を反映

                    local forward = GetEntityForwardVector(targetPed)
                    local direction = vector3(
                        forward.x,
                        forward.y,
                        math.tan(pitch)
                    )
                    direction = direction / #(direction) -- 正規化

                    -- 武器がフラッシュライトならZオフセットなし、それ以外の武器は少し上
                    local weaponHash = GetSelectedPedWeapon(targetPed)
                    local isFlashlight = (weaponHash == GetHashKey("WEAPON_FLASHLIGHT")) --Flashlight（近接）のみ構える場所が違うのでオフセットを考慮して0
                    local zOffset = isFlashlight and 0.0 or 0.125

                    local coronaPos = boneCoords + direction * 0.5 + vector3(0.0, 0.0, zOffset)

                    DrawCorona(
                        coronaPos.x, coronaPos.y, coronaPos.z,
                        3.5,                                   -- サイズ
                        255, 255, 200,                         -- 色
                        255,                                   -- アルファ
                        15.0,                                  -- intensity
                        0.2,                                   --Z-bias

                        direction.x, direction.y, direction.z, -- 向き
                        1.0, 0.0, 90.0,                        -- range, inner angle, outer angle
                        2
                    )
                end
            end
        end
    end
end)
