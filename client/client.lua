-------------------------------------
------- Created by T1GER#9080 -------
-------------------------------------
RSCore = nil
insideShell = false
plyLabID    = 0
emptyLabs   = {}
playerloaded = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if insideShell then
			NetworkOverrideClockTime(23, 0, 0)
			ClearOverrideWeather()
			ClearWeatherTypePersist()
			SetWeatherTypePersist('EXTRASUNNY')
			SetWeatherTypeNow('EXTRASUNNY')
			SetWeatherTypeNowPersist('EXTRASUNNY')
			SetRainFxIntensity(0.0)
		end
	end
	
end)

RegisterNetEvent('RSCore:Client:OnPlayerLoaded')
AddEventHandler('RSCore:Client:OnPlayerLoaded', function()
playerloaded = true
Wait(2000)
	
end)

RegisterNetEvent('t1ger_drugbusiness:JobDataCL')
AddEventHandler('t1ger_drugbusiness:JobDataCL', function(data)
	Config.StealSupplies = data
end)

RegisterNetEvent('t1ger_drugbusiness:SellJobDataCL')
AddEventHandler('t1ger_drugbusiness:SellJobDataCL', function(data)
	Config.SellStock = data
end)

RegisterNetEvent('t1ger_drugbusiness:productionTime')
AddEventHandler('t1ger_drugbusiness:productionTime', function()
	local ownsLab = false
	if plyLabID ~= 0 then
		ownsLab = true
	else
		ownsLab = false
	end
	while ownsLab do
		Citizen.Wait((Config.ProductionMinutes * 1000 * 60))
		TriggerServerEvent('t1ger_drugbusiness:suppliesToStock', plyLabID)
	end
end)

-- Get Safe Spawn Pos for Shell:
function GetSafeSpawn(pos)
	local ObjectNearPoint = IsAnyObjectNearPoint(pos[1], pos[2], pos[3] - 30.0, 50.0, false)
	Wait(250)
	local spawnPos = { pos[1], pos[2], pos[3] - 30.0 }
	if ObjectNearPoint then
		while ObjectNearPoint do
			Citizen.Wait(1)
			spawnPos        = { (spawnPos[1] + 20.0), spawnPos[2], (spawnPos[3] - 30.0) }
			ObjectNearPoint = IsAnyObjectNearPoint(spawnPos[1], spawnPos[2], (spawnPos[3]), 35.0, false)
			if not ObjectNearPoint then
				break
			end
		end
		return spawnPos
	else
		return spawnPos
	end
end
RegisterNetEvent("t1ger_drugbusiness:getPlayerIden")
AddEventHandler("t1ger_drugbusiness:getPlayerIden", function()
	TriggerServerEvent("t1ger_drugbusiness:getPlyLabs")
end)
RegisterNetEvent('t1ger_drugbusiness:applyPlyLabID')
AddEventHandler('t1ger_drugbusiness:applyPlyLabID', function(labID)
	-- get player lab id:
	plyLabID = labID

	-- remove blips:
	for k, v in pairs(labBlips) do
		RemoveBlip(v)
	end

	-- get lab blips on map:
	RSCore.Functions.TriggerCallback('t1ger_drugbusiness:getTakenLabs', function(takenLabs)
		for k, v in pairs(takenLabs) do
			if v.id ~= plyLabID then
				emptyLabs[v.id] = v.id
			end
		end
		for k, v in pairs(Config.DrugLabs) do
			if plyLabID == k then
				if Config.OwnedLabBlip then
					CreateLabBlips(k, v, "Your Lab")
				end
			else
				if emptyLabs[k] == k then
					if Config.PlayerLabsBlip then
						CreateLabBlips(k, v, "Player Lab")
					end
				else
					if Config.PurchasableLabBlip then
						CreateLabBlips(k, v, "Purchasable Lab")
					end
				end
			end
		end
	end)
	Wait(1000)
	TriggerEvent('t1ger_drugbusiness:productionTime')
end)

hacking = false
labMenu = nil
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local player = GetPlayerPed(-1)
		local coords = GetEntityCoords(player)
		for k, v in pairs(Config.DrugLabs) do
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.pos[1], v.pos[2], v.pos[3], false)
			--if labMenu ~= nil then
				distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.pos[1], v.pos[2], v.pos[3], false)


			--else
				local mk = Config.MarkerSettings
				if distance <= 10.0 and distance >= 2.0 then
					if mk.enable then
						DrawMarker(mk.type, v.pos[1], v.pos[2], v.pos[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
					end
				elseif distance <= 2.0 then

					if plyLabID == k then
						DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], Lang['drug_lab_interact'])
						if IsControlJustPressed(0, Config.KeyToManageLab) then
							DrugLabManageMenu(k, v)
						end
					else
						if emptyLabs[k] == k then
							if isCop then
								DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], Lang['police_raid_lab'])
								if IsControlJustPressed(0, Config.KeyToRaidLab) then
									TriggerServerEvent('t1ger_drugbusiness:alertLabOwner', k, "police")
									RequestAnimDict("timetable@jimmy@doorknock@")

									TaskPlayAnim(player, "timetable@jimmy@doorknock@", "knockdoor_idle", 8.0, 8.0, -1, 4, 0, 0, 0, 0)
									RSCore.Functions.Progressbar("sell_pawn_items", Lang['prog_bar_raid_door'], 1000, false, true, {}, {}, {}, {}, function() -- Done

									end, function() -- Cancel
								
									end)
									Citizen.Wait((Config.WaitTimeUntilRaid * 1000))
									Wait(150)
									ClearPedTasks(player)
									SpawnDrugLab(k, v)
								end
							else
								if plyLabID ~= 0 then
									DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], Lang['drug_lab_rob'])
									if IsControlJustPressed(0, Config.KeyToRobLab) and not hacking then
										hacking = true
										GainAccessToLab(k, v)
									end
								else
									DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], Lang['lab_owned_player'])
								end
							end
						else
							if plyLabID == 0 then
								DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], (Lang['press_to_buy_lab']:format(math.floor(v.price))))
								if IsControlJustPressed(0, Config.KeyToPurchaseLab) then
									--labMenu = v
									OpenDrugLabBuyMenu(k, v)
								end
							else
								DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], Lang['only_own_one_lab'])
							end
						end
					end
				end
			--end
		end
	end
