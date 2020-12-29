-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

RSCore = nil
TriggerEvent('RSCore:GetObject', function(obj) RSCore = obj end)

-- Get & Apply Player Lab ID:
RegisterServerEvent('t1ger_drugbusiness:getPlyLabs')
AddEventHandler('t1ger_drugbusiness:getPlyLabs', function()
    local xPlayer =  RSCore.Functions.GetPlayer(source)
 
    exports['ghmattimysql']:execute("SELECT `labID` FROM `t1ger_druglabs` WHERE `identifier` = '"..xPlayer.PlayerData.citizenid.."'", function(data)
        local labID = 0
        if data[1] ~= nil then
            labID = data[1].labID
        end
        TriggerClientEvent('t1ger_drugbusiness:applyPlyLabID', xPlayer.PlayerData.source, labID)
    end)
end)

-- STEAL SUPPLIES:
RegisterServerEvent('t1ger_drugbusiness:JobDataSV')
AddEventHandler('t1ger_drugbusiness:JobDataSV',function(data)
    TriggerClientEvent('t1ger_drugbusiness:JobDataCL',-1,data)
end)

-- SELL STOCK:
RegisterServerEvent('t1ger_drugbusiness:SellJobDataSV')
AddEventHandler('t1ger_drugbusiness:SellJobDataSV',function(data)
    TriggerClientEvent('t1ger_drugbusiness:SellJobDataCL',-1,data)
end)

-- Remove Stock:
RegisterServerEvent('t1ger_drugbusiness:removeStock')
AddEventHandler('t1ger_drugbusiness:removeStock',function(plyLabID, stockLevel)
    exports['ghmattimysql']:execute( "SELECT `stock` FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'", function(data)
        if data[1].stock ~= nil then
            local stock = data[1].stock
            exports['ghmattimysql']:execute( "UPDATE `t1ger_druglabs` SET `stock` = 0 WHERE `labID` = '"..plyLabID.."'")
        end
    end)
end)

-- Get Purchased Labs:
RSCore.Functions.CreateCallback('t1ger_drugbusiness:getTakenLabs',function(source, cb)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
    local takenLabs = {}
    exports['ghmattimysql']:execute("SELECT `labID` FROM `t1ger_druglabs`", function(data)
        for k,v in pairs(data) do
            table.insert(takenLabs,{id = v.labID})
        end
        cb(takenLabs)
    end)
end)

-- Purchase Drug Lab:
 RSCore.Functions.CreateCallback('t1ger_drugbusiness:buyDrugLab',function(source, cb, id, val)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
    local money = 0
    if Config.PayDrugLabWithCash then
        money = xPlayer.PlayerData.money.cash
    else
        money = xPlayer.PlayerData.money.bank
    end
	if money >= val.price then
		if Config.PayDrugLabWithCash then
			xPlayer.Functions.RemoveMoney("cash",val.price)
		else
			xPlayer.Functions.RemoveMoney("bank", val.price)
		end
        exports['ghmattimysql']:execute("INSERT INTO t1ger_druglabs (identifier, labID) VALUES (@identifier, @labID)", {['identifier'] = xPlayer.PlayerData.steam, ['labID'] = id})      
        cb(true)
    else
        cb(false)
    end
end)

-- Sell Drug Lab:
 RSCore.Functions.CreateCallback('t1ger_drugbusiness:sellDrugLab',function(source, cb, id, val, sellPrice)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute( "SELECT `labID` FROM `t1ger_druglabs` WHERE `identifier` = '"..xPlayer.PlayerData.citizenid.."'", function(data)
        if data[1].labID ~= nil then 
            if data[1].labID == id then
                exports['ghmattimysql']:execute( "DELETE FROM `t1ger_druglabs` WHERE `labID` = '"..id.."'")
                if Config.RecieveSoldLabCash then
                    xPlayer.Functions.AddMoney("cash",sellPrice)
                else
                    xPlayer.Functions.AddMoney('bank',sellPrice)
                end
                cb(true)
            else
                cb(false)
            end
        end
    end)
end)

-- Get Supplies:
 RSCore.Functions.CreateCallback('t1ger_drugbusiness:getSupplies',function(source, cb, plyLabID)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT `supplies` FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(data)
        if data[1].supplies ~= nil then
            local supplies = data[1].supplies
            cb(supplies)
        else
            cb(nil)
        end
    end)
end)

-- Get Stock:
 RSCore.Functions.CreateCallback('t1ger_drugbusiness:getStock',function(source, cb, plyLabID)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT `stock` FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(data)
        if data[1].stock ~= nil then
            local stock = data[1].stock
            cb(stock)
        else
            cb(nil)
        end
    end)
