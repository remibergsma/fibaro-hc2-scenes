--[[
%% properties
63 value
%% globals
--]]

-- Script to turn on lights when motion is detected
-- Remi Bergsma github@remi.nl

-- Please note: 
-- Update the id's below to match yours. Also update trigger at the top.
-- This script requires global variable 'Sun' to be defined in the Variables Panel. See sunset/sunrise script for usage.

-- id of the motion sensor.
local motionSensor = 63
-- id of the light to switch
local light = 27
-- is the light a dimmer
local isDimmer = 1
-- dimmer percentage (ignored of not a dimmer)
local dimLevel = 70
-- whether or not to display debug messages
local debug = 1

-- check how we are invoked
-- type=other => manual
local startSource = fibaro:getSourceTrigger();
if debug ==1 then fibaro:debug("We were invoked by " .. startSource["type"]) end

-- if motion sensor is detected
if (((tonumber(fibaro:getValue(motionSensor, "value")) > 0 )
      -- or we invoke manually
      or startSource["type"] == "other" )
   -- and the sun is set (does not make sense to switch lights during daytime)
   and fibaro:getGlobalValue("Sun") == "Set")
then
    -- switch on the light
    if debug ==1 then fibaro:debug("Switching ON light due to motion") end
    if isDimmer == 1
      then
        if debug ==1 then fibaro:debug("Set dim level to " .. dimLevel .. "%") end
	    fibaro:call(light, "setValue", dimLevel);
    else
        if debug ==1 then fibaro:debug("Turned on the light") end
        fibaro:call(light, "turnOn");
    end
end
  
-- lights will be turned off by a separate scene.
