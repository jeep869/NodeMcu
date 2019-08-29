
require("sht30v2") 
sht30v2.init()
temp,humi=sht30v2.read() 
print("temperature="..temp..", humidity="..humi)


--[[
require("sht30m2")
sht30m2.initSHT30()
sht31=sht30m2.get_data() 
print("temperature:"..sht31.temp..",humidity:"..sht31.humi)
--]]