-- client.lua
local lastFlashState = false

CreateThread(function()
    while true do
        Wait(50) -- 頻度調整（低負荷）

        local ped = PlayerPedId()
        local flashlightOn = IsFlashLightOn(ped)
        local coords = GetEntityCoords(ped)
        local rotation = GetEntityRotation(ped, 2)
        
        local camRot = GetGameplayCamRot(2)  -- カメラの回転
        TriggerServerEvent("flashlight:updateState", flashlightOn, coords, camRot)
    end
end)

local syncedFlashPlayers = {}
local otherPlayerStates = {}

RegisterNetEvent("flashlight:updateAll", function(states)
    otherPlayerStates = states
end)

RegisterNetEvent("flashlight:syncStates", function(states)
    syncedFlashPlayers = states
end)
CreateThread(function()
    while true do
        Wait(0)
        local myPed = PlayerPedId()

        for playerId, data in pairs(otherPlayerStates) do
            local target = GetPlayerFromServerId(playerId)
            if target and NetworkIsPlayerActive(target) then
                local targetPed = GetPlayerPed(target)
                if targetPed ~= myPed and data.state then
                    -- 右手ボーン位置
                    local boneId = GetPedBoneIndex(targetPed, 57005)
                    local boneCoords = GetWorldPositionOfEntityBone(targetPed, boneId)

                    -- プレイヤーの回転から pitch を取得（上下角度）
                    local pitch = math.rad(data.rotation.x or 0)

                    -- direction ベクトルの修正：視線に上下成分を反映

                    local heading = GetEntityHeading(targetPed)

                    -- forwardベクトルにpitchを加味した3D方向を作成
                    local forward = GetEntityForwardVector(targetPed)
                    local direction = vector3(
                        forward.x,
                        forward.y,
                        math.tan(pitch) -- 上下方向
                    )
                    direction = direction / #(direction) -- 正規化

                    -- 武器がフラッシュライトならZオフセットなし、それ以外は少し上
                    local weaponHash = GetSelectedPedWeapon(targetPed)
                    local isFlashlight = (weaponHash == GetHashKey("WEAPON_FLASHLIGHT"))
                    local zOffset = isFlashlight and 0.0 or 0.125

                    -- Coronaの位置：右手の位置＋少し前方＋Z補正
                    local coronaPos = boneCoords + direction * 0.5 + vector3(0.0, 0.0, zOffset)

                    -- Coronaの描画
                    DrawCorona(
                        coronaPos.x, coronaPos.y, coronaPos.z,
                        3.5,               -- サイズ
                        255, 255, 200,     -- 色
                        255,               -- アルファ
                        15.0, 0.2,         -- intensity, Z-bias
                        direction.x, direction.y, direction.z, -- 向き
                        1.0, 0.0, 90.0,    -- range, inner angle, outer angle
                        2
                    )
                end
            end
        end
    end
end)
