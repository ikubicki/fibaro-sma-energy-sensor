--[[
SMA PV-energy sensor
@author ikubicki
]]

function QuickApp:onInit()
    self.config = Config:new(self)
    self.sma = SMA:new(self.config)
    self.sma.debug = false
    self.i18n = i18n:new(api.get("/settings/info").defaultLanguage)
    self:trace('')
    self:trace(self.i18n:get('name'))
    self:updateProperty('manufacturer', 'SMA')
    self:updateProperty('manufacturer', 'Energy meter')
    self:updateView("button1", "text", self.i18n:get('refresh'))
    self:updateView("label2", "text", string.format(self.i18n:get('today'), 0, 'W'))
    self:run()
end

function QuickApp:run()
    self:pullDataFromInverter()
    local interval = self.config:getTimeoutInterval()
    if (interval > 0) then
        fibaro.setTimeout(interval, function() self:run() end)
    end
end

function QuickApp:button1Event()
    self:pullDataFromInverter()
end

function QuickApp:pullDataFromInverter()
    self:updateView("button1", "text", self.i18n:get('please-wait'))
    local sid = false
    local errorCallback = function(error)
        self:updateView("button1", "text", self.i18n:get('refresh'))
        QuickApp:error(json.encode(error))
    end
    local logoutCallback = function()
        self:updateView("label1", "text", string.format(self.i18n:get('last-update'), os.date('%Y-%m-%d %H:%M:%S')))
        self:updateView("button1", "text", self.i18n:get('refresh'))
        self:trace(self.i18n:get('device-updated'))
    end
    local loggerCallback = function(res)
        self.sma:logout(sid, logoutCallback, errorCallback)
        if res and res.result then
            for _, deviceLogs in pairs(res.result) do
                local energy = deviceLogs[#deviceLogs]['v'] - deviceLogs[1]['v']
                self:debug('energia ', energy)
                local formattedEnergy = energy
                local unit = 'W'
                if energy > 1000000 then
                    formattedEnergy = string.format("%.1f", energy / 1000000)
                    unit = 'MWh'
                elseif energy > 1000 then
                    formattedEnergy = string.format("%.1f", energy / 1000)
                    unit = 'KWh'
                end
                self:updateView("label2", "text", string.format(self.i18n:get('today'), formattedEnergy, unit))
                self:updateEnergy(energy)
            end
        end
    end
    local loginCallback = function(sessionId)
        sid = sessionId
        self.sma:getLogger(sid, loggerCallback, errorCallback)
    end
    self.sma:login(loginCallback, errorCallback)
end

function QuickApp:updateEnergy(energy)
    if energy > 1000000 then
        self:debug('MWH ', energy / 1000000)
        self:updateProperty("value", energy / 1000000) 
        self:updateProperty("unit", "MWh") 
    elseif energy > 1000 then
        self:debug('KWH ', energy / 1000)
        self:updateProperty("value", energy / 1000) 
        self:updateProperty("unit", "KWh") 
    else
        self:debug('WH ', energy)
        self:updateProperty("value", energy) 
        self:updateProperty("unit", "Wh") 
    end
end
