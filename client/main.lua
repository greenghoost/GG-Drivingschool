local QBCore = exports['qb-core']:GetCoreObject()

local Licenses, CurrentAction, CurrentActionMsg, CurrentActionData = {}, nil, nil, nil
local CurrentTest, CurrentTestType, CurrentVehicle, CurrentCheckPoint, DriveErrors = nil, nil, nil, 0, 0
local LastCheckPoint, CurrentBlip, CurrentZoneType, IsAboveSpeedLimit, LastVehicleHealth = -1, nil, nil, false, nil

function StartTheoryTest()
	CurrentTest = 'theory'
	SendNUIMessage({ openQuestion = true })
	SetTimeout(200, function()
		SetNuiFocus(true, true)
	end)
end

function StopTheoryTest(success)
	CurrentTest = nil
	SendNUIMessage({ openQuestion = false })
	SetNuiFocus(false)
	if success then
		QBCore.Functions.Notify("Passed Theory Test, Start your practical test!", "success", 5000)
		StartDriveTest()
	else
		QBCore.Functions.Notify("Failed Theory Test", "error")
	end
end

function StartDriveTest()
	local coords = { x = 231.36, y = -1394.49, z = 30.5, h = 239.94 }
	local plate = "TSTDRIVE" .. math.random(1111, 9999)

	QBCore.Functions.SpawnVehicle(Config.Vehicles, function(vehicle)
		SetVehicleNumberPlateText(vehicle, plate)
		SetEntityHeading(vehicle, coords.h)

		if Config.FuelScript == 'ox_fuel' then
			Entity(vehicle).state.fuel = 100 -- Don't change this. Change it in the  Defaults to ox fuel if not set in the config
		else
			exports[Config.FuelScript]:SetFuel(vehicle, 100.0)
		end

		TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
		TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
		SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
		SetVehicleEngineOn(vehicle, true, true)
		SetVehicleDirtLevel(vehicle, 0)
		SetVehicleUndriveable(vehicle, false)
		WashDecalsFromVehicle(vehicle, 1.0)

		CurrentTest = 'drive'
		CurrentTestType = 'drive_test'
		CurrentCheckPoint, DriveErrors, IsAboveSpeedLimit = 0, 0, false
		CurrentVehicle, LastVehicleHealth = vehicle, GetEntityHealth(vehicle)
		CurrentZoneType, LastCheckPoint = 'residence', -1
	end, coords, true)
end

function StopDriveTest(success)
	if success then
		lib.callback.await('gg-drivingschool:server:GetLicense')
		QBCore.Functions.Notify("Passed Driving Test", "success")
	else
		QBCore.Functions.Notify("Failed Driving Test", "error")
	end
	CurrentTest, CurrentTestType = nil, nil
end

function SetCurrentZoneType(type)
	CurrentZoneType = type
end

RegisterNUICallback('question', function(data, cb)
	SendNUIMessage({ openSection = 'question' })
	cb()
end)

RegisterNUICallback('close', function(data, cb)
	StopTheoryTest(true)
	cb()
end)

RegisterNUICallback('kick', function(data, cb)
	StopTheoryTest(false)
	cb()
end)

-- Create Blips
CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z)
	SetBlipSprite(blip, 616)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 1.0)
	SetBlipColour(blip, 3)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Driving School')
	EndTextCommandSetBlipName(blip)
end)

-- Block UI during theory test
CreateThread(function()
	while true do
		if CurrentTest == 'theory' then
			local playerPed = PlayerPedId()
			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisablePlayerFiring(playerPed, true) -- Disable weapon firing
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			Wait(1)
		else
			Wait(500)
		end
	end
end)

RegisterNetEvent('drivingtest:start', function()
    local hasItem = false

    if Config.Inventory == 'ox' then
        local count = exports.ox_inventory:Search('count', 'driver_license')
        hasItem = count >= 1
    elseif Config.Inventory == 'qb' then
        hasItem = QBCore.Functions.HasItem('driver_license')
    end

    if hasItem then
        QBCore.Functions.Notify("You already have a license!", "error")
    else
        lib.callback.await('gg-drivingschool:payment')
    end
end)

