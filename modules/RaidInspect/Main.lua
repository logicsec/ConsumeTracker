-- Raid Inspect Module
ConsumeTracker = ConsumeTracker or {}
ConsumeTracker.Modules = ConsumeTracker.Modules or {}
ConsumeTracker.Modules["RaidInspect"] = {}
local Module = ConsumeTracker.Modules["RaidInspect"]

Module.Label = "Raid Inspect"
Module.Icon = "Interface\\Icons\\INV_Misc_Spyglass_03"

-- Reference icon mappings from IconMappings.lua (with defensive fallback)
RaidInspect_Icons = RaidInspect_Icons or {}
Module.classColors = RaidInspect_Icons.classColors or {}
Module.raceIcons = RaidInspect_Icons.raceIcons or {}
Module.classIcons = RaidInspect_Icons.classIcons or {}
Module.specIcons = RaidInspect_Icons.specIcons or {}

-- Storage for raid member rows
Module.raidRows = {}

-- Inspection System
Module.inspectCache = {}      -- { [unitName] = { [slotId] = texture/link, ... } }
Module.inspectQueue = {}      -- { unitId, unitId, ... }
Module.lastInspectTime = 0
Module.INSPECT_INTERVAL = 1.0 -- Seconds between inspections to avoid throttling
Module.isInspectRunning = false

function Module:OnInitialize()
    -- Create update frame for inspection queue
    self.updateFrame = CreateFrame("Frame")
    self.updateFrame:Hide()
    self.updateFrame:SetScript("OnUpdate", function() self:OnUpdate(arg1) end)
    
    -- Register for inspection events
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:SetScript("OnEvent", function() self:OnInspectionEvent() end)
end

function Module:OnEnable(contentFrame)
    -- Called when this module is selected
    if not self.isBuilt then
        self:BuildUI(contentFrame)
        self.isBuilt = true
    end
    
    -- Register events
    self.eventFrame:RegisterEvent("INSPECT_TALENT_READY") -- Turtle/Vanilla+
    self.eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    
    -- Start queue processor
    self.updateFrame:Show()
    
    -- Refresh raid data when module is shown
    self:RefreshRaidData()
    
    if contentFrame.headerBg then contentFrame.headerBg:Show() end
end

function Module:OnDisable(contentFrame)
    -- Stop queue processor
    self.updateFrame:Hide()
    self.eventFrame:UnregisterAllEvents()
end

-- ===========================================
-- INSPECTION QUEUE LOGIC
-- ===========================================

function Module:QueueInspect(unitId)
    -- Avoid duplicates
    for _, unit in ipairs(self.inspectQueue) do
        if unit == unitId then return end
    end
    table.insert(self.inspectQueue, unitId)
end

function Module:OnUpdate(elapsed)
    -- Process queue
    if table.getn(self.inspectQueue) == 0 then return end
    
    local now = GetTime()
    if (now - self.lastInspectTime) < self.INSPECT_INTERVAL then return end
    
    -- Pop next unit
    local unitId = table.remove(self.inspectQueue, 1)
    
    -- Verify unit exists and is in range
    if UnitExists(unitId) and UnitIsVisible(unitId) and CheckInteractDistance(unitId, 1) then
        self.currentInspectUnit = unitId
        NotifyInspect(unitId)
        self.lastInspectTime = now
    else
        -- Re-queue if not visible? Or just skip? Skip for now to avoid stuck queue
    end
end

function Module:OnInspectionEvent()
    if event == "INSPECT_TALENT_READY" or event == "UNIT_INVENTORY_CHANGED" then
        if not self.currentInspectUnit then return end
        
        local unitId = self.currentInspectUnit
        local unitName = UnitName(unitId)
        if not unitName then return end
        
        -- Initialize cache entry
        if not self.inspectCache[unitName] then
            self.inspectCache[unitName] = {
                gear = {},
                ilvl = 0
            }
        end
        
        -- Scrape Gear
        local gearData = self.inspectCache[unitName].gear
        local links = self.inspectCache[unitName].links or {}
        self.inspectCache[unitName].links = links
        
        for slot = 1, 19 do -- 1-19 covers all visible slots
            local texture = GetInventoryItemTexture(unitId, slot)
            if texture then
                gearData[slot] = texture
                links[slot] = GetInventoryItemLink(unitId, slot)
            end
        end
        
        -- Update UI if this unit is visible
        self:RefreshRowForUnit(unitName)
        
        -- Clear current unit to be safe
        if event == "INSPECT_TALENT_READY" then
            self.currentInspectUnit = nil
        end
    end
end

function Module:RefreshRowForUnit(unitName)
    -- Find the row for this unit and update gear icons
    for _, row in ipairs(self.raidRows) do
        if row.unitName == unitName then
            self:UpdateRowGear(row, unitName)
            break
        end
    end
