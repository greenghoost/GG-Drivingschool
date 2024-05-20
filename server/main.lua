local QBCore = exports['qb-core']:GetCoreObject() 

lib.callback.register('gg-drivingschool:payment', function(source)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local bankamount = xPlayer.PlayerData.money["bank"]
    local amount = Config.TestCost

    if bankamount >= amount then
        xPlayer.Functions.RemoveMoney('bank', Config.TestCost)
        TriggerClientEvent('gg-drivingschool:paymentSuccess', src)
    else
        TriggerClientEvent('QBCore:Notify', src, "Not enough money", "error")
    end
end)


lib.callback.register('gg-drivingschool:server:GetLicense', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)


    local info = {}
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "A1-A2-A | AM-B | C1-C-CE"

    if Config.Inventory == 'qb' then
        Player.Functions.AddItem('driver_license', 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['driver_license'], 'add')
    elseif Config.Inventory == 'ox' then
        exports.ox_inventory:AddItem(src, 'driver_license', 1)
    end

end)
