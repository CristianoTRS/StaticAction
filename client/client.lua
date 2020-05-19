ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end)

local actions = {}

function Draw3DText(x, y, z, text, color)

    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    
    if onScreen then
        SetTextScale(0.25*scale, 1.0*scale)
        SetTextFont(0)
        SetTextProportional(1)
        --SetTextScale(0.0, 0.55)
        SetTextColour(color.r, color.g, color.b, color.a)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function findClosestAction(x, y, z)

    local closestAction = 1000
    local closestIndex = 0
    local closestValue = nil

    for k, v in pairs(actions) do

        local dist = GetDistanceBetweenCoords(x, y, z, v.x, v.y, v.z, false)
        if dist < closestAction then
            closestAction = dist
            closestIndex = k
            closestValue = v
        end
    end

    if closestAction < 7.5 then
        return { closestIndex, closestValue }
    else
        return nil
    end
end

RegisterCommand('action', function(source, args, rawCommand)

    local playerPed = GetPlayerPed(-1)
    local coords = GetEntityCoords(playerPed)

    TriggerServerEvent('staticAction:server:actionCommand', coords, args, playerPed)
end)

RegisterCommand('raction', function(source, args, rawCommand)

    local playerPed = GetPlayerPed(-1)
    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    local closestAction = findClosestAction(x, y, z)

    if closestAction ~= nil then
        if closestAction[2].pid == playerPed then
            TriggerServerEvent('staticAction:server:ractionCommand', closestAction[1])
        else
            ESX.ShowNotification('~r~This action doesn\'t belong to you!')
        end
    else
        ESX.ShowNotification('~r~No action found.')
    end
end)

RegisterNetEvent('staticAction:client:actionCommand')
AddEventHandler('staticAction:client:actionCommand', function(coords, args, pid)

    local msg = table.concat(args, ' ')
    local data = { pid = pid, x = coords.x, y = coords.y, z = coords.z, action = msg, color = { r = 0, g = 255, b = 0, a = 255 }, time = 30 }

    if msg == '' then
        ESX.ShowNotification('~r~Invalid Action!')
    else
        table.insert(actions, data)
    end
end)

RegisterNetEvent('staticAction:client:ractionCommand')
AddEventHandler('staticAction:client:ractionCommand', function(action)
    table.remove(actions, action)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k, v in pairs(actions) do
            Draw3DText(v.x, v.y, v.z, v.action, v.color)
        end
    end
end)

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(1000)

        for k, v in pairs(actions) do

            if v.time == 30 then
                v.color = { r = 0, g = 255, b = 0, a = 255 }
            elseif v.time == 20 then
                v.color = { r = 255, g = 255, b = 0, a = 255 }
            elseif v.time == 10 then
                v.color = { r = 255, g = 00, b = 0, a = 255 }
            elseif v.time == 0 then
                table.remove(actions, k)
            end

            v.time = v.time - 1
        end
    end
end)
