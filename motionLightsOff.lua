--[[
%% autostart
%% properties
%% globals
--]]

-- Script to turn off lights when no more motion is detected
-- Remi Bergsma github@remi.nl

-- variables
-- number of seconds after which to turn off lights when motion stopped
local offTimeout = 10
-- id of the motion sensor
local motionSensor = 63
-- id of the light
local light = 62
-- whether or not to display debug messages
local debug = 1

-- turn off lights after some time
while true do
  -- first check for ongoing motion
  currentStatus = tonumber(fibaro:getValue(motionSensor, "value"))
  if debug ==1 then fibaro:debug("Testing for ongoing motion..") end
  if currentStatus == 1
    then 
        -- wait until motion is over
        while true do
          if debug ==1 then fibaro:debug("Ongoing motion, waiting 30s..") end
          fibaro:sleep(30*1000)
          if debug ==1 then fibaro:debug("Testing again..") end
          currentStatus = tonumber(fibaro:getValue(motionSensor, "value"))
          if currentStatus == 0 then break end
        end
  end
  if debug ==1 then fibaro:debug("No ongoing motion.") end
  
  -- how long ago was last motion?
  time = os.time() 
  last = tonumber(fibaro:getValue(motionSensor, "lastBreached")) 
  diff = tonumber(time-last)
  if debug ==1 then fibaro:debug("Last motion was at " .. last .. ", that is " .. diff .. " sec ago. Current status is: " .. currentStatus) end

  -- if lights are on and no motion, then switch them off
  local lampStatus = tonumber(fibaro:getValue(light, "value"))
  -- lamp will report 1 if on, dimmer will report dimlevel (1-99)
  if diff > offTimeout
    then
      if lampStatus >= 1
        then
          if debug ==1 then fibaro:debug("Current status of light: " .. lampStatus) end
          fibaro:call(light, "turnOff");
          if debug ==1 then fibaro:debug("Turned OFF due to no activity") end
	  fibaro:sleep(1000)
          lampStatus = tonumber(fibaro:getValue(light, "value"))
    	  if debug ==1 then fibaro:debug("New status of light: " .. lampStatus) end
      elseif debug ==1 then
        fibaro:debug("Nothing to do, lamp is already off.")
      end
  elseif debug ==1 then 
    fibaro:debug("Nothing to do, timeout is not over yet.")
  end
  if debug ==1 then fibaro:debug("Sleep a minute before testing again.") end
  fibaro:sleep(60*1000)
end
