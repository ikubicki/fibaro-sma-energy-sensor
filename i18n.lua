--[[
Internationalization tool
@author ikubicki
]]
class 'i18n'

function i18n:new(langCode)
    self.phrases = phrases[langCode]
    return self
end

function i18n:get(key)
    if self.phrases[key] then
        return self.phrases[key]
    end
    return key
end

phrases = {
    pl = {
        ['name'] = 'SMA czujnik energii fotowoltaicznej',
        ['refresh'] = 'Odśwież',
        ['last-update'] = 'Ostatnia aktualizacja: %s',
        ['please-wait'] = 'Proszę czekać...',
        ['device-updated'] = 'Zaktualizowano dane czujnika',
    },
    en = {
        ['name'] = 'SMA PV Energy sensor',
        ['refresh'] = 'Refresh',
        ['last-update'] = 'Last update at %s',
        ['please-wait'] = 'Please wait...',
        ['device-updated'] = 'Sensor data updated',
    },
    de = {
        ['name'] = 'SMA PV Energie sensor',
        ['refresh'] = 'Aktualisieren',
        ['last-update'] = 'Letztes update: %s',
        ['please-wait'] = 'Ein moment bitte...',
        ['device-updated'] = 'Sensor aktualisiert',
    }
}