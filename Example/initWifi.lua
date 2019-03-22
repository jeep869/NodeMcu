gpio.mode(4,gpio.OUTPUT)
wifi_cfg={}
wifi_cfg.ssid="APqw"
wifi_cfg.pwd="12345678"
wifi_cfg.auto=true
wifi.setmode(wifi.STATION) 
wifi.sta.config(wifi_cfg)       
       
tmr.alarm(1,1000,1,function()
    if wifi.sta.getip() == nil then
        print("Wifi connectiong...")
    else
        tmr.stop(1)
        print("Wifi connect success:")
    end
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("Wifi connected, IP is "..wifi.sta.getip())
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
    print("Wifi disconnect")
    gpio.write(4,gpio.HIGH)
end)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
    gpio.write(4,gpio.LOW)
   dofile("test.lua")
end)
