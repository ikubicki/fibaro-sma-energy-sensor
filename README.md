# SMA Energy Meter

This quick application creates energy meter from SMA inverter. It collect data about today or total energy produced by your solar installation.

Data updates every 5 minutes by default.

## Configuration

`URL` - Base url to SMA inverter web interface, eg: `https://192.168.0.255`

`Password` - Password of chosen user

### Optional values

`Right` - name of the user. Defaults to `usr`.

`Refresh Interval` - number of minutes defining how often data should be refreshed. This value will be automatically populated on initialization of quick application.

`Data Type` - allows to determine which energy metric should be used: `total` or `today`. Defaults to `today`.

## Integration

This quick application integrates with other SMA dedicated quick app i have provided. It will automatically populate configuration to a new virtual SMA device.