--[[
SMA SDK
@author ikubicki
]]
class 'SMA'

SMA.debug = false

function SMA:new(config)
    self.right = config:getRight('usr')
    self.pass = config:getPassword()
    self.sid = false
    self.http = HTTPClient:new({
        baseUrl = config:getUrl()
    })
    QuickApp:debug(config:getUrl())
    return self
end

function SMA:login(callback, fail)
    if self.sid then
        self:logout(self.sid)
    end
    local sid = false
    local error = function(err)
        if sid then
            self:logout(sid)
        end
        if fail ~= nil then
            fail(err)
        end
    end
    local success = function(response)
        local data = string.gsub(response.data, "null", "false")
        local json = json.decode(data)
        if json.result then
            sid = json.result.sid
        end
        if json.err == 503 then
            error('Too many opened sessions!')
            return false
        end
        
        if sid then 
            self.sid = sid
            if callback ~= nil then
                callback(sid)
            else
                self:logout(sid)
            end
        else
            error('Received error: ' .. json.err)
        end
    end
    local data = {
        right = self.right,
        pass = self.pass
    }
    self.http:post('/dyn/login.json', data, success, error)
end

function SMA:getValues(sid, keys, callback, fail)
    local error = function(error)
        self:logout(sid)
        if fail ~= nil then
            fail(error)
        end
    end
    local success = function(response)
        local data = string.gsub(response.data, "null", "0") -- another hack
        local json = json.decode(data)
        if json then
            if callback ~= nil then
                callback(json)
            else
                self:logout(sid)
            end
        else
            error()
        end
    end
    local data = {
        destDev = {},
        keys = keys
    }
    self.values = {}
    data = json.encode(data)
    data = data:gsub("{}", "[]") -- tiny hack
    self.http:post('/dyn/getValues.json?sid=' .. sid, data, success, error)
end

function SMA:getLogger(sid, callback, fail)
    local error = function(error)
        self:logout(sid)
        if fail ~= nil then
            fail(error)
        end
    end
    local success = function(response)
        local data = string.gsub(response.data, "null", "0") -- another hack
        local json = json.decode(data)
        if json then
            if callback ~= nil then
                callback(json)
            else
                self:logout(sid)
            end
        else
            error()
        end
    end
    local midnight = os.time({
        year = os.date("%Y"),
        month = os.date("%m"),
        day = os.date("%d"),
        hour = 0,
        min = 0
    })
    local data = {
        destDev = {},
        key = 28672,
        tStart = midnight,
        tEnd = midnight + 86400
    }
    data = json.encode(data)
    data = data:gsub("{}", "[]") -- tiny hack
    self.http:post('/dyn/getLogger.json?sid=' .. sid, data, success, error)
end

function SMA:logout(sid, callback, fail)
    local error = function(error)
        QuickApp:error(json.encode(error))
        if fail ~= nil then
            fail(error)
        end
    end
    local success = function(response)
        local data = string.gsub(response.data, "null", "0") -- another hack
        local json = json.decode(data)
        if (json.result.isLogin == false) then
            self.sid = false
            if SMA.debug then
                QuickApp:debug(sid .. " successfully logged out")
            end
            if callback ~= nil then
                callback()
            end
        else
            error("Unable to logout " .. sid)
        end
    end
    self.http:post('/dyn/logout.json?sid=' .. sid, '{}', success, error)
end

SMA.POWER_CURRENT = '6100_40263F00'
SMA.POWER_MAXIMUM = '6100_00411E00'
SMA.YIELD_TOTAL = '6400_00260100'