end)

robId  = nil
robVal = nil
function GainAccessToLab(id, val)
	local player = GetPlayerPed(-1)
	robId        = id
	robVal       = val
	SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
	Citizen.Wait(200)
	FreezeEntityPosition(player, true)
	TaskStartScenarioInPlace(player, 'WORLD_HUMAN_STAND_MOBILE', -1, true)
	TriggerServerEvent('t1ger_drugbusiness:alertLabOwner', id, "player")
	RSCore.Functions.Progressbar("sell_pawn_items", Lang['prog_bar_pre_hack'], (Config.WaitTimeUntilHack * 1000), false, true, {}, {}, {}, {}, function() -- Done

	end, function() -- Cancel

	end)
	--exports['progressBars']:startUI((), )
	Citizen.Wait((Config.WaitTimeUntilHack * 1000))
	TriggerEvent("mhacking:show")
	TriggerEvent("mhacking:start", Config.mHackingBlocks, Config.mHackingSeconds, hackingCallback)
end

function hackingCallback(success)
	local player = GetPlayerPed(-1)
	local coords = GetEntityCoords(player)
	TriggerEvent('mhacking:hide')
	if success then
		hacking = false
		ClearPedTasks(player)
		FreezeEntityPosition(player, false)
		SpawnDrugLab(robId, robVal)
	else
		ShowNotifyESX(Lang['lab_robbery_hack_fail'])
		hacking = false
		ClearPedTasks(player)
		FreezeEntityPosition(player, false)
	end
end

-- Purchase Drug Lab:
function OpenDrugLabBuyMenu(id, val)
	local playerPed = GetPlayerPed(-1)
	local elements  = {
		{ label = Lang['button_yes'], value = "confirm_purchase" },
		{ label = Lang['button_no'], value = "decline_purchase" },
	}

	local assert    = assert
	local menu      = assert(MenuV)

	local OpenDrug  = MenuV:CreateMenu("Confirm | Price: $" .. math.floor(val.price), '', 'center', 255, 0, 0, 'size-150')
	--local OpenDrug = MenuV:CreateMenu('Rename', '', 'topleft', 255, 0, 0, 'size-150')
	MenuV:OpenMenu(OpenDrug, function()
	end)

	for k, v in ipairs(elements) do
		local button = OpenDrug:AddButton({ icon = "🧑‍🔧 ", label = v.label, value = v, select = function(btn)
			local select = btn.Value.value
			if select == 'confirm_purchase' then
			
				Wait(100)
				RSCore.Functions.TriggerCallback('t1ger_drugbusiness:buyDrugLab', function(purchased)
					if purchased then
						ShowNotifyESX((Lang['drug_lab_purchased']):format(math.floor(val.price)))
						TriggerServerEvent('t1ger_drugbusiness:getPlyLabs')
					else
						ShowNotifyESX(Lang['not_enough_money'])
					end
				end, id, val)
			elseif select == "decline_purchase" then
				MenuV:CloseMenu(OpenDrug)
			end

		end })


	end


end

-- Manage Drug Lab Menu:
function DrugLabManageMenu(id, val)
	local playerPed  = GetPlayerPed(-1)
	local elements   = {
		{ label = Lang['enter_drug_lab'], value = "enter_drug_lab" },
		{ label = Lang['sell_drug_lab'], value = "sell_drug_lab" },
	}

	local assert     = assert
	local menu       = assert(MenuV)

	local LabManager = MenuV:CreateMenu("Drug Lab [" .. tostring(id) .. "]", '', 'center', 255, 0, 0, 'size-150')
	--local OpenDrug = MenuV:CreateMenu('Rename', '', 'topleft', 255, 0, 0, 'size-150')
	MenuV:OpenMenu(LabManager, function()
	end)

	for k, v in ipairs(elements) do
		local button = LabManager:AddButton({ icon = "🧑‍🔧 ", label = v.label, value = v, select = function(btn)
			local select = btn.Value.value
			if select == 'enter_drug_lab' then
				--   labMenu = nil
				SpawnDrugLab(id, val)
				MenuV:CloseMenu(LabManager)

			elseif select == "sell_drug_lab" then
				SellDrugLabMenu(id, val)
				MenuV:CloseMenu(LabManager)
			end

		end })
	end

end

	-- Sell Drug Lab:
function SellDrugLabMenu(id, val)
		local playerPed = GetPlayerPed(-1)
		local sellPrice = (val.price * Config.SellPercent)
		local elements  = {
			{ label = Lang['button_yes'], value = "confirm_sale" },
			{ label = Lang['button_no'], value = "decline_sale" },
		}

		local assert    = assert
		local menu      = assert(MenuV)

		local ShellDrug = MenuV:CreateMenu("Drug Lab [" .. tostring(id) .. "]", '', 'center', 255, 0, 0, 'size-150')
		--local ShellDrug = MenuV:CreateMenu('Rename', '', 'topleft', 255, 0, 0, 'size-150')
		MenuV:OpenMenu(ShellDrug, function()
		end)

		for k, v in ipairs(elements) do
			local button = ShellDrug:AddButton({ icon = "🧑‍🔧 ", label = v.label, value = v, select = function(btn)
				local select = btn.Value.value
				if (select == 'confirm_sale') then
					RSCore.Functions.TriggerCallback('t1ger_drugbusiness:sellDrugLab', function(sold)
						if sold then
							TriggerServerEvent('t1ger_drugbusiness:getPlyLabs')
							ShowNotifyESX((Lang['drug_lab_sold']):format(math.floor(sellPrice)))
						else
							ShowNotifyESX(Lang['not_your_drug_lab'])
						end
					end, id, val, math.floor(sellPrice))

				elseif select == "decline_sale" then
					ShellDrug:Close()

				end

			end })
		end

		inLaptop     = false
		inDruglab    = nil
		spawnedShell = nil
end

