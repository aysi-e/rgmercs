local mq           = require('mq')
local Logger       = require("utils.logger")

local Compatibility      = { _version = '2.1', _name = "Compatibility", _author = 'Aysi', }
Compatibility.__index    = Compatibility

function Compatibility.clearCursor()
    local item = mq.TLO.Cursor
    if not item() or (item.ID() or 0) <= 0 then return false end
    pcall(function()
        local count = 0
        while (mq.TLO.Cursor.ID() or 0) > 0 and count < 255 do
            mq.cmd('/autoinventory')
            mq.delay(50)
            count = count + 1
        end
    end)
    return true
end

-- function Compatibility.tryMem(slot, spellName)
--     Logger.log_info("[Compatibility] Attempting to memorize spell %s in slot %d", spellName, slot)
--     local me = mq.TLO.Me
--     if not slot or slot < 1 or not spellName or spellName == '' then return false end
    
--     if not Compatibility.unmemGem(slot) then return false end

--     Compatibility.clearCursor()

--     local bookSlot = me.Book(spellName)()
--     local page = math.ceil(bookSlot / 8)
--     if not bookSlot then
--         return false
--     end

--     -- 4. Stand up if sitting or ducking
--     local isDucked = false
--     pcall(function() isDucked = mq.TLO.Me.Ducking() end)
--     if mq.TLO.Me.Sitting() or isDucked then
--         mq.cmd('/stand')
--         mq.delay(400)
--     end

--     -- 5. Open SpellBookWnd
--     local SBW = function() return mq.TLO.Window('SpellBookWnd') end
--     mq.cmd(string.format('/book %d', page));
--     local t = 0
--     while not SBW().Open() and t < 2500 do
--         mq.delay(100)
--         t = t + 100
--     end
--     if not SBW().Open() then
--         Logger.log_error('Failed to memorize spell - could not open the spellbook.')
--         return false
--     end

--     -- 9. Pick up spell from book page and drop onto gem slot
--     mq.cmdf('/notify SpellBookWnd SBW_Spell%d leftmouseup', (bookSlot - 1) % 8)
--     mq.delay(math.random(300, 500))
--     mq.cmdf('/notify CastSpellWnd CSPW_Spell%d leftmouseup', slot - 1)

--     -- 10. Wait for CastingWindow (the memorization bar) to start and finish
--     local w = 0
--     while not mq.TLO.Window('CastingWindow').Open() and w < 3000 do
--         mq.delay(100)
--         w = w + 100
--     end

--     while mq.TLO.Window('CastingWindow').Open() do
--         mq.delay(100)
--     end
--     mq.delay(400)

--     -- 11. Close spellbook
--     if SBW().Open() then
--         mq.cmd('/notify SpellBookWnd SBW_DoneButton leftmouseup')
--     end

--     Compatibility.clearCursor()

--     return true
-- end

function Compatibility.unmemGem(slot)
    slot = tonumber(slot) or 1
    local currentInGem = nil
    pcall(function() currentInGem = mq.TLO.Me.Gem(slot).Name() end)
    if not currentInGem or currentInGem == '' or currentInGem == 'NULL' then return true end

    mq.cmdf('/notify CastSpellWnd CSPW_Spell%d rightmouseup', slot - 1)
    mq.delay(200)
    local clearWait = 0
    while clearWait < 1000 do
        local inGem = nil
        pcall(function() inGem = mq.TLO.Me.Gem(slot).Name() end)
        if not inGem or inGem == '' or inGem == 'NULL' then return true end
        mq.delay(100)
        clearWait = clearWait + 100
    end
    local stillInGem = nil
    pcall(function() stillInGem = mq.TLO.Me.Gem(slot).Name() end)
    return not stillInGem or stillInGem == '' or stillInGem == 'NULL'
end

return Compatibility