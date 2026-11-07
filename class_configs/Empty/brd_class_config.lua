--- @type Mq
local mq           = require('mq')
local Casting      = require("utils.casting")
local Combat       = require("utils.combat")
local Config       = require('utils.config')
local Core         = require("utils.core")
local Globals      = require("utils.globals")
local ItemManager  = require('utils.item_manager')
local Logger       = require("utils.logger")
local Targeting    = require("utils.targeting")


local _ClassConfig = {
    _version              = "ratquest - empty default config - must change",
    _author               = "Aysi",
    ['Modes']             = {
        'General',
    },
    ['OnModeChange']      = function(self, mode)

    end,
    ['ModeChecks']        = {
        CanMez       = function() return false end,
        CanCharm     = function() return false end,
        IsMezzing    = function() return false end,
    },
    ['Dispel']            = {

    },
    ['Cure']              = {

    },
    ['Themes']            = {
        ['General'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.50, g = 0.08, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.50, g = 0.08, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.20, g = 0.03, b = 0.14, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.50, g = 0.08, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.50, g = 0.08, b = 0.35, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.20, g = 0.03, b = 0.14, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.50, g = 0.08, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.50, g = 0.08, b = 0.35, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.50, g = 0.08, b = 0.35, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.33, g = 0.05, b = 0.23, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.50, g = 0.08, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.50, g = 0.08, b = 0.35, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.50, g = 0.08, b = 0.35, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.20, g = 0.03, b = 0.14, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.00, g = 0.80, b = 0.10, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.00, g = 0.80, b = 0.10, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.50, g = 0.08, b = 0.35, a = 1.0, }, },
        },
    },
    ['ItemSets']          = {

    },
    ['AbilitySets']       = {
        
    },
    ['Helpers']           = {

    },
    ['SpellList']         = { -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
        {
            name = "Default Mode",
            -- cond = function(self) return true end, --Code kept here for illustration, if there is no condition to check, this line is not required
            spells = {
                
            },
        },
    },
    ['Mez']               = {
    },
    ['Charm']             = {
        ['Abilities'] = {        },
    },
    ['RotationOrder']     = {
        {
            name = 'Downtime',
            state = 1,
            steps = 1,
            midSong = true,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and not mq.TLO.Me.Invis()
            end,
        },
        {
            name = 'Emergency(Health)',
            state = 1,
            steps = 1,
            midSong = true,
            doFullRotation = true,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return Targeting.HasXTHaters() and Core.AtEmergencyHP()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            midSong = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Combat',
            state = 1,
            steps = 1,
            midSong = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
    },
    ['Rotations']         = {
        ['Burn']              = {
            
        },
        ['Combat']            = {
            
        },
        ['Downtime']          = {
            
        },
        ['Emergency(Health)'] = {

        },
        ['Emergency(Aggro)']  = {

        },
        ['InstantRunBuff']    = {

        },
    },
    ['PullAbilities']     = {

    },
    ['PullMoveAbilities'] = {

    },
    ['DefaultConfig']     = {
        ['Mode']            = {
            DisplayName = "Mode",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes do?",
            Answer = "There is only one mode.",
        },
    },
    ['ClassFAQ']          = {},
}
return _ClassConfig
