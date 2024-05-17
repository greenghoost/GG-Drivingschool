local QBCore = exports['qb-core']:GetCoreObject() 

Config = {}

Config.Framework = 'qb-core'    -- your framework name here
Config.Inventory = 'qb'         -- your inventory script here 'qb' - for 'qb-inventory' | 'ox' - for'ox_inventory'
Config.Target = 'qb'            -- your target script name here 'qb' - for 'qb-target' | 'ox' - for 'ox_target'

Config.startingped = vector4(240.38, -1379.77, 33.74, 140.28)
Config.MaxErrors       = 5
Config.SpeedMultiplier =  3.6

Config.SpeedLimits = {
	residence = 50,
	town      = 80,
	freeway   = 120
}

Config.Vehicles = 'blista'
Config.FuelScript = 'LegacyFuel'
Config.TestCost = 1000

Config.Zones = {
	DMVSchool = {
		Pos   = {x = 237.28, y = -1383.67, z = 33.03}
	},
}

Config.CheckPoints = {

	{
		Pos = {x = 255.139, y = -1400.731, z = 29.537},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			QBCore.Functions.Notify('Next Point Speed - '..Config.SpeedLimits['residence'].." ", "success", 2500)
		end
	},

	{
		Pos = {x = 271.874, y = -1370.574, z = 30.932},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			QBCore.Functions.Notify('Go to Next Point', "success", 2500)
		end
	},

	{
		Pos = {x = 234.907, y = -1345.385, z = 29.542},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			Citizen.CreateThread(function()
				--DrawMissionText('stop_for_ped', 2500)
				QBCore.Functions.Notify('Stop For Ped', "error", 2500)
				PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
				FreezeEntityPosition(vehicle, true)
				Citizen.Wait(4000)
				FreezeEntityPosition(vehicle, false)
				QBCore.Functions.Notify('good lets continue', "success", 2500)
			end)
		end
	},

	{
		Pos = {x = 217.821, y = -1410.520, z = 28.292},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			setCurrentZoneType('town')

			Citizen.CreateThread(function()
				--DrawMissionText('stop_look_left', Config.SpeedLimits['town'], 2500)
				QBCore.Functions.Notify("Stop Look Left - "..Config.SpeedLimits['town'].." ", "error", 2500)
				PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
				FreezeEntityPosition(vehicle, true)
				Citizen.Wait(6000)

				FreezeEntityPosition(vehicle, false)
				--DrawMissionText('good_turn_right', 2500)
				QBCore.Functions.Notify('Good Turn Right', "success", 2500)
			end)
		end
	},

	{
		Pos = {x = 178.550, y = -1401.755, z = 27.725},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			--DrawMissionText('watch_traffic_lightson', 2500)
			QBCore.Functions.Notify('Watch Traffic Light Son', "error", 2500)
		end
	},

	{
		Pos = {x = 113.160, y = -1365.276, z = 27.725},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			--DrawMissionText('go_next_point', 2500)
			QBCore.Functions.Notify('Go To Next Point', "success", 2500)
		end
	},

	{
		Pos = {x = -73.542, y = -1364.335, z = 27.789},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			--DrawMissionText('stop_for_passing', 2500)
			QBCore.Functions.Notify('Stop For Passing', "error", 2500)
			PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
			FreezeEntityPosition(vehicle, true)
			Citizen.Wait(6000)
			FreezeEntityPosition(vehicle, false)
		end
	},

	{
		Pos = {x = -355.143, y = -1420.282, z = 27.868},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			--DrawMissionText('go_next_point', 2500)
			QBCore.Functions.Notify('Go To Next Point', "success", 2500)
		end
	},

	{
		Pos = {x = -439.148, y = -1417.100, z = 27.704},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			--DrawMissionText('go_next_point', 2500)
			QBCore.Functions.Notify('Go To Next Point', "success", 2500)
		end
	},

	{
		Pos = {x = -453.790, y = -1444.726, z = 27.665},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			setCurrentZoneType('freeway')

			--DrawMissionText('hway_time', Config.SpeedLimits['freeway'], 2500)
			QBCore.Functions.Notify("Free way time - "..Config.SpeedLimits['freeway'].." ", "error", 2500)
			PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
		end
	},

	{
		Pos = {x = -463.237, y = -1592.178, z = 37.519},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			--DrawMissionText('go_next_point', 2500)
			QBCore.Functions.Notify('Go To Next Point', "success", 2500)
		end
	},

	{
		Pos = {x = -900.647, y = -1986.28, z = 26.109},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			--DrawMissionText('go_next_point', 2500)
			QBCore.Functions.Notify('Go To Next Point', "success", 2500)
		end
	},

	{
		Pos = {x = 1225.759, y = -1948.792, z = 38.718},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			--DrawMissionText('go_next_point', 2500)
			QBCore.Functions.Notify('Go To Next Point', "success", 2500)
		end
	},

	{
		Pos = {x = 1225.759, y = -1948.792, z = 38.718},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			setCurrentZoneType('town')
			--DrawMissionText('in_town_speed', Config.SpeedLimits['town'], 2500)
			QBCore.Functions.Notify("In Town Speed - "..Config.SpeedLimits['town'].." ", "error", 2500)
		end
	},

	{
		Pos = {x = 1163.603, y = -1841.771, z = 35.679},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			--DrawMissionText('gratz_stay_alert', 2500)
			QBCore.Functions.Notify('Stay Alert', "error", 2500)
			PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
		end
	},

	{
		Pos = {x = 235.283, y = -1398.329, z = 28.921},
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DeleteVehicle(vehicle)
		end
	}

}