RegisterNetEvent('staticAction:server:actionCommand')
AddEventHandler('staticAction:server:actionCommand', function(coords, args, name)
    TriggerClientEvent('staticAction:client:actionCommand', -1, coords, args, name)
end)

RegisterNetEvent('staticAction:server:ractionCommand')
AddEventHandler('staticAction:server:ractionCommand', function(source, args)
    TriggerClientEvent('staticAction:client:ractionCommand', -1, source, args)
end)