end

function Module:UpdateRowGear(row, unitName)
    local data = self.inspectCache[unitName]
    if not data or not data.gear then return end
    
    -- Slots 1-19 map to standard inventory slots
    -- We want to display specific slots, e.g., Head(1), Neck(2), Shoulder(3), Shirt(4), Chest(5), Waist(6), Legs(7), Feet(8), Wrist(9), Hands(10), Ring1(11), Ring2(12), Trinket1(13), Trinket2(14), Back(15), MainHand(16), OffHand(17), Ranged(18), Tabard(19)
    -- Let's display primary gear slots in order
    local displaySlots = {1, 2, 3, 15, 5, 9, 10, 6, 7, 8, 11, 12, 13, 14, 16, 17, 18} 
    
    for i, slotId in ipairs(displaySlots) do
        local btn = row.gearIcons[i]
        if btn then
            local texture = data.gear[slotId]
            local link = data.links and data.links[slotId]
            
            local icon = btn.icon or btn:GetNormalTexture()
            if texture then
                icon:SetTexture(texture)
                icon:SetAlpha(1.0)
                btn.link = link -- Store link on button
            else
                icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
                icon:SetAlpha(0.2)
                btn.link = nil
            end
        end
    end
end

function Module:BuildUI(parent)
    local moduleContent = parent

    -- Module Header Background
    local headerBg = moduleContent:CreateTexture(nil, "BACKGROUND")
    headerBg:SetTexture(0.15, 0.15, 0.15, 0.8)
    headerBg:SetPoint("TOPLEFT", moduleContent, "TOPLEFT", 0, -35)
    headerBg:SetPoint("TOPRIGHT", moduleContent, "TOPRIGHT", 0, 0)
    headerBg:SetHeight(34)
    moduleContent.headerBg = headerBg

    -- Module Header Title
    local moduleTitle = moduleContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    moduleTitle:SetText("Raid Inspect")
    moduleTitle:SetPoint("TOPLEFT", moduleContent, "TOPLEFT", 10, -10)
    moduleTitle:SetTextColor(1, 0.82, 0)

    -- Helper: Create Sub Tab
    local function CreateSubTab(tabParent, id, text, xOffset)
        local tab = CreateFrame("Button", "RaidInspect_SubTab_" .. id, tabParent)
        tab:SetWidth(100)
        tab:SetHeight(24)
        tab:SetPoint("TOPLEFT", tabParent, "TOPLEFT", xOffset, -40)

        local tabText = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tabText:SetPoint("CENTER", tab, "CENTER", 0, 0)
        tabText:SetText(text)
        tabText:SetTextColor(0.6, 0.6, 0.6)
        tab.text = tabText

        local activeLine = tab:CreateTexture(nil, "OVERLAY")
        activeLine:SetTexture(1, 0.82, 0, 1)
        activeLine:SetHeight(2)
        activeLine:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, 0)
        activeLine:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", 0, 0)
        activeLine:Hide()
        tab.activeLine = activeLine

        return tab
    end

    -- Create Sub Tabs
    local subTabs = {}
    subTabs[1] = CreateSubTab(moduleContent, 1, "Equipment", 10)
    subTabs[2] = CreateSubTab(moduleContent, 2, "Talents", 115)
    moduleContent.subTabs = subTabs

    -- Tab Content Frames
    moduleContent.tabFrames = {}
    
    local contentWidth = 590
    local contentHeight = 420
    local contentX = 10
    local contentY = -70

    local function CreateTabFrame(id)
        local f = CreateFrame("Frame", nil, moduleContent)
        f:SetWidth(contentWidth)
        f:SetHeight(contentHeight)
        f:SetPoint("TOPLEFT", moduleContent, "TOPLEFT", contentX, contentY)
        f:Hide()
        moduleContent.tabFrames[id] = f
        return f
    end

    local equipmentFrame = CreateTabFrame(1)
    local talentsFrame = CreateTabFrame(2)

    -- Tab switching logic
    local function ShowSubTab(tabId)
        for i, tab in ipairs(subTabs) do
            if i == tabId then
                tab.text:SetTextColor(1, 0.82, 0)
                tab.activeLine:Show()
                moduleContent.tabFrames[i]:Show()
            else
                tab.text:SetTextColor(0.6, 0.6, 0.6)
                tab.activeLine:Hide()
                moduleContent.tabFrames[i]:Hide()
            end
        end
    end

    subTabs[1]:SetScript("OnClick", function() ShowSubTab(1) end)
    subTabs[2]:SetScript("OnClick", function() ShowSubTab(2) end)

    -- Build Equipment Tab
    self:BuildEquipmentContent(equipmentFrame)
    
    -- Build Talents Tab
    self:BuildTalentsContent(talentsFrame)

    -- Show Equipment tab by default
    ShowSubTab(1)
