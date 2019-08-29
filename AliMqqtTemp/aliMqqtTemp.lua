require("sht30v2")
const={}
const.D0=0
const.D1=1
const.D2=2
const.D3=3
const.D4=4
const.D5=5
const.D6=6
const.D7=7

if file.open("mqttcfg.json") then
    mqttcfg= sjson.decode(file.read())
    file.close()
end

sensor=mqttcfg.sensor
ClientId =wifi.sta.getmac()
ProductKey= mqttcfg.ProductKey
DeviceName= mqttcfg.DeviceName
DeviceSecret=mqttcfg.DeviceSecret
RegionId="cn-shanghai"
myMQTTport=1883
myMQTT=nil
myMQTThost=ProductKey..".iot-as-mqtt."..RegionId..".aliyuncs.com"
myMQTTusername=DeviceName.."&"..ProductKey
topic0 = "/sys/"..ProductKey.."/"..DeviceName.."/thing/event/property/post"

function GetTime()
    sec,usec,rate=rtctime.get()
    time=rtctime.epoch2cal(sec+(60*60*8),usec,rate)
     print(string.format("%04d/%02d/%02d %02d:%02d:%02d", 
                            time["year"], 
                            time["mon"], 
                            time["day"], 
                            time["hour"], 
                            time["min"], 
                            time["sec"]))
    return time                     
end                    

myMQTTtimes='6666'
hmacdata="clientId"..ClientId.."deviceName"..DeviceName.."productKey"..ProductKey.."timestamp"..myMQTTtimes
myMQTTpassword=crypto.toHex(crypto.hmac("sha1",hmacdata,DeviceSecret))
myMQTTClientId=ClientId.."|securemode=3,signmethod=hmacsha1,timestamp="..myMQTTtimes.."|"
myMQTT=mqtt.Client(myMQTTClientId,120,myMQTTusername,myMQTTpassword)

MQTTconnectFlag=0
tmr.alarm(0,2000,1,function()
    if myMQTT~=nil then
        print("Mqtt attempting client connect...")
        myMQTT:connect(myMQTThost, myMQTTport,0,MQTTSuccess,MQTTFailed)
    end
    end)

function MQTTSuccess(client)
    print("Mqtt attempting client connected")
    client:subscribe(topic0,0, function(conn)
       print("Mqtt subscribe success")
        end)
    myMQTT=client
    MQTTconnectFlag=1
    tmr.stop(0)
end

function MQTTFailed(client,reson)
    print("Fail reson:"..reson)
    MQTTconnectFlag=0
    tmr.start(0)
end
myMQTT:on("offline", function(client)
    print("mqtt offline")
    tmr.start(0)
    end)
myMQTT:on("message", function(client, topic, data)
    print(topic ..":")
    if data ~= nil then
       print(data)
       updatefunc(client,data)
    end
    end)
function updatefunc(m,pl)
    local alcfg = sjson.decode(pl)
    if alcfg.method == "thing.service.property.set" then
        if alcfg["params"]["Config"]~=nil then 
           aliData=alcfg.params.Config     
           if file.open("mqttcfg.json") then
             mqttcfg= sjson.decode(file.read())
             sensorCfg=mqttcfg.sensor
             file.close()
             print("config readed")
           else
             print("open file error")
             node.restart()      
           end
           if aliData.interval~=nil then 
              print("aliData interval:"..aliData.interval)    
              print("mqqtcfg interval:".. mqttcfg.interval)    
              mqttcfg.interval=aliData.interval
           end
           if aliData.tempName~=nil then 
              sensorCfg[aliData.sensorId].tempName=aliData.tempName
           end
           if aliData.humiName~=nil then 
              sensorCfg[aliData.sensorId].humiName=aliData.humiName
           end
           file.open("mqttcfg.json", "w+")
           file.write(sjson.encode(mqttcfg))
           file.close()
           print("Restarting...")
           node.restart()          
        end
    end
end  
function getPostData()
        local retTable = {}; 
        retTable["id"] = tmr.now()
        retTable["params"]=getParams(sensor)
        retTable["method"] = "thing.event.property.post"
        return sjson.encode(retTable)
end
function getParams(sensor)
    params={}
    for  i=1,#sensor  do
        if sensor[i].type=="dht22" then
           dht22pin=sensor[i].pin
           status,temp,humi,temp_dec,humi_dec=dht.read(const[dht22pin])
           print("pin:"..const[dht22pin]..", dht:"..temp) 
           sensorTemp=temp
           sensorHumi=humi
        end 
        
        if sensor[i].type=="sht31"  then 
            sht30v2.init()
            sensorTemp,sensorHumi=sht30v2.read() 
        end
    
        tempName=sensor[i].tempName
        humiName=sensor[i].humiName
        params[tempName]=sensorTemp
        params[humiName]=sensorHumi
    end   
    return params
end    
tmr.alarm(1, 1000*60*mqttcfg.interval,1, function()
    if MQTTconnectFlag==1 and myMQTT~=nil then
        myMQTT:publish(topic0,getPostData(),0,0,
            function(client)
                print("send ok")
                GetTime()  
            end)   
    end
end)

