gpio.mode(4,gpio.OUTPUT)

if file.open("wificfg.json") then
    wifi_cfg= sjson.decode(file.read())
    file.close()
else
    print("Open Wificfg.json fail")
    return
end
wifi.setmode(wifi.STATION) 
wifi.sta.config(wifi_cfg)       
       
tmr.alarm(1,1000,1,function()
    if wifi.sta.getip() == nil then
        print("Wifi connectiong...")
        gpio.write(4,gpio.LOW)
    else
        tmr.stop(1)
        print("Wifi connect success:")
    end
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("Wifi connected, IP is "..wifi.sta.getip())
    gpio.write(4,gpio.HIGH)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
    print("Wifi disconnect")
end)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
   GetNetTime()
   fileName="aliMqqtTemp.lua"
   print("Do file "..fileName)
   dofile(fileName)
end)

function GetNetTime()
    sntp.sync({"0.nodemcu.pool.ntp.org","1.nodemcu.pool.ntp.org","2.nodemcu.pool.ntp.org","3.nodemcu.pool.ntp.org","www.beijing-time.org"},
       function(sec, usec, server, info)
           print('sync', sec, usec, server)
        end,
        function()
           print("get time error")
        end)
    return 0
end