end

function Module:BuildEquipmentContent(parent)
    -- Scroll Frame
    local scrollFrame = CreateFrame("ScrollFrame", "RaidInspect_EquipScrollFrame", parent)
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 0)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function()
        local delta = arg1
        local current = this:GetVerticalScroll()
        local maxScroll = this.maxScroll or 0
        local newScroll = math.max(0, math.min(current - (delta * 30), maxScroll))
        this:SetVerticalScroll(newScroll)
    end)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(570)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)
    
    parent.scrollFrame = scrollFrame
    parent.scrollChild = scrollChild
    self.equipmentScrollChild = scrollChild

    -- "Not in Raid" message
    local notInRaidText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    notInRaidText:SetPoint("CENTER", parent, "CENTER", 0, 0)
    notInRaidText:SetText("Not in a raid group\n\nJoin a raid to see members")
    notInRaidText:SetTextColor(0.5, 0.5, 0.5)
    notInRaidText:Hide()
    self.notInRaidText = notInRaidText
end

function Module:GetRaidMembers()
    local members = {}
    local numRaid = GetNumRaidMembers()
    
    if numRaid == 0 then
        return members
    end
    
    for i = 1, numRaid do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
        
        if name then
            local unitId = "raid" .. i
            local race = UnitRace(unitId)
            local guildName = GetGuildInfo(unitId) or ""
            local sex = UnitSex(unitId) -- 1=unknown, 2=male, 3=female
            local gender = "Male"
            if sex == 3 then gender = "Female" end
            
            table.insert(members, {
                name = name,
                guild = guildName,
                class = fileName or "WARRIOR", -- fileName is the uppercase class token
                race = race or "Unknown",
                gender = gender,
                level = level or 60,
                online = online,
                unitId = unitId,
            })
        end
    end
    
    -- Sort by class for organization
    table.sort(members, function(a, b)
        if a.class == b.class then
            return a.name < b.name
        end
        return a.class < b.class
    end)
    
    return members
end