RegisterNetEvent('gg-drivingschool:paymentSuccess', function()
    StartTheoryTest()
end)


-- Drive test checkpoints and completion
CreateThread(function()
	while true do
		if CurrentTest == 'drive' then
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			local nextCheckPoint = CurrentCheckPoint + 1

			if not Config.CheckPoints[nextCheckPoint] then
				if DoesBlipExist(CurrentBlip) then
					RemoveBlip(CurrentBlip)
				end
				CurrentTest = nil
				QBCore.Functions.Notify("Driving Test Complete", "error")
				StopDriveTest(DriveErrors < Config.MaxErrors)
			else
				if CurrentCheckPoint ~= LastCheckPoint then
					if DoesBlipExist(CurrentBlip) then
						RemoveBlip(CurrentBlip)
					end
					CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z)
					SetBlipRoute(CurrentBlip, 1)
					LastCheckPoint = CurrentCheckPoint
				end

				local distance = GetDistanceBetweenCoords(coords, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, true)

				if distance <= 100.0 then
					DrawMarker(1, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
				end

				if distance <= 3.0 then
					Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
					CurrentCheckPoint = CurrentCheckPoint + 1
				end
			end
			Wait(0)
		else
			Wait(500)
		end
	end
end)

-- Speed / Damage control
CreateThread(function()
	while true do
		if CurrentTest == 'drive' then
			local playerPed = PlayerPedId()
			if IsPedInAnyVehicle(playerPed, false) then
				local vehicle = GetVehiclePedIsIn(playerPed, false)
				local speed = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
				local tooMuchSpeed = false

				for k, v in pairs(Config.SpeedLimits) do
					if CurrentZoneType == k and speed > v then
						tooMuchSpeed = true
						if not IsAboveSpeedLimit then
							DriveErrors = DriveErrors + 1
							IsAboveSpeedLimit = true
							QBCore.Functions.Notify("Driving Too Fast", "error")
							QBCore.Functions.Notify("Mistakes - " .. DriveErrors .. " / " .. Config.MaxErrors, "error")
						end
					end
				end

				if not tooMuchSpeed then
					IsAboveSpeedLimit = false
				end

				local health = GetEntityHealth(vehicle)
				if health < LastVehicleHealth then
					DriveErrors = DriveErrors + 1
					QBCore.Functions.Notify("You damaged vehicle", "error")
					LastVehicleHealth = health
					Wait(1500) -- avoid stacking faults
				end
			end
			Wait(10)
		else
			Wait(500)
		end
	end
end)

CreateThread(function()
	-- Starter Ped
	local startmodel = `cs_priest`
	RequestModel(startmodel)
	while not HasModelLoaded(startmodel) do Wait(10) end
	local START_PED = CreatePed(0, startmodel, Config.startingped.x, Config.startingped.y, Config.startingped.z-1.0, Config.startingped.w, false, false)
	TaskStartScenarioInPlace(START_PED, 'WORLD_HUMAN_CLIPBOARD', true)
	FreezeEntityPosition(START_PED, true)
	SetEntityInvincible(START_PED, true)
	SetBlockingOfNonTemporaryEvents(START_PED, true)


	if Config.Target == 'qb' then
		exports['qb-target']:AddTargetEntity(START_PED, {
			options = {
				{
	                type = "client",
	                event = "drivingtest:start",
	                icon = "fas fa-archive",
	                label = "Start Driving Test",
	            },
			},
			distance = 2.0
		})
	elseif Config.Target == 'ox' then 
		exports.ox_target:addLocalEntity(START_PED, {
            {
                type = "client",
	            event = "drivingtest:start",
	            icon = "fas fa-archive",
	            label = "Start Driving Test",
            },
        })
	elseif Config.Target == 'interact' then 
		exports.interact:AddLocalEntityInteraction({
            entity = START_PED,
            name = 'dtest_guy',
            id = 'dtest_guy',
            distance = 5.0,
            interactDst = 1.5,
            ignoreLos = true,
            offset = vec3(0.0, 0.0, 0.0),
            options = {
                {
                    label = 'Start Driving Test',
                    action = function()
                        TriggerEvent('drivingtest:start')
                    end,
                },
            }
        })
	end
end)
