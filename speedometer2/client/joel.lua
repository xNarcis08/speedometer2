onInt = false
local hour = 0
local voice = 2
local minute = 0
local month = ""
local hunger = 100
local thirst = 100
local dayMonth = 0
local varDay = "th"
local showHud = false
local showMovie = false
local showRadar = false
local sBuffer = {}
local seatbelt = false
local ExNoCarro = false
local timedown = 0
local talking = false

local menu_celular = false
RegisterNetEvent("status:celular")
AddEventHandler("status:celular",function(status)
	menu_celular = status
end)

function calculateTimeDisplay()
	hour = GetClockHours()
	month = GetClockMonth()
	minute = GetClockMinutes()
	dayMonth = GetClockDayOfMonth()

	if hour <= 9 then
		hour = "0"..hour
	end

	if minute <= 9 then
		minute = "0"..minute
	end

	if month == 0 then
		month = "January"
	elseif month == 1 then
		month = "February"
	elseif month == 2 then
		month = "March"
	elseif month == 3 then
		month = "April"
	elseif month == 4 then
		month = "May"
	elseif month == 5 then
		month = "June"
	elseif month == 6 then
		month = "July"
	elseif month == 7 then
		month = "August"
	elseif month == 8 then
		month = "September"
	elseif month == 9 then
		month = "October"
	elseif month == 10 then
		month = "November"
	elseif month == 11 then
		month = "December"
	end
end

RegisterNetEvent("vrp_hud:Tokovoip")
AddEventHandler("vrp_hud:Tokovoip",function(status)
	voice = status
end)

RegisterNetEvent("vrp_hud:TokovoipTalking")
AddEventHandler("vrp_hud:TokovoipTalking",function(status)
	talking = status
end)

RegisterNetEvent("statusFome")
AddEventHandler("statusFome",function(number)
	hunger = parseInt(number)
end)

RegisterNetEvent("statusSede")
AddEventHandler("statusSede",function(number)
	thirst = parseInt(number)
end)

RegisterNetEvent("hudActived")
AddEventHandler("hudActived",function()
	showHud = true
end)

Citizen.CreateThread(function()
	while true do
		if IsPauseMenuActive() or IsScreenFadedOut() or menu_celular then
			SendNUIMessage({ hud = false, movie = false })
		else
			local ped = PlayerPedId()
			local armour = GetPedArmour(ped)
			local health = (GetEntityHealth(PlayerPedId())-100)/100*100
			local stamina = GetPlayerSprintStaminaRemaining(PlayerId())
			nsei,baixo,alto = GetVehicleLightsState(GetVehiclePedIsIn(PlayerPedId()))
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))

		

			local ped = PlayerPedId()
			local car = GetVehiclePedIsIn(ped)

			if not showHud then 
				showRadar = false 
			end

			if IsPedOnAnyBike(ped) then
				showHud = true
				showRadar = true
				Wait(1000)
			end
			
			if not IsPedInAnyVehicle(ped) then 
				showHud = false
				showRadar = false
				DisplayRadar(showRadar)
				Wait(1000)
			end

			if baixo == 1 and alto == 0 then
				farol = 1
			elseif  alto == 1 then
				farol = 2
			else
				farol = 0
      		end

			if IsPedInAnyVehicle(ped) then
				showHud = true
				showRadar = true
				local vehicle = GetVehiclePedIsIn(ped)

				local fuel = GetVehicleFuelLevel(vehicle)
				local enginehealth = GetVehicleEngineHealth(vehicle)
				local speed = GetEntitySpeed(vehicle) * 3.6
				Wait(1000)

				SendNUIMessage({ hud = showHud, movie = showMovie, car = true, day = dayMonth..varDay, month = month, hour = hour, minute = minute,  radio = radioDisplay, voice = voice, talking = talking, health = parseInt(health), armour = parseInt(armour), thirst = parseInt(thirst), hunger = parseInt(hunger), stamina = parseInt(stamina), fuel = parseInt(fuel), speed = parseInt(speed), seatbelt = seatbelt, farol = farol, enginehealth = enginehealth })
			else
				SendNUIMessage({ hud = showHud, movie = showMovie, car = false, day = dayMonth..varDay, month = month, hour = hour, minute = minute,  radio = radioDisplay, voice = voice, talking = talking, health = parseInt(health), armour = parseInt(armour), thirst = parseInt(thirst), hunger = parseInt(hunger), stamina = parseInt(stamina) })
			end
		end

		Citizen.Wait(1000)
	end
end)

RegisterKeyMapping('hud:interact', 'Abrir menu de interação', 'keyboard', 'I')

RegisterCommand('hud:interact', function()
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) then
		onInt = true
		SendNUIMessage({ interact = true })
		SetNuiFocus(true, true)
		TransitionToBlurred(1000)
	else
		TriggerEvent("Notify","negado","Você não pode abrir o menu em um veículo.")
	end
end)

RegisterNUICallback('hideFocus',function()
	SetNuiFocus(false, false)
	onInt = false
	TransitionFromBlurred(1000)
end)

RegisterNUICallback('hideHUD',function()
	TriggerEvent("bdl:triggerhud")
end)
-- /HUD
RegisterCommand("togkm",function(source,args)
	TriggerEvent("bdl:triggerhud")
end)
-- HIDE HUD
RegisterNetEvent("bdl:triggerhud")
AddEventHandler("bdl:triggerhud",function()
	showHud =  not showHud
end)
-- /MOVIE
RegisterCommand("movie",function(source,args)
	showMovie = not showMovie
end)
-- CINTO
IsCar = function(veh)
	local vc = GetVehicleClass(veh)
	return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 15 and vc <= 20)
end

Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		local ped = PlayerPedId()
		local car = GetVehiclePedIsIn(ped)

		if car ~= 0 and (ExNoCarro or IsCar(car)) then
			ExNoCarro = true
			if seatbelt then
				DisableControlAction(0,75)
			end

			timeDistance = 4
			sBuffer[2] = sBuffer[1]
			sBuffer[1] = GetEntitySpeed(car)

			if sBuffer[2] ~= nil and not seatbelt and GetEntitySpeedVector(car,true).y > 1.0 and sBuffer[1] > 10.25 and (sBuffer[2] - sBuffer[1]) > (sBuffer[1] * 0.255) then
				SetEntityHealth(ped,GetEntityHealth(ped)-10)
		--		TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped),4160)
				timedown = 10
			end

			if IsControlJustReleased(1,47) then
				if seatbelt then
					TriggerEvent("vrp_sound:source","unbelt",0.5)
					seatbelt = false
					Wait(2000)
				else
					TriggerEvent("vrp_sound:source","belt",0.5)
					seatbelt = true
					Wait(2000)
				end
			end

			if IsPedOnAnyBike(ped) then
				showRadar = true
			end

			if not seatbelt and not showHud then 
				showRadar = false
				Wait(3000)
			end

		elseif ExNoCarro then
			ExNoCarro = false
			seatbelt = false
			sBuffer[1],sBuffer[2] = 0.0,0.0
		end
		DisplayRadar(showRadar)
		Citizen.Wait(timeDistance)
	end
end)