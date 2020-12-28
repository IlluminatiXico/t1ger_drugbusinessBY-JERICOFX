-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {}

-- Police Settings:
Config.PoliceJobs = {"police", "lspd"}	-- Jobs that can't do bankrobberies etc, but can secure the banks.
Config.NotifyCops = true				-- Notify police when stealing job vehicle

-- Alert Blip
Config.AlertBlipShow = true			-- enable or disable blip on map on police notify
Config.AlertBlipTime = 20			-- miliseconds that blip is active on map (this value is multiplied with 4 in the script)
Config.AlertBlipRadius = 50.0		-- set radius of the police notify blip
Config.AlertBlipAlpha = 250			-- set alpha of the blip
Config.AlertBlipColor = 3			-- set blip color

-- Marker settings for ALL drug labs:
Config.MarkerSettings = {
	enable = true,
	drawDist = 10.0,
	type = 20,
	scale = {x = 0.7, y = 0.7, z = 0.7},
	color = {r = 240, g = 52, b = 52, a = 100}
}

-- Blip Settings for drug labs:
Config.BlipSettings = {
	enable = true,
	sprite = 492,
	display = 4,
	scale = 0.65,
	color = 0
} 

-- Buttons:
Config.KeyToManageLab			= 38		-- Default: [E]
Config.KeyToPurchaseLab			= 38		-- Default: [E]
Config.KeyToRobLab				= 38		-- Default: [E]
Config.KeyToRaidLab				= 38		-- Default: [E]
Config.KeyToLaptop				= 47 		-- Default: [G]
Config.KeyToLeaveLab			= 38		-- Default: [E]
Config.KeyToDeliverStockVeh		= 38		-- Default: [E]
Config.KeyToLockpickJobVeh		= 47 		-- Default: [G]
Config.KeyToDeliverJobVeh		= 38		-- Default: [E]

-- General Settings:
Config.PayDrugLabWithCash 		= true		-- Set to false to use bank money instead
Config.RecieveSoldLabCash       = true      -- Set to false to receive bank money on sale of drug lab
Config.OwnedLabBlip 			= true		-- Blip for owned lab (source player)
Config.PlayerLabsBlip 		    = true		-- Blip to view other players' owned labs
Config.PurchasableLabBlip 	    = true		-- Blip to show labs forsale
Config.SellPercent              = 0.75      -- Means player gets 75% in return from original paid price
Config.SupplyLevelPrice			= 15000		-- Set price to purchase one level of supplies in drug lab
Config.StockLevelPrice			= 30000		-- Set sell price for each level of stuck in drug lab
Config.ProductionMinutes		= 10		-- Set value in minutes for interval of producing one level of supplies into one level of stock.
Config.SellMultiplier = { 1.0, 1.1, 1.2, 1.3, 1.5 } -- set stovk value multiplier for each level of stock upon sale

-- Robbery Settings:
Config.RobLabWhenPlayerOffline	= true		-- Set to false to disable robbing a drug lab where owner of the lab is offline.
Config.WaitTimeUntilHack 		= 10		-- Set time in seconds, until hacking device is ready. This is time the owner of lab has to react on it an take down possible intruders.
Config.mHackingBlocks			= 3			-- Set amount of hacking blocks in mhacking
Config.mHackingSeconds			= 30		-- Set amount of seconds for mHacking minigame

-- Police Settings:
Config.RaidLabWhenPlayerOffline	= true		-- Set to false to disable police raiding a drug lab where owner of the lab is offline.
Config.WaitTimeUntilRaid		= 10		-- Set time in seconds, until police enter the lab. This is time the owner of lab has to react on it an take down possible police.

-- Defined shell props // do not touch this if you dont know what u are doing
Config.ShellProps = {
	['lab_coke'] = `shell_coke2`,
	['lab_meth'] = `shell_meth`,
	['lab_weed'] = `shell_weed2`,
}

