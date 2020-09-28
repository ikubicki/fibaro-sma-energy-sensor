--[[
Configuration handler
@author ikubicki
]]
class 'Config'

function Config:new(app)
    self.app = app
    self:init()
    return self
end

function Config:getRight(alternative)
    if self.right and self.right:len() > 3 then
        return self.right
    end
    return alternative
end

function Config:getPassword()
    return self.password
end

function Config:getUrl()
    return self.url
end

function Config:getTimeoutInterval()
    return tonumber(self.interval) * 60000
end

function Config:getDataType()
    return self.dataType
end

function Config:setDataType(dataType)
    if string.len(self.dataType) > 3 then
        return false
    end
    self.app:setVariable("Data Type", dataType)
    self.dataType = dataType
end

--[[
This function takes variables and sets as global variables if those are not set already.
This way, adding other devices might be optional and leaves option for users, 
what they want to add into HC3 virtual devices.
]]
function Config:init()
    self.right = self.app:getVariable('Right')
    self.password = self.app:getVariable('Password')
    self.url = self.app:getVariable('URL')
    self.interval = self.app:getVariable('Refresh Interval')
    self.dataType = self.app:getVariable('Data Type')

    local storedRight = Globals:get('sma_right', '')
    local storedPassword = Globals:get('sma_password', '')
    local storedUrl = Globals:get('sma_url', '')
    local storedInterval = Globals:get('sma_interval', '')
    -- handling right (username)
    if string.len(self.right) < 4 and string.len(storedRight) > 3 then
        self.app:setVariable("Right", storedRight)
        self.right = storedRight
    elseif (storedRight == '' and self.right) then -- or storedRight ~= self.right then
        Globals:set('sma_right', self.right)
    end
    -- handling password
    if string.len(self.password) < 4 and string.len(storedPassword) > 3 then
        self.app:setVariable("Password", storedPassword)
        self.password = storedPassword
    elseif (storedPassword == '' and self.password) then -- or storedPassword ~= self.password then
        Globals:set('sma_password', self.password)
    end
    -- handling URL
    if string.len(self.url) < 4 and string.len(storedUrl) > 3 then
        self.app:setVariable("URL", storedUrl)
        self.url = storedUrl
    elseif (storedUrl == '' and self.url) then -- or storedUrl ~= self.url then
        Globals:set('sma_url', self.url)
    end
    -- handling interval
    if not self.interval or self.interval == "" then
        if storedInterval and storedInterval ~= "" then
            self.app:setVariable("Refresh Interval", storedInterval)
            self.interval = storedInterval
        else
            self.interval = "1"
        end
    end
    if (storedInterval == "" and self.interval ~= "") then -- or storedInterval ~= self.interval then
        Globals:set('sma_interval', self.interval)
    end
end