function Module:RefreshRaidData()
    if not self.equipmentScrollChild then return end
    
    local scrollChild = self.equipmentScrollChild
    
    -- Clear existing rows
    for _, row in ipairs(self.raidRows) do
        row:Hide()
    end
    self.raidRows = {}
    
    local members = self:GetRaidMembers()
    
    if table.getn(members) == 0 then
        self.notInRaidText:Show()
        scrollChild:SetHeight(1)
        return
    end
    
    self.notInRaidText:Hide()
    
    local rowHeight = 36
    local gearSlots = 16
    local gearIconSize = 20
    local gearSpacing = 2
    
    for i, player in ipairs(members) do
        local row = CreateFrame("Frame", nil, scrollChild)
        row:SetWidth(570)
        row:SetHeight(rowHeight)
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -((i-1) * rowHeight))
        
        -- Class-colored gradient background
        local color = self.classColors[player.class] or {0.5, 0.5, 0.5}
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(row)
        bg:SetTexture("Interface\\Buttons\\WHITE8x8")
        bg:SetGradientAlpha("HORIZONTAL", color[1], color[2], color[3], 0.6, color[1], color[2], color[3], 0)
        
        -- Dim if offline
        if not player.online then
            bg:SetGradientAlpha("HORIZONTAL", 0.3, 0.3, 0.3, 0.6, 0.3, 0.3, 0.3, 0)
        end
        
        -- Name-Guild
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("LEFT", row, "LEFT", 5, 0)
        nameText:SetWidth(100)
        nameText:SetJustifyH("LEFT")
        
        local displayName = player.name
        if player.guild and player.guild ~= "" then
            displayName = player.name .. "-\n" .. player.guild
        end
        nameText:SetText(displayName)
        
        if player.online then
            nameText:SetTextColor(color[1], color[2], color[3])
        else
            nameText:SetTextColor(0.5, 0.5, 0.5)
        end
        
        -- Race Icon (gender-specific with fallback)
        local raceGenderKey = player.race .. "_" .. player.gender
        local raceIcon = row:CreateTexture(nil, "ARTWORK")
        raceIcon:SetWidth(24)
        raceIcon:SetHeight(24)
        raceIcon:SetPoint("LEFT", row, "LEFT", 110, 0)
        raceIcon:SetTexture(self.raceIcons[raceGenderKey] or self.raceIcons[player.race] or "Interface\\Icons\\INV_Misc_QuestionMark")
        
        -- Class Icon
        local classIcon = row:CreateTexture(nil, "ARTWORK")
        classIcon:SetWidth(24)
        classIcon:SetHeight(24)
        classIcon:SetPoint("LEFT", raceIcon, "RIGHT", 4, 0)
        classIcon:SetTexture(self.classIcons[player.class] or "Interface\\Icons\\INV_Misc_QuestionMark")
        
        -- Spec Icon (placeholder - would need inspect for real data)
        local specIcon = row:CreateTexture(nil, "ARTWORK")
        specIcon:SetWidth(24)
        specIcon:SetHeight(24)
        specIcon:SetPoint("LEFT", classIcon, "RIGHT", 4, 0)
        specIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        
        -- Level
        local levelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        levelText:SetPoint("LEFT", specIcon, "RIGHT", 8, 0)
        levelText:SetText("L" .. player.level)
        levelText:SetTextColor(1, 0.82, 0)
        
        -- Gear Icons (Horizontal Scroll)
        local gearStartX = 250
        local availableWidth = 570 - gearStartX - 5
        
        -- Create scroll frame for gear
        local gearScroll = CreateFrame("ScrollFrame", nil, row)
        gearScroll:SetPoint("TOPLEFT", row, "TOPLEFT", gearStartX, 0)
        gearScroll:SetWidth(availableWidth)
        gearScroll:SetHeight(rowHeight)
        
        -- Create container for icons
        local gearContainer = CreateFrame("Frame", nil, gearScroll)
        gearContainer:SetWidth(1) -- Will expand
        gearContainer:SetHeight(rowHeight)
        gearScroll:SetScrollChild(gearContainer)
        
        -- Enable mouse wheel for horizontal scroll
        gearScroll:EnableMouseWheel(true)
        gearScroll:SetScript("OnMouseWheel", function()
            local current = this:GetHorizontalScroll()
            local delta = arg1
            local new = math.max(0, current - (delta * 20))
            this:SetHorizontalScroll(new)
        end)
        
        row.gearIcons = {}
        row.unitName = player.name
        
        for slot = 1, 17 do -- 17 display slots
            local gearBtn = CreateFrame("Button", nil, gearContainer)
            gearBtn:SetWidth(gearIconSize)
            gearBtn:SetHeight(gearIconSize)
            gearBtn:SetPoint("LEFT", gearContainer, "LEFT", (slot-1) * (gearIconSize + gearSpacing), 0)
            
            local icon = gearBtn:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(gearBtn)
            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            icon:SetAlpha(0.3)
            gearBtn.icon = icon
            
            -- Tooltip scripts
            gearBtn:SetScript("OnEnter", function()
                if this.link then
                    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                    
                    -- Extract the "item:1234:..." part from the full link
                    -- Full link: |cff...|Hitem:1234...|h[Name]|h|r
                    local _, _, itemString = string.find(this.link, "^|c%x+|H(.+)|h%[.*%]")
                    
                    if itemString then
                        GameTooltip:SetHyperlink(itemString)
                    else
                        -- Fallback for standard links
                        GameTooltip:SetHyperlink(this.link)
                    end
                    GameTooltip:Show()
                end
            end)
            gearBtn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            
            row.gearIcons[slot] = gearBtn
        end
        
        -- Set container width based on icons
        gearContainer:SetWidth(17 * (gearIconSize + gearSpacing))
        
        table.insert(self.raidRows, row)
        
        -- Queue inspection if online
        if player.online then
            -- Check cache first
            if self.inspectCache[player.name] then
                self:UpdateRowGear(row, player.name)
            end
            
            -- If it's me, scrape immediately (no inspect needed)
            if player.name == UnitName("player") then
                -- Initialize cache entry
                local unitName = player.name
                if not self.inspectCache[unitName] then
                    self.inspectCache[unitName] = { gear = {}, links = {}, ilvl = 0 }
                end
                
                local gearData = self.inspectCache[unitName].gear
                local links = self.inspectCache[unitName].links
                
                for slot = 1, 19 do
                    local texture = GetInventoryItemTexture("player", slot)
                    if texture then
                        gearData[slot] = texture
                        links[slot] = GetInventoryItemLink("player", slot)
                    end
                end
                
                self:UpdateRowGear(row, unitName)
            else
                -- Queue for fresh data (or initially)
                self:QueueInspect(player.unitId)
            end
        end
    end
    
    -- Update scroll child height
    scrollChild:SetHeight(table.getn(members) * rowHeight)
    
    -- Calculate max scroll
    local scrollFrame = scrollChild:GetParent()
    local visibleHeight = scrollFrame:GetHeight()
    local contentHeight = scrollChild:GetHeight()
    scrollFrame.maxScroll = math.max(0, contentHeight - visibleHeight)
end

function Module:BuildTalentsContent(parent)
    local placeholder = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    placeholder:SetPoint("CENTER", parent, "CENTER", 0, 0)
    placeholder:SetText("Talents Tab\n(Coming Soon)")
    placeholder:SetTextColor(0.5, 0.5, 0.5)
end