end)

-- Buy Supplies:
 RSCore.Functions.CreateCallback('t1ger_drugbusiness:buySupplies',function(source, cb, plyLabID)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute( "SELECT `supplies` FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(data)
        if data[1].supplies ~= nil then
            local supplies = data[1].supplies
            if supplies < 5 then
                local maxSupplies = (5 - supplies) 
                local priceSupplyLevel = (maxSupplies * Config.SupplyLevelPrice)
                local money = xPlayer.PlayerData.money.bank
                if money >= priceSupplyLevel then
                    xPlayer.Functions.RemoveMoney('bank', priceSupplyLevel)
                    TriggerClientEvent('t1ger_drugbusiness:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['supplies_purchased']:format(maxSupplies,priceSupplyLevel)))
                    -- UPDATE DATABASE:

                    exports['ghmattimysql']:execute("UPDATE `t1ger_druglabs` SET `supplies` = 5 WHERE `labID` = '"..plyLabID.."'")
                    cb(true)
                else
                    cb(false)
                end
            else
                cb(nil)
            end
        end
    end)
end)

-- Alert on raid/robbery
RegisterServerEvent('t1ger_drugbusiness:alertLabOwner')
AddEventHandler('t1ger_drugbusiness:alertLabOwner', function(plyLabID, type)
    local target = nil
    exports['ghmattimysql']:execute("SELECT `identifier` FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(data)
        if data[1] ~= nil then
            local  targetIdentifier = data[1].identifier
            Wait(200)
            target =  RSCore.Functions.GetPlayer(targetIdentifier)
            if type == "police" then
                TriggerClientEvent('t1ger_drugbusiness:ShowNotifyESX', target.PlayerData.source, Lang['lab_raid_on_going'])
            elseif type == "player" then
                TriggerClientEvent('t1ger_drugbusiness:ShowNotifyESX', target.PlayerData.source, Lang['lab_robbery_in_progress'])
            end
        else
            print("error [t1ger_drugbusiness:alertLabOwner]")
        end
    end)
end)

-- Seize Supplies and Stock
RegisterServerEvent('t1ger_drugbusiness:seizeStockSupplies')
AddEventHandler('t1ger_drugbusiness:seizeStockSupplies', function(plyLabID)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
  
    -- GET TARGET PLAYER:
    local target = nil
    exports['ghmattimysql']:execute("SELECT `identifier` FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(user)
        print(user[1].identifier)
        if user[1].identifier ~= nil then
            local  targetIdentifier = user[1].identifier
            Wait(200)
            target =  RSCore.Functions.GetPlayerByCitizenId(targetIdentifier)
            if target ~= nil then
                print("ID recived "..tostring(target))
                exports['ghmattimysql']:execute("SELECT * FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(data)
                    if data[1] ~= nil then
                        exports['ghmattimysql']:execute("UPDATE `t1ger_druglabs` SET `supplies` = 0, `stock` = 0 WHERE `labID` = '"..plyLabID.."'")
                    end
                end)
            else
                if Config.RaidLabWhenPlayerOffline then
                    exports['ghmattimysql']:execute("SELECT * FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(data)
                        if data[1] ~= nil then
                            exports['ghmattimysql']:execute("UPDATE `t1ger_druglabs` SET `supplies` = 0, `stock` = 0 WHERE `labID` = '"..plyLabID.."'")
                        end
                    end)
                else
                    print("player offline [t1ger_drugbusiness:seizeStockSupplies]")
                end
            end
        else
            print("error [t1ger_drugbusiness:seizeStockSupplies]")
        end
    end)
end)

-- Rob Supplies and Stock
RegisterServerEvent('t1ger_drugbusiness:robStockSupplies')
AddEventHandler('t1ger_drugbusiness:robStockSupplies', function(targetID, plyLabID)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
    -- GET TARGET PLAYER:
    local target = nil
    exports['ghmattimysql']:execute("SELECT identifier FROM t1ger_druglabs WHERE labID = '"..targetID.."'",function(user)
        local  targetIdentifier = user[1].identifier
        Wait(200)
        target =   RSCore.Functions.GetPlayerByCitizenId(targetIdentifier)
        if target ~= nil then
            local stock = 0
            local supplies = 0            
            exports['ghmattimysql']:execute("SELECT * FROM `t1ger_druglabs` WHERE `labID` = '"..targetID.."'", function(data)
                if data[1] ~= nil then
                    stock = data[1].stock
                    supplies = data[1].supplies
                    exports['ghmattimysql']:execute("UPDATE `t1ger_druglabs` SET `supplies` = 0, `stock` = 0 WHERE `labID` = '"..targetID.."'")
                end
                exports['ghmattimysql']:execute("SELECT * FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(newData)
                    if newData[1] ~= nil then
                        local newStock = 0
                        local newSupplies = 0
                        if (newData[1].stock + stock) >= 5 then
                            newStock = 5
                        else
                            newStock = newData[1].stock + stock
                        end
                        if (newData[1].supplies + supplies) >= 5 then
                            newSupplies = 5
                        else
                            newSupplies = newData[1].supplies + supplies
                        end
                        exports['ghmattimysql']:execute("UPDATE `t1ger_druglabs` SET `supplies` = '"..newSupplies.."',`stock` = '"..newStock.."' WHERE `labID` = '"..plyLabID.."'")
                    end
                end)
            end)
        else
            if Config.RobLabWhenPlayerOffline then 
                local stock = 0
                local supplies = 0            
                exports['ghmattimysql']:execute("SELECT * FROM `t1ger_druglabs` WHERE `labID` = '"..targetID.."'", function(data)
                    if data[1] ~= nil then
                        stock = data[1].stock
                        supplies = data[1].supplies
                        exports['ghmattimysql']:execute("UPDATE `t1ger_druglabs` SET `supplies` = 0, `stock` = 0 WHERE `labID` = '"..targetID.."'")
                    end
                    exports['ghmattimysql']:execute("SELECT * FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(newData)
                        if newData[1] ~= nil then
                            local newStock = 0
                            local newSupplies = 0
                            if (newData[1].stock + stock) >= 5 then
                                newStock = 5
                            else
                                newStock = newData[1].stock + stock
                            end
                            if (newData[1].supplies + supplies) >= 5 then
                                newSupplies = 5
                            else
                                newSupplies = newData[1].supplies + supplies
                            end
                            exports['ghmattimysql']:execute("UPDATE `t1ger_druglabs` SET `supplies` = '"..newSupplies.."',`stock` = '"..newStock.."' WHERE `labID` = '"..plyLabID.."'")
                        end
                    end)
                end)
            else
                print("player not online [t1ger_drugbusiness:robStockSupplies]")
            end
        end
    end)
end)

-- Convert Supplies to Stock
RegisterServerEvent('t1ger_drugbusiness:suppliesToStock')
AddEventHandler('t1ger_drugbusiness:suppliesToStock', function(plyLabID)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT * FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(data)
        if data[1] ~= nil then
            local supplies = data[1].supplies
            local stock = data[1].stock
            if supplies > 0 and stock < 5 then
                supplies = supplies - 1
                stock = stock + 1
                exports['ghmattimysql']:execute("UPDATE `t1ger_druglabs` SET `supplies` = '"..supplies.."',`stock` = '"..stock.."' WHERE `labID` = '"..plyLabID.."'")
            else
                if stock >= 5 then
                elseif supplies <= 0 then
                end
            end
        end
    end)
end)

