-- Raid Inspect Icon Mappings
-- Complete race, class, and spec icon mappings for Turtle WoW

RaidInspect_Icons = {}

-- ===========================================
-- CLASS COLORS (for row backgrounds and text)
-- ===========================================
RaidInspect_Icons.classColors = {
    WARRIOR = {0.78, 0.61, 0.43},
    ROGUE = {1, 0.96, 0.41},
    MAGE = {0.41, 0.80, 0.94},
    WARLOCK = {0.58, 0.51, 0.79},
    HUNTER = {0.67, 0.83, 0.45},
    PRIEST = {1, 1, 1},
    PALADIN = {0.96, 0.55, 0.73},
    SHAMAN = {0, 0.44, 0.87},
    DRUID = {1, 0.49, 0.04},
}

-- ===========================================
-- RACE ICONS (Using Racial Abilities/Themes)
-- Note: Achievement icons do not exist in Vanilla, so we use spell/item icons.
-- ===========================================
RaidInspect_Icons.raceIcons = {
    -- Alliance
    ["Human_Male"] = "Interface\\Icons\\Spell_Holy_PrayerOfHealing", 
    ["Human_Female"] = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
    
    ["Dwarf_Male"] = "Interface\\Icons\\Ability_Racial_Avatar", -- Stoneform lookalike
    ["Dwarf_Female"] = "Interface\\Icons\\Ability_Racial_Avatar",
    
    ["Night Elf_Male"] = "Interface\\Icons\\Ability_Ambush", -- Shadowmeld
    ["Night Elf_Female"] = "Interface\\Icons\\Ability_Ambush",
    
    ["Gnome_Male"] = "Interface\\Icons\\Spell_Arcane_Arcane01", -- Escape Artist
    ["Gnome_Female"] = "Interface\\Icons\\Spell_Arcane_Arcane01",
    
    ["High Elf_Male"] = "Interface\\Icons\\Spell_Holy_MindVision", -- Elf Eye
    ["High Elf_Female"] = "Interface\\Icons\\Spell_Holy_MindVision",
    
    -- Horde
    ["Orc_Male"] = "Interface\\Icons\\Ability_Racial_BloodRage", -- Blood Fury
    ["Orc_Female"] = "Interface\\Icons\\Ability_Racial_BloodRage",
    
    ["Undead_Male"] = "Interface\\Icons\\Spell_Shadow_RaiseDead", -- WotF
    ["Undead_Female"] = "Interface\\Icons\\Spell_Shadow_RaiseDead",
    
    ["Tauren_Male"] = "Interface\\Icons\\Ability_Warstomp", -- War Stomp
    ["Tauren_Female"] = "Interface\\Icons\\Ability_Warstomp",
    
    ["Troll_Male"] = "Interface\\Icons\\Ability_Racial_Regeneration", -- Regeneration
    ["Troll_Female"] = "Interface\\Icons\\Ability_Racial_Regeneration",
    
    ["Goblin_Male"] = "Interface\\Icons\\INV_Misc_Coin_01", -- Gold
    ["Goblin_Female"] = "Interface\\Icons\\INV_Misc_Coin_01",
    
    -- Fallback Keys (Just in case)
    Human = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
    Dwarf = "Interface\\Icons\\Ability_Racial_Avatar",
    ["Night Elf"] = "Interface\\Icons\\Ability_Ambush",
    Gnome = "Interface\\Icons\\Spell_Arcane_Arcane01",
    ["High Elf"] = "Interface\\Icons\\Spell_Holy_MindVision",
    Orc = "Interface\\Icons\\Ability_Racial_BloodRage",
    Undead = "Interface\\Icons\\Spell_Shadow_RaiseDead",
    Tauren = "Interface\\Icons\\Ability_Warstomp",
    Troll = "Interface\\Icons\\Ability_Racial_Regeneration",
    Goblin = "Interface\\Icons\\INV_Misc_Coin_01",
}

-- ===========================================
-- CLASS ICONS
-- ===========================================
RaidInspect_Icons.classIcons = {
    WARRIOR = "Interface\\Icons\\INV_Sword_27",
    ROGUE = "Interface\\Icons\\INV_Weapon_ShortBlade_05",
    MAGE = "Interface\\Icons\\INV_Staff_13",
    WARLOCK = "Interface\\Icons\\Spell_Shadow_DemonicEmpathy",
    HUNTER = "Interface\\Icons\\INV_Weapon_Bow_07",
    PRIEST = "Interface\\Icons\\INV_Staff_30",
    PALADIN = "Interface\\Icons\\INV_Hammer_01",
    SHAMAN = "Interface\\Icons\\INV_Jewelry_Talisman_04",
    DRUID = "Interface\\Icons\\Spell_Nature_Regeneration",
}

-- ===========================================
-- SPEC ICONS (Vanilla Talent Trees)
-- ===========================================
RaidInspect_Icons.specIcons = {
    -- Warrior
    ["WARRIOR_Arms"] = "Interface\\Icons\\Ability_Warrior_SavageBlow",
    ["WARRIOR_Fury"] = "Interface\\Icons\\Ability_Warrior_InnerRage",
    ["WARRIOR_Protection"] = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
    -- Rogue
    ["ROGUE_Assassination"] = "Interface\\Icons\\Ability_Rogue_Eviscerate",
    ["ROGUE_Combat"] = "Interface\\Icons\\Ability_BackStab",
    ["ROGUE_Subtlety"] = "Interface\\Icons\\Ability_Stealth",
    -- Mage
    ["MAGE_Arcane"] = "Interface\\Icons\\Spell_Holy_MagicalSentry",
    ["MAGE_Fire"] = "Interface\\Icons\\Spell_Fire_FireBolt02",
    ["MAGE_Frost"] = "Interface\\Icons\\Spell_Frost_FrostBolt02",
    -- Warlock
    ["WARLOCK_Affliction"] = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
    ["WARLOCK_Demonology"] = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
    ["WARLOCK_Destruction"] = "Interface\\Icons\\Spell_Shadow_RainOfFire",
    -- Hunter
    ["HUNTER_BeastMastery"] = "Interface\\Icons\\Ability_Hunter_BeastCall",
    ["HUNTER_Marksmanship"] = "Interface\\Icons\\Ability_Marksmanship",
    ["HUNTER_Survival"] = "Interface\\Icons\\Ability_Kick",
    -- Priest
    ["PRIEST_Discipline"] = "Interface\\Icons\\Spell_Holy_InnerFire",
    ["PRIEST_Holy"] = "Interface\\Icons\\Spell_Holy_Renew",
    ["PRIEST_Shadow"] = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    -- Paladin
    ["PALADIN_Holy"] = "Interface\\Icons\\Spell_Holy_HolyBolt",
    ["PALADIN_Protection"] = "Interface\\Icons\\Spell_Holy_DevotionAura",
    ["PALADIN_Retribution"] = "Interface\\Icons\\Spell_Holy_AuraOfLight",
    -- Shaman
    ["SHAMAN_Elemental"] = "Interface\\Icons\\Spell_Nature_Lightning",
    ["SHAMAN_Enhancement"] = "Interface\\Icons\\Spell_Nature_LightningShield",
    ["SHAMAN_Restoration"] = "Interface\\Icons\\Spell_Nature_HealingWaveGreater",
    -- Druid
    ["DRUID_Balance"] = "Interface\\Icons\\Spell_Nature_StarFall",
    ["DRUID_Feral"] = "Interface\\Icons\\Ability_Racial_BearForm",
    ["DRUID_Restoration"] = "Interface\\Icons\\Spell_Nature_HealingTouch",
}
