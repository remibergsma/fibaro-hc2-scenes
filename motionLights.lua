--[[
%% properties
59 value
63 value
66 value
69 value
72 value
75 value
78 value
%% globals
--]]

-- Script to turn ON/OFF lights when motion is detected. One script handles them all :-)
-- Remi Bergsma github@remi.nl

-- Please note: 
-- This script requires global variable 'Sun' to be defined in the Variables Panel.

-- Configuration:
-- Add motion devices in header, and create a line in the config array for each of them.
-- In this array, define motion and light devices to switch
-- Data structure: lightArray['motion id'] = { identifier, light id, isDimmer, dimLevel, timeout }
local lightArray = { }
lightArray['59'] = { 'Corridor', 62, 1, 10, 180 }
lightArray['63'] = { 'Living room', 18, 0, 0, 300 }
lightArray['69'] = { 'Kitchen', 56, 1, 50, 300 }

-- whether or not to display debug messages
local debug = 1

-- check how we are invoked
-- type=other => manual
local trigger = fibaro:getSourceTrigger()
if trigger["type"] == "other" then
	fibaro:debug("Invoked manually, cannot use dynamic configuration. Halting.")
	fibaro:abort()
end

-- how many instances are running
local nrOfScenes = fibaro:countScenes()
if debug ==1 then fibaro:debug("New session: total number of concurrent running scenes is now " .. nrOfScenes) end

-- who triggered us
if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Triggered by device of type " .. trigger["type"] .. ".") end

-- do we have config for triggering device?
local configFound = 0
for k, v in pairs(lightArray) do
	if k == trigger['deviceID'] then
		configFound = 1
    end
end

if configFound == 0 then
	if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "No config found for triggering device " .. trigger['deviceID'] .. ". Halting.") end
	fibaro:abort()
end

-- getting config
local configArray = lightArray[trigger['deviceID']]

-- which config are we running
if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Running config for " .. configArray[1] .. ".") end

-- vars needed in the code below
-- id of the light to switch
local light = configArray[2]
-- is the light a dimmer
local isDimmer = configArray[3]
-- dimmer percentage (ignored of not a dimmer)
local dimLevel = configArray[4]
-- number of seconds after which to turn off lights when motion stopped
local offTimeout = configArray[5]

-- motion reported
if tonumber(fibaro:getValue(trigger['deviceID'], "value")) > 0 then
	if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Motion detected." ) end
	-- Only if the sun is set (does not make sense to switch lights during daytime)
	if fibaro:getGlobalValue("Sun") == "Set" then
		-- already on?
		if tonumber(fibaro:getValue(light, "value")) == 0 then 
			-- switch on the light
			if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Switching ON light due to motion") end
			if isDimmer == 1 then
				if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Set dim level to " .. dimLevel .. "%") end
				fibaro:call(light, "setValue", dimLevel);
			else
				if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Turned on the light") end
				fibaro:call(light, "turnOn");
			end
		else
			if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Not turning ON lights: already on") end
		end
	else
		if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Not turning ON lights during day time.") end
	end

-- no motion reported
else
	if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Device " .. trigger['deviceID'] .. " reports no more motion." ) end
	if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Sleeping " .. offTimeout .. "s before turning OFF.." ) end
	fibaro:sleep(offTimeout*1000)
	-- first check for ongoing motion
	currentStatus = tonumber(fibaro:getValue(trigger['deviceID'], "value"))
	if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Testing for ongoing motion..") end
	if currentStatus == 0 then   
		if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "No ongoing motion.") end
		-- how long ago was last motion?
		time = os.time() 
		last = tonumber(fibaro:getValue(trigger['deviceID'], "lastBreached")) 
		diff = tonumber(time-last)
		if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Last motion was at " .. last .. ", that is " .. diff .. " sec ago. Current motion status is: " .. currentStatus) end

		-- if lights are on and no motion, then switch them off
		local lightStatus = tonumber(fibaro:getValue(light, "value"))
		-- relay switch will report 1 if on, dimmer will report dimlevel (1-99)
		if diff > offTimeout then
			if lightStatus >= 1 then
			if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Current status of light: " .. lightStatus) end
			fibaro:call(light, "turnOff");
			if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Turned OFF due to no activity") end
			fibaro:sleep(1000)
			lightStatus = tonumber(fibaro:getValue(light, "value"))
			if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "New status of light: " .. lightStatus) end
		elseif debug ==1 then
			fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Nothing to do, lamp is already off.")
		end
	elseif debug ==1 then 
		fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Nothing to do, timeout is not over yet.") end
	else
	if debug ==1 then fibaro:debug("Device " .. trigger['deviceID'] .. ": " .. "Ongoing motion, skipping turning OFF.") end
	end
end
