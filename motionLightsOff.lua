--[[
%% autostart
%% properties
%% globals
--]]

-- Script to turn off lights when no more motion is detected
-- Remi Bergsma github@remi.nl

-- variables
-- whether or not to display debug messages
local debug = 1
-- time in seconds to sleep between each loop
local sleepTime = 60

-- Data structure: 
--   name (to identify config, does not do anything)
--   id of motion device
--   id of lamp to switch
--   number of seconds after which to turn off lights when motion stopped
local dataArray = { 
	{ 'overloop', 59, 62, 10 },
	{ 'living', 63, 18, 20 },
}

-- keep running
while true do
	-- loop all the configs
	for k, v in pairs(dataArray) do
		name = v[1]
		motionSensor = v[2]
		light = v[3]
		offTimeout = v[4]
    
		if debug ==1 then fibaro:debug("Procesing config line " ..k .. " " .. name .. ": motion id " .. motionSensor .. ", light id " .. light) end

		-- first check for ongoing motion
		currentStatus = tonumber(fibaro:getValue(motionSensor, "value"))
		if debug ==1 then fibaro:debug("Testing for ongoing motion..") end
		if currentStatus == 0
			then   
				if debug ==1 then fibaro:debug("No ongoing motion.") end
				-- how long ago was last motion?
				time = os.time() 
				last = tonumber(fibaro:getValue(motionSensor, "lastBreached")) 
				diff = tonumber(time-last)
				if debug ==1 then fibaro:debug("Last motion was at " .. last .. ", that is " .. diff .. " sec ago. Current status is: " .. currentStatus) end
      
				-- if lights are on and no motion, then switch them off
				local lightStatus = tonumber(fibaro:getValue(light, "value"))
				-- lamp will report 1 if on, dimmer will report dimlevel (1-99)
				if diff > offTimeout
					then
						if lightStatus >= 1
							then
								if debug ==1 then fibaro:debug("Current status of light: " .. lightStatus) end
								fibaro:call(light, "turnOff");
								if debug ==1 then fibaro:debug("Turned OFF due to no activity") end
								fibaro:sleep(1000)
								lightStatus = tonumber(fibaro:getValue(light, "value"))
								if debug ==1 then fibaro:debug("New status of light: " .. lightStatus) end
						elseif debug ==1 then
							fibaro:debug("Nothing to do, lamp is already off.")
						end
				elseif debug ==1 then 
					fibaro:debug("Nothing to do, timeout is not over yet.")
				end    
			else
				if debug ==1 then fibaro:debug("Ongoing motion, skipping.") end
    	end
	end
	if debug ==1 then fibaro:debug("Sleeping " .. sleepTime .. "s before testing again.") end
	fibaro:sleep(sleepTime*1000)
end