-- Labs:
Config.DrugLabs = {
    [1] = { pos = {-1463.08,-381.48,38.87}, h = 45.87, prop = 'lab_meth', price = 15000, delivery = {-1457.22,-383.84,38.48,120.0} },
    [2] = { pos = {-1453.27,-387.31,38.19}, h = 212.3, prop = 'lab_coke', price = 20000, delivery = {-1457.22,-383.84,38.48,120.0} },
    [3] = { pos = {-1468.15,-387.05,38.81}, h = 48.29, prop = 'lab_weed', price = 10000, delivery = {-1464.83,-389.52,38.56,132.12} },
}

-- Offset spots relative to the spawned shell object. Do not mess with this, if you don't know what u are doing.
-- Read more about offsets here: https://runtime.fivem.net/doc/natives/?_0x1899F328B0E12848
Config.Offsets = {
	['lab_coke'] = { entry = {-6.25, 8.42, -1.0},  h = 180.81, laptop = {-8.61, -0.93, -1.0}, animPos = {-8.0, -0.93, -1.0}, animHead = 88.4 },
	['lab_meth'] = { entry = {-6.25, 8.42, -1.0},  h = 180.81, laptop = {-8.59, 1.50, -1.0}, animPos = {-8.0, 1.60, -1.0}, animHead = 91.62 },
	['lab_weed'] = { entry = {17.59, 11.75, -2.0}, h = 89.85,  laptop = {-3.47, -3.88, -1.0}, animPos = {-3.97, -3.88, -1.0}, animHead = 272.33 },
}

-- Job Vehicles:
Config.JobVehicles = { "rumpo2", "rumpo", "speedo", "pony", "burrito4", "burrito3" }
Config.StockSellVeh = 'mule3'

-- Job Delivery Marker Setting:
Config.DeliveryMarker = { enable = true, drawDist = 10.0, type = 27, scale = { x = 5.0, y = 5.0, z = 1.0 }, color = { r = 244, g = 208, b = 63, a = 100 } }

-- Steal Supplies:
Config.StealSupplies = {
	[1] = {
		location = {-1657.33,3083.83,31.12},
		heading = 138.36,
		anim = {pos = {-1656.47,3082.35,31.08}, h = 52.82},
		started = false,
		goons = {
			[1] = { pos = {-1653.32,3082.84,31.2}, 	h = 157.13, ped = 'G_M_Y_Lost_02', 		animDict = 'amb@world_human_cop_idles@female@base', 					animName = 'base', 				weapon = 'WEAPON_PISTOL', },
			[2] = { pos = {-1660.67,3087.39,31.18}, h = 172.6, 	ped = 'G_M_Y_MexGang_01', 	animDict = 'rcmme_amanda1', 											animName = 'stand_loop_cop', 	weapon = 'WEAPON_PISTOL', },
			[3] = { pos = {-1653.54,3088.9,31.4}, 	h = 162.59, ped = 'G_M_Y_SalvaBoss_01', animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base', 	animName = 'base', 				weapon = 'WEAPON_PISTOL', },
		},
	},
	[2] = {
		location = {-1576.35,5169.86,19.58},
		heading = 155.36,
		anim = {pos = {-1574.97,5168.63,19.57}, h = 58.56},
		started = false,
		goons = {
			[1] = { pos = {-1578.98,5173.11,19.57}, h = 146.12, ped = 'G_M_Y_Lost_02', 		animDict = 'amb@world_human_cop_idles@female@base', 					animName = 'base', 				weapon = 'WEAPON_HEAVYPISTOL', },
			[2] = { pos = {-1571.95,5169.48,19.55}, h = 159.6, 	ped = 'G_M_Y_MexGang_01', 	animDict = 'rcmme_amanda1', 											animName = 'stand_loop_cop', 	weapon = 'WEAPON_MICROSMG', },
			[3] = { pos = {-1582.8,5172.02,19.56}, 	h = 197.48, ped = 'G_M_Y_SalvaBoss_01', animDict = 'amb@world_human_leaning@male@wall@back@legs_crossed@base', 	animName = 'base', 				weapon = 'WEAPON_MINISMG', },
		},
	},
}

Config.SellStock = {
	[1] = { 
		started = false,
		location = {2546.4,-279.8,92.99},
	},
	[2] = { 
		started = false,
		location = {2776.03,2809.02,41.51},
	},
}