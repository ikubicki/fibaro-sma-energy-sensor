--[[
SMA PV-energy meter
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
    self:updateProperty('model', 'Energy meter')
    self:updateView("button1", "text", self.i18n:get('refresh'))
    self:updateView("label2", "text", string.format(self.i18n:get('today'), 0, 'W'))
    self:updateProperty("rateType", "production")
    self:updateProperty("storeEnergyData", true)
    self:updateProperty("saveToEnergyPanel", true)
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
        self:updateView("button1", "text", self.i18n:get('refresh'))
        self:trace(self.i18n:get('device-updated'))
    end
    local loggerCallback = function(res)
        if res and res.result then
            for _, deviceLogs in pairs(res.result) do
                local todayEnergy = deviceLogs[#deviceLogs]['v'] - deviceLogs[1]['v']
                local formattedTodayEnergy = todayEnergy
                local unit = 'W'
                if todayEnergy > 1000000 then
                    formattedTodayEnergy = string.format("%.1f", todayEnergy / 1000000)
                    unit = 'MWh'
                elseif todayEnergy > 1000 then
                    formattedTodayEnergy = string.format("%.1f", todayEnergy / 1000)
                    unit = 'KWh'
                end
                self:updateView("label3", "text", string.format(self.i18n:get('today'), formattedTodayEnergy, unit))
            end
        end
    end
    local valuesCallback = function(res)
        if res and res.result then
            for _, deviceValues in pairs(res.result) do
                local energy = deviceValues[SMA.YIELD_TOTAL]["1"][1]["val"]
                self:updateEnergy(energy)
            end
        end
    end
    local loginCallback = function(sessionId)
        sid = sessionId
        self.sma:getValues(sid, {SMA.YIELD_TOTAL}, valuesCallback, errorCallback)
        self.sma:getLogger(sid, loggerCallback, errorCallback)
        self.sma:logout(sid, logoutCallback, errorCallback)
    end
    self.sma:login(loginCallback, errorCallback)
end

function QuickApp:updateEnergy(energy)
    self:updateProperty("energy", energy / 1000)
    self:updateProperty("value", energy / 1000)

    local formattedEnergy = energy
    local unit = 'W'
    if energy > 1000000000 then
        formattedEnergy = string.format("%.2f", energy / 1000000000)
        unit = 'GWh'
    elseif energy > 1000000 then
        formattedEnergy = string.format("%.2f", energy / 1000000)
        unit = 'MWh'
    elseif energy > 1000 then
        formattedEnergy = string.format("%.2f", energy / 1000)
        unit = 'KWh'
    end

    self:updateView("label1", "text", string.format(self.i18n:get('last-update'), os.date('%Y-%m-%d %H:%M:%S')))
    self:updateView("label2", "text", string.format(self.i18n:get('overall'), formattedEnergy, unit))

    self:debug('aaa', self.properties.energy, self.properties.value, self.properties.rateType)
    -- self:debug(json.encode(self.properties))
end
