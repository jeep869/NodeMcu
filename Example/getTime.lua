function GetNetTime()
    sntp.sync({ "0.nodemcu.pool.ntp.org", "1.nodemcu.pool.ntp.org", "2.nodemcu.pool.ntp.org", "3.nodemcu.pool.ntp.org", "www.beijing-time.org" },
        function(sec, usec, server, info)
            print('sync', sec, usec, server)
        end,
        function()
            print("get time error")
        end)
    return 0
end


function GetTime()
    sec, usec, rate = rtctime.get()
    time = rtctime.epoch2cal(sec + (60 * 60 * 8), usec, rate)
    print(string.format("%04d/%02d/%02d %02d:%02d:%02d",
        time["year"],
        time["mon"],
        time["day"],
        time["hour"],
        time["min"],
        time["sec"]))
    return 0
end

GetNetTime()
GetTime()