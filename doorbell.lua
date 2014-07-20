--[[ 
%% properties 
4 sceneActivation 
%% globals 
--]]

-- Script to handle the doorbell event
-- Remi Bergsma github@remi.nl

-- This scrips requires a global var named 'doorBellLock' with values 0 and 1.

-- the device id that triggers the action (i.e. the binary sensor that the doorbell button is connected to)
local trigger = fibaro:getSourceTrigger()
local triggerDeviceId = trigger['deviceID']

local name = fibaro:getName(triggerDeviceId) 
-- id of the light to switch at night
local light = 24
-- is the light a dimmer
local isDimmer = 0
-- dimmer percentage (ignored of not a dimmer)
local dimLevel = 50
-- timeout: when to turn the light off again
local lightTimeout = 300
-- whether or not to display debug messages
local debug = 1

-- id of the scene that got triggered
local triggerSceneActivationID = tonumber(fibaro:getValue(triggerDeviceId, "sceneActivation"))
if debug ==1 then fibaro:debug("We are triggered by scene activation id " .. triggerSceneActivationID) end 

-- doorBellLock global variable
local doorBellLock = fibaro:getGlobal("doorBellLock")

-- only ring if not locked
if (tonumber(doorBellLock) == 0) then
	-- the events we monitor for (push and release of doorbell button)
	if (tonumber(fibaro:getValue(triggerDeviceId, "sceneActivation")) == 20 
	or tonumber(fibaro:getValue(triggerDeviceId, "sceneActivation")) == 21) then 
		if debug ==1 then fibaro:debug("Trrring by sceneActivation id ".. triggerSceneActivationID) end
    
		-- mail camera snapshot
		fibaro:call(87, "sendPhotoToUser", "10")
		fibaro:call(86, "sendPhotoToUser", "10")
		-- archive foto and video
		fibaro:startScene(28)
    
		-- start with setting a lock to prevent it from triggering again immediately
		fibaro:setGlobal("doorBellLock",1) 	

		-- notify mobile devices. First id is person, last is notification template
		fibaro:call(12, "sendDefinedPushNotification", "3") -- remi
		fibaro:call(15, "sendDefinedPushNotification", "3") -- kaat
		fibaro:call(16, "sendDefinedPushNotification", "3") -- ipad
		
		-- ring the bell
		local currentDate = os.date("*t")
		if currentDate.hour >= 22 or currentDate.hour <= 7 then
			-- no bells during the night
			if debug ==1 then fibaro:debug("Did not ring due to night time!") end
		else
			-- ring the bel: virtual device 47 has a button that does HTTP call to ring bell
			if debug ==1 then fibaro:debug("Rang the bell") end
			-- button 1-6 are number of rings the bell makes
			fibaro:call(47, "pressButton", "3")
		end
    
		-- Switch on a light
		local switchedOn = 0
		-- Only if the sun is set (does not make sense to switch lights during daytime)
		if fibaro:getGlobalValue("Sun") == "Set" then
		-- already on?
		if tonumber(fibaro:getValue(light, "value")) == 0 then 
			-- switch on the light
			-- do a small random sleep
			fibaro:sleep(math.random(50)*100)
			switchedOn = 1
			if debug ==1 then fibaro:debug("Switching ON light due to door bell") end
			if isDimmer == 1 then
				if debug ==1 then fibaro:debug("Set dim level to " .. dimLevel .. "%") end
				fibaro:call(light, "setValue", dimLevel);
			else
				if debug ==1 then fibaro:debug("Turned on the light") end
				fibaro:call(light, "turnOn");
			end
		else
			if debug ==1 then fibaro:debug("Not turning ON lights: already ON!") end
		end
	else
		if debug ==1 then fibaro:debug("Not turning ON lights during day time.") end
	end

	-- do not ring for the next few seconds
	if debug ==1 then fibaro:debug("Locking for 15s") end
	fibaro:sleep(15*1000)
	fibaro:setGlobal("doorBellLock",0) 
	if debug ==1 then fibaro:debug("Unlocked") end

	-- turn off light if we turned it on
	if switchedOn == 1 then
		-- we already slept 15s before
		lightTimeout = lightTimeout - 15
		if debug ==1 then fibaro:debug("Waiting for " .. lightTimeout .. "s before switching light off again.") end
		fibaro:sleep(lightTimeout*1000)
		if tonumber(fibaro:getValue(light, "value")) == 1 then
			if debug ==1 then fibaro:debug("Switching light off again.") end
			fibaro:call(light, "turnOff");
		else
			if debug ==1 then fibaro:debug("Not turning OFF lights: already OFF!") end
		end
	end
end
else
	-- if locked do not ring but do unlock after some time
	if debug ==1 then fibaro:debug("Ignoring request: doorbell locked. Unlocking in 15s.") end
	fibaro:sleep(15*1000)
	fibaro:setGlobal("doorBellLock",0)
end

if debug ==1 then fibaro:debug("End processing trigger by ".. triggerSceneActivationID) end
