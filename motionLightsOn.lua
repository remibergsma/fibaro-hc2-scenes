--[[
%% properties
59 value
%% globals
--]]

-- Please note: 
-- Update the id's below to match yours.
-- This script requires global variable 'Sun' to be defined in the Variables Panel.

-- id of the motion sensor. Also update trigger at the top.
local motionSensor = 59
-- id of the light to switch
local light = 62
-- is the light a dimmer
local isDimmer = 1
-- dimmer percentage (ignored of not a dimmer)
local dimLevel = 10 

-- check how we are invoked
-- type=other => manual
local startSource = fibaro:getSourceTrigger();

-- if motion sensor is breached
if (((tonumber(fibaro:getValue(motionSensor, "value")) > 0 )
      -- or we invoke manually
      or startSource["type"] == "other" )
   -- and the sun is set (does not make sense to switch lights during daytime)
   and fibaro:getGlobalValue("Sun") == "Set")
then
    -- switch on the light
    fibaro:debug("Switched ON lights due to motion")
    if isDimmer == 1
      then
	    fibaro:call(light, "setValue", dimLevel);
    else
        fibaro:call(light, "turnOn");
    end
end
  
-- lights will be turned off by a separate scene.
