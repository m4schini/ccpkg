PROTOCOL = "HOMECOMING"

local MODEM_SIDE = settings.get("homecoming.modem")
local LOCATION = settings.get("homecoming.location")
local AUTHORIZED_DEVICE_ID = settings.get("homecoming.authorized_device")

if MODEM_SIDE == nil or LOCATION == nil or AUTHORIZED_DEVICE_ID == nil then
    print("Init Homecoming")
    settings.define("homecoming.modem", { description = "modem side", default = nil, type = "string" })
    settings.define("homecoming.location", { description = "modem side", default = nil, type = "string" })
    settings.define("homecoming.authorized_device",
        { description = "id of authorized device", default = nil, type = "number" })

    local completion = require "cc.completion"
    term.write("Modem: ")
    settings.set("homecoming.modem", read(nil, nil, completion.peripheral))
    term.write("ID of this location: ")
    settings.set("homecoming.location", read())
    term.write("ID of your client device: ")
    settings.set("homecoming.authorized_device", tonumber(read()))

    print("Confirm settings:")
    print("Modem:", settings.get("homecoming.modem"))
    print("Location:", settings.get("homecoming.location"))
    print("Modem:", settings.get("homecoming.authorized_device"))
    print("Are these settings correct? [y/N]")
    if read() ~= "y" then
        printError("Homecoming setup aborted by user")
        return 1
    end

    settings.save()
    MODEM_SIDE = settings.get("homecoming.modem")
    LOCATION = settings.get("homecoming.location")
    AUTHORIZED_DEVICE_ID = settings.get("homecoming.authorized_device")
end

rednet.open(MODEM_SIDE)

if not rednet.isOpen() then
    printError("failed to open rednet on " .. MODEM_SIDE)
    return
end

local function triggerRedstone()
    redstone.setOutput("top", true)
    sleep(1)
    redstone.setOutput("top", false)
end

while true do
    print("waiting for HOMECOMING message")
    local id, message = rednet.receive(PROTOCOL)
    print("received HOMECOMING message", id, message)
    if id == AUTHORIZED_DEVICE_ID and message == LOCATION then
        triggerRedstone()
    end
end
