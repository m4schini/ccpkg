local INVENTORY_ROW_LENGTH = 9
local INVENTORY_ROW_COUNT = 3

local function getValidItemGroup(itemDetail)
    local slot = itemDetail
    if slot.itemGroups == nil or #slot.itemGroups <= 0 then
        print("itemgroups empty")
        return nil
    end

    local out
    for j, itemGroup in ipairs(slot.itemGroups) do
        local key = itemGroup.id
        out = settings.get("ingest." .. key)
        if out ~= nil then
            return out
        end
    end


    return nil
end

local function getValidTag(itemDetail)
    local slot = itemDetail
    if slot.tags == nil then
        print("tags empty", textutils.serialise(slot.tags))
        return nil
    end

    local out
    for key, v in pairs(slot.tags) do
        print('tag', key)
        out = settings.get("ingest." .. key)
        if out ~= nil then
            return out
        end
    end

    return nil
end

local monitor = peripheral.find("monitor")
monitor.setTextScale(0.5)
monitor.clear()
print(monitor.getSize())

local inventory_prefix = 3
local inventory_row = 3

print(textutils.serialiseJSON(peripheral.getNames()))


while true do
    monitor.setCursorPos(4, 5)
    monitor.write('Place Box')
    monitor.setCursorPos(6, 6)
    monitor.write('below')
    local event, peripheral_id = os.pullEvent("peripheral")
    if peripheral.hasType(peripheral_id, "minecraft:shulker_box") then
        monitor.clear()
        monitor.setCursorPos(4, 1)
        monitor.write('Detected')
        monitor.setCursorPos(2, 2)
        monitor.write('Shulker Box')


        local box = peripheral.wrap(peripheral_id)
        local function processSlot(slot)
            local slot_data = box.getItemDetail(slot)
            if slot_data == nil then
                return colors.white
            end

            local out = settings.get("ingest." .. slot_data.name, nil)
            if out == nil then
                out = getValidTag(slot_data)
            end
            if out == nil then
                out = getValidItemGroup(slot_data)
            end
            if out == nil then
                return colors.purple
            end

            print("pushing", slot, "to", out)
            box.pushItems(out, slot)

            return colors.green
        end

        local i = 1
        for y = 1, INVENTORY_ROW_COUNT, 1 do
            for x = 1, INVENTORY_ROW_LENGTH, 1 do
                local slot_color = processSlot(i)
                local bc = monitor.getBackgroundColor()
                monitor.setCursorPos(x + inventory_prefix, y + inventory_row)
                monitor.setBackgroundColor(slot_color)
                monitor.write(' ')
                monitor.setBackgroundColor(bc)

                i = i + 1
            end
        end

        monitor.setCursorPos(3, 8)
        monitor.write('You can now')
        monitor.setCursorPos(1, 9)
        monitor.write('remove the box')

        ::wait::
        local event, detached_peripheral_id = os.pullEvent("peripheral_detach")
        if detached_peripheral_id ~= peripheral_id then
            goto wait
        end
        monitor.clear()
    end
end
