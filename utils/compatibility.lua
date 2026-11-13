local mq           = require('mq')
local Logger       = require("utils.logger")

local Compatibility      = { _version = '2.1', _name = "Compatibility", _author = 'Aysi', }
Compatibility.__index    = Compatibility

local function cleanSpellName(name)
    if not name or type(name) ~= 'string' then return "" end
    local cleaned = name:gsub('%s*%([%w%s/]+%)$', '')
    return (cleaned:gsub('^%s*(.-)%s*$', '%1'))
end

local function clearCursor()
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

function Compatibility.tryMem(slot, spellName)
    local me = mq.TLO.Me
    if not slot or slot < 1 or not spellName or spellName == '' then return false end
    local cleanName = cleanSpellName(spellName)

    clearCursor()

    local bookSlot = me.Book(spellName)()
    if not bookSlot then
        return false
    end

    -- 4. Stand up if sitting or ducking
    local isDucked = false
    pcall(function() isDucked = mq.TLO.Me.Ducking() end)
    if mq.TLO.Me.Sitting() or isDucked then
        mq.cmd('/stand')
        mq.delay(400)
    end

    -- 5. Open SpellBookWnd
    local SBW = function() return mq.TLO.Window('SpellBookWnd') end

    if not SBW().Open() then mq.cmd('/book') end
    local t = 0
    while not SBW().Open() and t < 2500 do
        mq.delay(100)
        t = t + 100
    end
    if not SBW().Open() then
        Logger.log_error('Failed to memorize spell - could not open the spellbook.')
        return false
    end

    -- 6. Detect spells per page in SpellBookWnd
    local per = 0
    for i = 0, 24 do
        local nm
        pcall(function() nm = SBW().Child('SBW_Spell' .. i).Name() end)
        if nm then per = per + 1 else break end
    end
    if per == 0 then per = 8 end

    -- 7. Determine current page by reading displayed spell slots
    local curPage, inferred = 1, false
    for i = 0, per - 1 do
        local txt
        pcall(function() txt = SBW().Child('SBW_Spell' .. i).Text() end)
        if txt and txt ~= '' then
            txt = txt:match('^%s*(.-)%s*$')
            local bs = me.Book(txt)()
            if bs then
                curPage = math.ceil(bs / per)
                inferred = true
                break
            end
        end
    end

    if not inferred then
        for _ = 1, 40 do
            mq.cmd('/notify SpellBookWnd SBW_PageDown_Button leftmouseup')
            mq.delay(70)
        end
        curPage = 1
    end

    -- 8. Turn pages to reach target page
    local targetPage = math.ceil(bookSlot / per)
    if curPage ~= targetPage then
        local diff = targetPage - curPage
        local btn = (diff > 0) and 'SBW_PageUp_Button' or 'SBW_PageDown_Button'
        for _ = 1, math.abs(diff) do
            mq.cmdf('/notify SpellBookWnd %s leftmouseup', btn)
            mq.delay(math.random(150, 300))
        end
    end

    -- 9. Pick up spell from book page and drop onto gem slot
    mq.cmdf('/notify SpellBookWnd SBW_Spell%d leftmouseup', (bookSlot - 1) % per)
    mq.delay(math.random(300, 500))
    mq.cmdf('/notify CastSpellWnd CSPW_Spell%d leftmouseup', slot - 1)

    -- 10. Wait for CastingWindow (the memorization bar) to start and finish
    local w = 0
    while not mq.TLO.Window('CastingWindow').Open() and w < 3000 do
        mq.delay(100)
        w = w + 100
    end

    while mq.TLO.Window('CastingWindow').Open() do
        mq.delay(100)
    end
    mq.delay(400)

    -- 11. Close spellbook
    if SBW().Open() then
        mq.cmd('/notify SpellBookWnd SBW_DoneButton leftmouseup')
    end

    clearCursor()

    return true
end

return Compatibility