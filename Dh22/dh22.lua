local moduleName = ...
local M = {} 
_G[moduleName] = M
temptable={}

function M.readTempHumi()
  status,temp,humi,temp_dec,humi_dec=dht.read(3)
  if status==dht.OK then

    payloadJson = {

        ["Temperature"] =temp,["Humidity"] = humi

    }

    temptable["Temperature"] = temp
    temptable["Humidity"] = humi
    return temp,humi
  else
    print("status:"..status)
  end

end

return M 