-- Police Notification:
RegisterServerEvent('t1ger_drugbusiness:PoliceNotifySV')
AddEventHandler('t1ger_drugbusiness:PoliceNotifySV', function(targetCoords, streetName)
	TriggerClientEvent('t1ger_drugbusiness:PoliceNotifyCL', -1,string.format((Lang['police_notify']:format(streetName))))
	TriggerClientEvent('t1ger_drugbusiness:PoliceNotifyBlip', -1, targetCoords)
end)

-- Job Reward:
RegisterServerEvent('t1ger_drugbusiness:jobReward')
AddEventHandler('t1ger_drugbusiness:jobReward',function(plyLabID)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT `supplies` FROM `t1ger_druglabs` WHERE `labID` = '"..plyLabID.."'",function(data)
        if data[1] ~= nil then
            -- Get Current Supplies:
            local supplies = data[1].supplies
            -- Check Supplies
            if supplies < 5 then
                -- Add Supplies Level:
                supplies = supplies + 1
                -- UPDATE DATABASE:
                exports['ghmattimysql']:execute("UPDATE `t1ger_druglabs` SET `supplies` = '"..supplies.."' WHERE `labID` = '"..plyLabID.."'")
            end
        end
    end)
end)

-- Stock Sale:
RegisterServerEvent('t1ger_drugbusiness:stockSaleSV')
AddEventHandler('t1ger_drugbusiness:stockSaleSV',function(plyLabID, stockLevel, stockValue)
    local xPlayer =  RSCore.Functions.GetPlayer(source)
    xPlayer.Functions.AddMoney("cash",stockValue)
    TriggerClientEvent('t1ger_drugbusiness:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['stock_sold_success']:format(stockValue)))
end)