function SpawnDrugLab(id, val)

	print(id.." | "..tostring(val.pos))
			local player   = GetPlayerPed(-1)
			local coords   = GetEntityCoords(player)
			local shellPos = GetSafeSpawn(val.pos)
			-- exports['progressBars']:startUI((2000), "ENTERING DRUG LAB")
			RSCore.Functions.Progressbar("sell_pawn_items", "ENTERING DRUG LAB", 2000, false, true, {}, {}, {}, {}, function() -- Done

			end, function() -- Cancel
		
			end)
			Citizen.Wait(2000)
			-- Spawning the shell:
			local prop = Config.DrugLabs[id].prop

			RequestModel(Config.ShellProps[prop])
			--while not HasModelLoaded(Config.ShellProps[prop]) do
			--	Citizen.Wait(10)
			--end
	print("364")
			local shell = CreateObject(Config.ShellProps[prop], shellPos[1], shellPos[2], shellPos[3], false, false, false)

			FreezeEntityPosition(shell, true)
			Wait(100)
			-- Enter Shell:
			insideShell  = true
			spawnedShell = shell
			NetworkRegisterEntityAsNetworked(shell)
			local obj_net = ObjToNet(shell)
			SetNetworkIdExistsOnAllMachines(obj_net, true)
			NetworkSetNetworkIdDynamic(obj_net, true)
			Citizen.Trace(obj_net)
	print("377")
			-- Screen Fade Out:
			DoScreenFadeOut(1000)
		--[[ 	while not IsScreenFadedOut() do
				Wait(0)
			end ]]
			Citizen.Wait(500)
			-- Teleport Player:
			local offset = Config.Offsets[prop]
			local entry  = GetOffsetFromEntityInWorldCoords(shell, offset.entry[1], offset.entry[2], offset.entry[3])
			local laptop = nil
			if offset.laptop ~= nil then
				laptop = GetOffsetFromEntityInWorldCoords(shell, offset.laptop[1], offset.laptop[2], offset.laptop[3])
			end
			local laptopAnimPos = nil
			if offset.animPos ~= nil then
				laptopAnimPos = GetOffsetFromEntityInWorldCoords(shell, offset.animPos[1], offset.animPos[2], offset.animPos[3])
			end
			local laptopAnimHead = offset.animHead
			SetEntityCoords(player, entry[1], entry[2], entry[3])
			SetEntityHeading(player, offset.h)

			-- Screen Fade In:
			Citizen.Wait(500)
			DoScreenFadeIn(1000)

			-- Loop Inside Drug Lab:
			while insideShell do
				Citizen.Wait(10)
				local player = GetPlayerPed(-1)
				local coords = GetEntityCoords(player)

				-- laptop:
				if offset.laptop ~= nil then
					if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, laptop[1], laptop[2], laptop[3], false) <= 2.0 and  inLaptop == false then
						DrawText3Ds(laptop[1], laptop[2], laptop[3], Lang['press_to_use_laptop'])
						if IsControlJustPressed(0, Config.KeyToLaptop) and  inLaptop == false then
							inLaptop = true
							OpenLaptopFunction(laptopAnimPos, laptopAnimHead, id, val)
							inLaptop = false
						end
					end
					inLaptop = false
				end

				-- exit:
				local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, entry[1], entry[2], entry[3], false)
				if inDruglab ~= nil then
					distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, inDruglab[1], inDruglab[2], inDruglab[3], false)
					--while inDruglab ~= nil and distance > 2.0 do
					--	inDruglab = nil
					--	Citizen.Wait(1)
					--end

				else
					local mk = Config.MarkerSettings
					if distance <= 10.0 and distance >= 2.0 then
						DrawMarker(mk.type, entry[1], entry[2], entry[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
					elseif distance <= 2.0 then
						DrawText3Ds(entry[1], entry[2], entry[3], Lang['press_to_leave_lab'])
						if IsControlJustPressed(0, Config.KeyToLeaveLab) then
							inDruglab  = entry
							local exit = Config.DrugLabs[id].pos
							RSCore.Functions.Progressbar("sell_pawn_items", "LEAVING DRUG LAB", 2000, false, true, {}, {}, {}, {}, function() -- Done

							end, function() -- Cancel
						
							end)
							--   exports['progressBars']:startUI((2000), "LEAVING DRUG LAB")
							Citizen.Wait(2000)
							DoScreenFadeOut(800)
							--while not IsScreenFadedOut() do
							--	Wait(0)
							--end
							Wait(500)
							DeleteObject(spawnedShell)
							SetEntityCoords(player, exit[1], exit[2], exit[3] - 0.975)
							insideShell  = false
							spawnedShell = nil
							inDruglab    = nil
							Wait(500)
							DoScreenFadeIn(1250)
						end
					end
				end
			end
	end

function OpenLaptopFunction(pos, heading, id, val)
			local player   = GetPlayerPed(-1)
			local animDict = "mp_fbi_heist"
			local animName = "loop"
			RequestAnimDict(animDict)
			--[[ while not HasAnimDictLoaded(animDict) do
				Citizen.Wait(10)
			end ]]
			TaskPlayAnimAdvanced(player, animDict, animName, pos[1], pos[2], pos[3], 0.0, 0.0, heading, 3.0, 1.0, -1, 30, 1.0, 0, 0)
			--exports['progressBars']:startUI((2000), Lang['prog_bar_using_laptop'])
			RSCore.Functions.Progressbar("sell_pawn_items", Lang['prog_bar_using_laptop'], 2000, false, true, {}, {}, {}, {}, function() -- Done

			end, function() -- Cancel
		
			end)
			Citizen.Wait(2000)
			if isCop then
				OpenPoliceSeizeMenu(id, val)
			else
				if plyLabID ~= id then
					RobDrugLabMenu(id, val)
				else
					OpenLaptopMainMenu()
				end
			end
		end
function RobDrugLabMenu(id, val)
			local player = GetPlayerPed(-1)
			RSCore.Functions.TriggerCallback('t1ger_drugbusiness:getStock', function(stock)
				if stock ~= nil then
					Wait(100)
					RSCore.Functions.TriggerCallback('t1ger_drugbusiness:getSupplies', function(supplies)
						if supplies ~= nil then
							Wait(100)
							local elements    = {
								{ label = Lang['laptop_rob_lab'], value = "ply_seize_stuff" }
							}

							local assert      = assert
							local menu        = assert(MenuV)

							local RobDrugMenu = MenuV:CreateMenu("Drug Lab [" .. tostring(id) .. "]", '', 'center', 255, 0, 0, 'size-150')
							--local ShellDrug = MenuV:CreateMenu('Rename', '', 'topleft', 255, 0, 0, 'size-150')
							MenuV:OpenMenu(RobDrugMenu, function()
							end)
							for k, v in ipairs(elements) do
								local button = RobDrugMenu:AddButton({ icon = "🧑‍🔧 ", label = v.label, value = v, select = function(btn)
									local select = btn.Value.value
									if select == 'ply_seize_stuff' then

										--	exports['progressBars']:startUI(3000, Lang['prog_bar_transfer'])
										RSCore.Functions.Progressbar("sell_pawn_items", Lang['prog_bar_transfer'], 3000, false, true, {}, {}, {}, {}, function() -- Done

										end, function() -- Cancel
									
										end)
										TriggerServerEvent('t1ger_drugbusiness:robStockSupplies', id, plyLabID)
										Wait(3000)
										ShowNotifyESX(Lang['lab_robbery_done'])
										inLaptop = false
										ClearPedTasks(player)
									end

								end })

							end
						end
					end, id)
				end
			end, id)
		end

function OpenPoliceSeizeMenu(id, val)
			local player = GetPlayerPed(-1)

			RSCore.Functions.TriggerCallback('t1ger_drugbusiness:getStock', function(stock)
				if stock ~= nil then
					Wait(100)
					RSCore.Functions.TriggerCallback('t1ger_drugbusiness:getSupplies', function(supplies)
						if supplies ~= nil then
							Wait(100)
							local elements    = {
								{ label = (Lang['laptop_cur_supplies']:format(supplies)), value = "show_cur_supplies" },
								{ label = (Lang['laptop_cur_stock']:format(stock)), value = "show_cur_stock" },
								{ label = Lang['laptop_pol_seize'], value = "police_seize_stuff" },
							}
							local assert      = assert
							local menu        = assert(MenuV)

							local RobDrugMenu = MenuV:CreateMenu("Drug Lab [" .. tostring(id) .. "]", '', 'center', 255, 0, 0, 'size-150')

							MenuV:OpenMenu(RobDrugMenu, function()
							end)
							for k, v in ipairs(elements) do
								local button = RobDrugMenu:AddButton({ icon = "🧑‍🔧 ", label = v.label, value = v, select = function(btn)
									local select = btn.Value.value
									if select == 'police_seize_stuff' then
										--menu.close()
										--exports['progressBars']:startUI(1500, Lang['prog_bar_transfer'])
										RSCore.Functions.Progressbar("sell_pawn_items", Lang['prog_bar_transfer'], 1500, false, true, {}, {}, {}, {}, function() -- Done

										end, function() -- Cancel
									
										end)
										Wait(1500)
								
										TriggerServerEvent('t1ger_drugbusiness:seizeStockSupplies', id)
										inLaptop = false
										ClearPedTasks(player)
									end
								end })
							end
						end
					end, id)
				end
			end, id)
		end
function OpenLaptopMainMenu()
			local player     = GetPlayerPed(-1)

			local elements   = {
				{ label = Lang['laptop_supplies'], value = "supplies_menu" },
				{ label = Lang['laptop_stock'], value = "stock_menu" },
			}

			local assert     = assert
			local menu       = assert(MenuV)

			local OpenLaptop = MenuV:CreateMenu("Laptop", '', 'center', 255, 0, 0, 'size-150')

			MenuV:OpenMenu(OpenLaptop, function()
			end)

			for k, v in ipairs(elements) do
				local button = OpenLaptop:AddButton({ icon = "🧑‍🔧 ", label = v.label, value = v, select = function(btn)
					local select = btn.Value.value
					if select == 'supplies_menu' then
						--menu.close()
						OpenLaptopSuppliesMenu()
					end
					if select == 'stock_menu' then
						--menu.close()
						OpenLaptopStockMenu()
					end

				end })

			end

			stealingSupplies = false

		end
function OpenLaptopSuppliesMenu()
				local player        = GetPlayerPed(-1)
				local elements      = {
					{ label = Lang['laptop_check_supplies'], value = "check_supplies" },
					{ label = Lang['laptop_buy_supplies'], value = "buy_supplies" },
					{ label = Lang['laptop_steal_supplies'], value = "steal_supplies" },
				}

				local assert        = assert
				local menu          = assert(MenuV)

				local OpenLaptopsup = MenuV:CreateMenu("Lab Supplies", '', 'center', 255, 0, 0, 'size-150')
				--local OpenDrug = MenuV:CreateMenu('Rename', '', 'topleft', 255, 0, 0, 'size-150')
				MenuV:OpenMenu(OpenLaptopsup, function()
				end)

				for k, v in ipairs(elements) do
					local button = OpenLaptopsup:AddButton({ icon = "🧑‍🔧 ", label = v.label, value = v, select = function(btn)
						local select = btn.Value.value
						if select == 'check_supplies' then
							RSCore.Functions.TriggerCallback('t1ger_drugbusiness:getSupplies', function(supplies)
								if supplies ~= nil then
									ShowNotifyESX((Lang['supplies_level_msg']:format(supplies)))
								else
									print("error [OpenLaptopSuppliesMenu() in check_supplies]")
								end
							end, plyLabID)
						end
						if select == 'buy_supplies' then
							RSCore.Functions.TriggerCallback('t1ger_drugbusiness:buySupplies', function(payment)
								if payment ~= nil then
									if not payment then
										ShowNotifyESX(Lang['not_enough_money'])
									end
								else
									ShowNotifyESX(Lang['supplies_are_full'])
								end
							end, plyLabID)
							OpenLaptopMainMenu()
						end
						if select == 'steal_supplies' then
							if not stealingSupplies then
								RSCore.Functions.TriggerCallback('t1ger_drugbusiness:getSupplies', function(supplies)
									if supplies ~= nil then
										if supplies < 5 then
											local id    = math.random(1, #Config.StealSupplies)
											local curID = 0
											while Config.StealSupplies[id].started and curID < 100 do
												curID = curID + 1
												id    = math.random(1, #Config.StealSupplies)
											end
											if curID == 100 then
												ShowNotifyESX(Lang['no_jobs_available'])
											else
												stealingSupplies                 = true
												Config.StealSupplies[id].started = true
												Wait(200)
												TriggerServerEvent('t1ger_drugbusiness:JobDataSV', Config.StealSupplies)
												TriggerEvent('t1ger_drugbusiness:SuppliesJob', id)
												--
												inLaptop = false
												ClearPedTasks(player)
											end
										else
											ShowNotifyESX(Lang['supplies_are_full'])
										end
									else
										print("error [OpenLaptopSuppliesMenu() in steal_supplies]")
									end
								end, plyLabID)
							else
								ShowNotifyESX(Lang['already_in_job'])
							end
						end
					end })
				end
end
function OpenLaptopStockMenu()
					local player          = GetPlayerPed(-1)
					local elements        = {
						{ label = Lang['laptop_check_stock'], value = "check_stock" },
						{ label = Lang['laptop_sell_stock'], value = "sell_stock" },
					}
					local assert          = assert
					local menu            = assert(MenuV)

					local OpenLaptopstock = MenuV:CreateMenu("Lab Stock", '', 'center', 255, 0, 0, 'size-150')
					MenuV:OpenMenu(OpenLaptopstock, function()
					end)

					for k, v in ipairs(elements) do
						local button = OpenLaptopstock:AddButton({ icon = "🧑‍🔧 ", label = v.label, value = v, select = function(btn)
							local select = btn.Value.value
							if (select == 'check_stock') then
								RSCore.Functions.TriggerCallback('t1ger_drugbusiness:getStock', function(stock)
									if stock ~= nil then
										ShowNotifyESX((Lang['stock_level_msg']:format(stock)))
									else
										print("error [OpenLaptopStockMenu() in check_stock]")
									end
								end, plyLabID)
							end
							if select == 'sell_stock' then

								StockSellData()
							end
						end })
					end


function StockSellData()
						local player        = GetPlayerPed(-1)
						local stockLevel    = 0
						local multiplier    = 0
						local gotStock      = false
						local gotMultiplier = false
						-- Get Stock:
						RSCore.Functions.TriggerCallback('t1ger_drugbusiness:getStock', function(stock)
							if stock ~= nil then
								stockLevel = stock
								gotStock   = true
							end
						end, plyLabID)
						-- Get Stock Value:
						while not gotStock do
							Wait(10)
							if gotStock and not gotMultiplier then
								for k, v in pairs(Config.SellMultiplier) do
									if stockLevel == k then
										multiplier     = v
										multiplierData = true
										break
									end
								end
							end
						end

						local stockPrice = (Config.StockLevelPrice * stockLevel)
						local stockValue = math.floor(stockPrice * multiplier)

						--exports['progressBars']:startUI(1000, "Retrieving Data")
						RSCore.Functions.Progressbar("sell_pawn_items", "Retrieving Data", 1500, false, true, {}, {}, {}, {}, function() -- Done

						end, function() -- Cancel
					
						end)
						Wait(1000)
						OpenLaptopSellMenu(stockLevel, stockValue)
					end

					sellingStock = false

				end
function OpenLaptopSellMenu(stockLevel, stockValue)
						local player     = GetPlayerPed(-1)
						local elements   = {
							{ label = (Lang['laptop_stock_level']:format(stockLevel)), value = "info_stock_level" },
							{ label = (Lang['laptop_sell_price']:format(math.floor(stockValue))), value = "info_stock_sell_price" },
							{ label = Lang['laptop_find_buyer'], value = "sell_stock_job" },
							{ label = Lang['button_return'], value = "return_to_stock_menu" },
						}

						local assert     = assert
						local menu       = assert(MenuV)

						local OpenLaptop = MenuV:CreateMenu("Stock Info", '', 'center', 255, 0, 0, 'size-150')
						--local OpenDrug = MenuV:CreateMenu('Rename', '', 'topleft', 255, 0, 0, 'size-150')
						MenuV:OpenMenu(OpenLaptop, function()
						end)

						for k, v in ipairs(elements) do
							local button = OpenLaptop:AddButton({ icon = "🧑‍🔧 ", label = v.label, value = v, select = function(btn)
								local select = btn.Value.value
								if select == 'return_to_stock_menu' then

									OpenLaptopStockMenu()
								end
								if select == 'sell_stock_job' then
									if not sellingStock then
										if stockLevel > 0 then
											local id    = math.random(1, #Config.SellStock)
											local curID = 0
											while Config.SellStock[id].started and curID < 100 do
												curID = curID + 1
												id    = math.random(1, #Config.SellStock)
											end
											if curID == 100 then
												print(curID)
												ShowNotifyESX(Lang['no_available_buyers'])
											else
												sellingStock                 = true
												Config.SellStock[id].started = true
												Wait(200)
												TriggerServerEvent('t1ger_drugbusiness:SellJobDataSV', Config.SellStock)
												TriggerEvent('t1ger_drugbusiness:StockDelivery', id, stockLevel, stockValue)

												inLaptop = false
												ClearPedTasks(player)
											end
										else
											ShowNotifyESX(Lang['stock_is_empty'])
										end
									else
										ShowNotifyESX(Lang['already_selling_stock'])
									end
								end
							end })
						end

						endStockJob       = false
						stockVeh          = nil
						stockVehModel     = nil
						stockVehSpawned   = false
						stockVehDelivered = false
end

RegisterNetEvent('t1ger_drugbusiness:StockDelivery')
AddEventHandler('t1ger_drugbusiness:StockDelivery', function(id, stockLevel, stockValue)
	print("STOCKDELIVERY")
							local player                                                 = GetPlayerPed(-1)
							local soldStock                                              = false
							local num                                                    = Config.SellStock[id]
							local blip                                                   = CreateStockBlip(num.location)
							local vehBlip                                                = nil
							local stockTaken                                             = false
							local notifySound1, notifySound2, notifySound3, notifySound4 = false, false, false, false

							while not soldStock and not endStockJob do
								print("notsold "..tostring(soldStock))
								print("endtosck"..tostring(endStockJob))
								Citizen.Wait(1)

								if num.started then
									local insideVeh = false

									local coords    = GetEntityCoords(player)
									local distance  = GetDistanceBetweenCoords(coords, num.location[1], num.location[2], num.location[3], true)

									local startPos  = Config.DrugLabs[plyLabID].delivery

									-- Remove Stock:
									if not stockTaken then
										TriggerServerEvent('t1ger_drugbusiness:removeStock', plyLabID, stockLevel)
										stockTaken = true
									end

									-- Spawn Vehicle:
									if not stockVehSpawned then
										ClearAreaOfVehicles(startPos[1], startPos[2], startPos[3], 15.0, false, false, false, false, false)
										stockVehSpawned = true
										Citizen.Wait(200)
										stockVehModel = Config.StockSellVeh
										RSCore.Functions.SpawnVehicle(stockVehModel, function(veh)
											SetEntityCoordsNoOffset(veh, startPos[1], startPos[2], startPos[3])
											SetEntityHeading(veh, 120.0)
											FreezeEntityPosition(veh, true)
											SetVehicleOnGroundProperly(veh)
											FreezeEntityPosition(veh, false)
											SetEntityAsMissionEntity(stockVeh, true, true)
											stockVeh = veh
											SetVehicleDoorsLockedForAllPlayers(stockVeh, false)
										end,{ x = startPos[1], y = startPos[2], z = startPos[3] })
									end

									-- Check if player is in job vehicle:
									if not insideShell and stockVehSpawned and not stockVehDelivered then
										local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
										if GetEntityModel(vehicle) == GetHashKey(stockVehModel) then
											insideVeh = true
										else
											insideVeh = false
										end
									end

									-- Stock Vehicle Blip:
									if stockVehSpawned then
										if DoesEntityExist(stockVeh) then
											if not DoesBlipExist(vehBlip) and not insideVeh then
												vehBlip = AddBlipForEntity(stockVeh)
											end
											SetBlipSprite(vehBlip, 477)
											SetBlipColour(vehBlip, 3)
											SetBlipDisplay(vehBlip, 2)
											SetBlipScale(vehBlip, 0.65)
											BeginTextCommandSetBlipName("STRING")
											AddTextComponentString("Delivery Vehicle")
											EndTextCommandSetBlipName(vehBlip)
										elseif DoesBlipExist(vehBlip) or insideVeh then
											RemoveBlip(vehBlip)
										end
									end

									-- Check if Ply inside shell/drug-lab:
									if insideShell then
										DrawMissionText(Lang['leave_drug_lab'])
										if not notifySound1 then
											PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
											notifySound1 = true
										end
									end

									-- Mission Text:
									if not insideShell and stockVehSpawned and not insideVeh and not stockVehDelivered then
										DrawMissionText(Lang['get_in_vehicle'])
										if not notifySound2 then
											PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
											notifySound2 = true
										end
									end

									-- Mission Text:
									if not insideShell and insideVeh and not stockVehDelivered then
										DrawMissionText(Lang['deliver_stock_drop_off'])
										if not notifySound3 then
											PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
											notifySound3 = true
										end
									end

									if not stockVehDelivered then
										local coords         = GetEntityCoords(GetPlayerPed(-1))
										local vehicle        = GetVehiclePedIsIn(GetPlayerPed(-1), false)
										local distToDelivery = GetDistanceBetweenCoords(coords, num.location[1], num.location[2], num.location[3], true)
										local mk             = Config.DeliveryMarker
										if mk.enable then
											if distToDelivery <= mk.drawDist then
												DrawMarker(mk.type, num.location[1], num.location[2], num.location[3] - 0.965, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
											end
										end
										if distToDelivery <= 2.0 and not stockVehDelivered then
											DrawText3Ds(num.location[1], num.location[2], num.location[3], Lang['deliver_stock'])
											if IsControlJustPressed(0, Config.KeyToDeliverStockVeh) then
												if GetEntityModel(vehicle) == GetHashKey(stockVehModel) then
													stockVehDelivered = true
													RemoveBlip(blip)
													RemoveBlip(vehBlip)
													SetVehicleForwardSpeed(stockVeh, 0)
													SetVehicleEngineOn(stockVeh, false, false, true)
													if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
														TaskLeaveVehicle(GetPlayerPed(-1), stockVeh, 4160)
														SetVehicleDoorsLockedForAllPlayers(stockVeh, true)
													end
													Citizen.Wait(1000)
													FreezeEntityPosition(stockVeh, true)
													ShowNotifyESX("You ~g~successfully~s~ delivered the ~b~stock~s~")
													PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
													TriggerServerEvent('t1ger_drugbusiness:stockSaleSV', plyLabID, stockLevel, stockValue)
													endStockJob = true
												else
													ShowNotifyESX(Lang['veh_not_matching'])
												end
											end
										end
									end

									if endStockJob then
										-- delete & reset vehicle:
										DeleteVehicle(stockVeh)
										stockVehModel   = nil
										stockVeh        = nil
										stockVehSpawned = false
										Wait(100)
										-- delete and reset blip:
										if DoesBlipExist(blip) then
											RemoveBlip(blip)
											blip = nil
										elseif DoesBlipExist(vehBlip) then
											RemoveBlip(vehBlip)
											vehBlip = nil
										end
										Wait(100)
										Config.SellStock[id].started = false
										Wait(200)
										TriggerServerEvent('t1ger_drugbusiness:SellJobDataSV', Config.SellStock)
										stockVehDelivered = false
										startPos          = nil
										endStockJob       = false
										sellingStock      = false
										Wait(100)
										break
									end
								end
							end
						end)

						endSupplyJob    = false
						deliveryStage   = false
						vehModel        = nil
						jobVehSpawned   = false
						jobVeh          = nil
						goonSpawn       = false
						jobVehStolen    = false
						curStealing     = false
						jobVehDelivered = false
						endPos          = nil
						endBlip         = false

RegisterNetEvent('t1ger_drugbusiness:SuppliesJob')
AddEventHandler('t1ger_drugbusiness:SuppliesJob', function(id)
							local player                                                 = GetPlayerPed(-1)
							local goons                                                  = {}
							local gotSupplies                                            = false
							local job                                                    = Config.StealSupplies[id]
							local blip                                                   = CreateJobBlip(job.location)
							local notifySound1, notifySound2, notifySound3, notifySound4 = false, false, false, false

							while not gotSupplies and not endSupplyJob do
								Citizen.Wait(0)

								if job.started then
									local coords         = GetEntityCoords(player)
									local distance       = GetDistanceBetweenCoords(coords, job.location[1], job.location[2], job.location[3], true)

									local streetNameHash = GetStreetNameAtCoord(job.location[1], job.location[2], job.location[3])
									local nameStreet     = GetStreetNameFromHashKey(streetNameHash)

									if distance > 60 and not deliveryStage then
										print("60 metros")
										DrawMissionText((Lang['job_go_to_location']:format(nameStreet)))
										if not notifySound1 then
											PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
											notifySound1 = true
										end
									end

									if distance < 150 and not jobVehSpawned then
										print("150")
										ClearAreaOfVehicles(job.location[1], job.location[2], job.location[3], 15.0, false, false, false, false, false)
										jobVehSpawned = true
										Citizen.Wait(200)
										local num = math.random(1, #Config.JobVehicles)
										vehModel  = Config.JobVehicles[num]
										local coordinates =  {x = job.location[1], y = job.location[2], z = job.location[3] }
										print("VEHICULO A ESPAWNEAR")
										RSCore.Functions.SpawnVehicle(vehModel, function(veh)
											SetEntityCoordsNoOffset(veh, job.location[1], job.location[2], job.location[3])
											SetEntityHeading(veh, job.heading)
											FreezeEntityPosition(veh, true)
											SetVehicleOnGroundProperly(veh)
											FreezeEntityPosition(veh, false)
											SetEntityAsMissionEntity(jobVeh, true, true)
											jobVeh = veh
											SetVehicleDoorsLockedForAllPlayers(jobVeh, true)
										end,coordinates,true)
									end

									if distance < 150 and not goonSpawn then
										ClearAreaOfPeds(job.location[1], job.location[2], job.location[3], 50, 1)
										goonSpawn = true
										Citizen.Wait(200)
										SetPedRelationshipGroupHash(GetPlayerPed(-1), GetHashKey("PLAYER"))
										AddRelationshipGroup('JobNPCs')
										local i = 0
										for k, v in pairs(job.goons) do
											RequestModel(GetHashKey(v.ped))
											while not HasModelLoaded(GetHashKey(v.ped)) do
												Wait(1)
											end
											goons[i] = CreatePed(4, GetHashKey(v.ped), v.pos[1], v.pos[2], v.pos[3], v.h, false, true)
											NetworkRegisterEntityAsNetworked(goons[i])
											SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(goons[i]), true)
											SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(goons[i]), true)
											SetPedCanSwitchWeapon(goons[i], true)
											SetPedArmour(goons[i], 100)
											SetPedAccuracy(goons[i], 60)
											SetEntityInvincible(goons[i], false)
											SetEntityVisible(goons[i], true)
											SetEntityAsMissionEntity(goons[i])
											RequestAnimDict(v.animDict)
											while not HasAnimDictLoaded(v.animDict) do
												Citizen.Wait(0)
											end
											TaskPlayAnim(goons[i], v.animDict, v.anim, 8.0, -8, -1, 49, 0, 0, 0, 0)
											GiveWeaponToPed(goons[i], GetHashKey(v.weapon), 255, false, false)
											SetPedDropsWeaponsWhenDead(goons[i], false)
											SetPedFleeAttributes(goons[i], 0, false)
											SetPedRelationshipGroupHash(goons[i], GetHashKey("JobNPCs"))
											TaskGuardCurrentPosition(goons[i], 5.0, 5.0, 1)
											i = i + 1
										end
									end

									if distance < 60 and distance > 10 and not deliveryStage then
										DrawMissionText(Lang['take_out_the_goons'])
										if not notifySound2 then
											PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
											notifySound2 = true
										end
									end

									if distance < 60 and not job.JobPlayer then
										job.JobPlayer = true
										Wait(200)
										TriggerServerEvent('t1ger_drugs:JobDataSV', Config.Jobs)
										Citizen.Wait(200)
										SetPedRelationshipGroupHash(GetPlayerPed(-1), GetHashKey("PLAYER"))
										AddRelationshipGroup('JobNPCs')
										local i = 0
										for k, v in pairs(goons) do
											ClearPedTasksImmediately(goons[i])
											SetRelationshipBetweenGroups(0, GetHashKey("JobNPCs"), GetHashKey("JobNPCs"))
											SetRelationshipBetweenGroups(5, GetHashKey("JobNPCs"), GetHashKey("PLAYER"))
											SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("JobNPCs"))
											i = i + 1
										end
									end

									if not jobVehStolen and distance < 10 then
										DrawMissionText(Lang['steal_the_supplies'])
										if not notifySound3 then
											PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
											notifySound3 = true
										end
									end

									local jovVehPos = GetEntityCoords(jobVeh)
									local distToVeh = GetDistanceBetweenCoords(coords, jovVehPos.x, jovVehPos.y, jovVehPos.z, true)

									if distToVeh <= 2 and not jobVehStolen then
										DrawText3Ds(jovVehPos.x, jovVehPos.y, jovVehPos.z, Lang['press_to_steal'])
										if IsControlJustPressed(0, Config.KeyToLockpickJobVeh) and not curStealing then
											StealJobVehicle(job)
										end
									end

									if jobVehStolen and not jobVehDelivered then
										RemoveBlip(blip)
										if not endBlip then
											endBlip      = true
											endPos       = Config.DrugLabs[plyLabID].delivery
											DeliveryBlip = AddBlipForCoord(endPos[1], endPos[2], endPos[3])
											SetBlipColour(DeliveryBlip, 5)
											BeginTextCommandSetBlipName("STRING")
											AddTextComponentString("Delivery [Your Lab]")
											EndTextCommandSetBlipName(DeliveryBlip)
											SetBlipRoute(DeliveryBlip, true)
											SetBlipRouteColour(DeliveryBlip, 5)
										end
										deliveryStage = true
									end

									if deliveryStage and not jobVehDelivered then
										DrawMissionText(Lang['deliver_supplies_back'])
										if not notifySound4 then
											PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
											notifySound4 = true
										end
									end

									if deliveryStage then
										local coords         = GetEntityCoords(GetPlayerPed(-1))
										local vehicle        = GetVehiclePedIsIn(GetPlayerPed(-1), false)
										local distToDelivery = GetDistanceBetweenCoords(coords, endPos[1], endPos[2], endPos[3], true)
										local mk             = Config.DeliveryMarker
										if mk.enable then
											if distToDelivery <= mk.drawDist then
												DrawMarker(mk.type, endPos[1], endPos[2], endPos[3] - 0.965, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, mk.scale.x, mk.scale.y, mk.scale.z, mk.color.r, mk.color.g, mk.color.b, mk.color.a, false, true, 2, false, false, false, false)
											end
										end
										if distToDelivery <= 2.0 and not jobVehDelivered then
											DrawText3Ds(endPos[1], endPos[2], endPos[3], Lang['press_to_deliver'])
											if IsControlJustPressed(0, Config.KeyToDeliverJobVeh) then
												if GetEntityModel(vehicle) == GetHashKey(vehModel) then
													jobVehDelivered = true
													RemoveBlip(DeliveryBlip)
													SetVehicleForwardSpeed(jobVeh, 0)
													SetVehicleEngineOn(jobVeh, false, false, true)
													if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
														TaskLeaveVehicle(GetPlayerPed(-1), jobVeh, 4160)
														SetVehicleDoorsLockedForAllPlayers(jobVeh, true)
													end
													Citizen.Wait(1000)
													FreezeEntityPosition(jobVeh, true)
													deliveryStage = false
													ShowNotifyESX("You ~g~successfully~s~ delivered one level of ~b~supplies~s~")
													PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
													TriggerServerEvent('t1ger_drugbusiness:jobReward', plyLabID)
													endSupplyJob = true
												else
													ShowNotifyESX(Lang['veh_not_matching'])
												end
											end
										end
									end

									if endSupplyJob then
										-- delete & reset vehicle:
										DeleteVehicle(jobVeh)
										vehModel      = nil
										jobVeh        = nil
										jobVehSpawned = false
										jobVehStolen  = false
										Wait(100)
										-- delete and reset blip:
										if deliveryStage then
											if DeliveryBlip ~= nil then
												RemoveBlip(DeliveryBlip)
											end
										else
											if blip ~= nil then
												RemoveBlip(blip)
											end
										end
										Wait(100)
										-- delete and reset goons:
										local i = 0
										for k, v in pairs(job.goons) do
											if DoesEntityExist(goons[i]) then
												DeleteEntity(goons[i])
											end
											i = i + 1
										end
										Wait(100)
										Config.StealSupplies[id].started = false
										Wait(200)
										TriggerServerEvent('t1ger_drugbusiness:JobDataSV', Config.StealSupplies)
										goons            = {}
										goonSpawn        = false
										deliveryStage    = false
										curStealing      = false
										jobVehDelivered  = false
										endBlip          = false
										endPos           = nil
										endSupplyJob     = false
										stealingSupplies = false
										Wait(100)
										break
									end
								end
							end
						end)

						-- Steal Job Vehicle:
function StealJobVehicle(val)
							local player   = GetPlayerPed(-1)
							local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
							local animName = "machinic_loop_mechandplayer"
							RequestAnimDict(animDict)
							--while not HasAnimDictLoaded(animDict) do
							--	Citizen.Wait(10)
							--end

							if Config.NotifyCops then
								NotifyPoliceFunction()
							end

							SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
							Citizen.Wait(500)
							FreezeEntityPosition(player, true)
							TaskPlayAnimAdvanced(player, animDict, animName, val.anim.pos[1], val.anim.pos[2], val.anim.pos[3], 0.0, 0.0, val.anim.h, 3.0, 1.0, -1, 31, 0, 0, 0)
							RSCore.Functions.Progressbar("sell_pawn_items", Lang['progbar_stealing'], 5000, false, true, {}, {}, {}, {}, function() -- Done

							end, function() -- Cancel
						
							end)
							--exports['progressBars']:startUI(5000, Lang['progbar_stealing'])
							Citizen.Wait(5000)

							ClearPedTasks(player)
							FreezeEntityPosition(player, false)
							jobVehStolen = true
							curStealing  = false
							SetVehicleDoorsLockedForAllPlayers(jobVeh, false)
						end

						-- Function for job blip in progress:
function CreateJobBlip(pos)
							local blip = AddBlipForCoord(pos[1], pos[2], pos[3])
							SetBlipSprite(blip, 1)
							SetBlipColour(blip, 5)
							AddTextEntry('MYBLIP', "Steal Supplies")
							BeginTextCommandSetBlipName('MYBLIP')
							AddTextComponentSubstringPlayerName(name)
							EndTextCommandSetBlipName(blip)
							SetBlipScale(blip, 0.75) -- set scale
							SetBlipAsShortRange(blip, true)
							SetBlipRoute(blip, true)
							SetBlipRouteColour(blip, 5)
							return blip
						end

						-- Function for job blip in progress:
function CreateStockBlip(pos)
							local blip = AddBlipForCoord(pos[1], pos[2], pos[3])
							SetBlipSprite(blip, 1)
							SetBlipColour(blip, 5)
							AddTextEntry('MYBLIP', "Drug Trade")
							BeginTextCommandSetBlipName('MYBLIP')
							AddTextComponentSubstringPlayerName(name)
							EndTextCommandSetBlipName(blip)
							SetBlipDisplay(blip, 2)
							SetBlipScale(blip, 0.75) -- set scale
							SetBlipAsShortRange(blip, true)
							SetBlipRoute(blip, true)
							SetBlipRouteColour(blip, 5)
							return blip
						end
						
						
--[[  AddEventHandler(
	"onClientResourceStart",
	function(resourceName)
		if playerloaded then
		TriggerServerEvent("t1ger_drugbusiness:getPlyLabs")
		end
	end
) ]]
