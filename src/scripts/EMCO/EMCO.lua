--- Embeddable Multi Console Object.
-- This is essentially YATCO, but with some tweaks, updates, and it returns an object
-- similar to Geyser so that you can a.) have multiple of them and b.) easily embed it
-- into your existing UI as you would any other Geyser element.
-- @module EMCO
EMCO = Geyser.Container:new({
  name = "TabbedConsoleClass",
})

function EMCO:readYATCO()
  local config
  if demonnic and demonnic.chat and demonnic.chat.config then 
    config = demonnic.chat.config
  else
    cecho("<white>(<blue>EMCO<white>)<reset> Could not find demonnic.chat.config, nothing to convert\n")
    return
  end
  local constraints = "EMCO:new({\n"
  constraints = string.format("%s  x = %d,\n", constraints, demonnic.chat.container.get_x())
  constraints = string.format("%s  y = %d,\n", constraints, demonnic.chat.container.get_y())
  constraints = string.format("%s  width = %d,\n", constraints, demonnic.chat.container.get_width())
  constraints = string.format("%s  height = %d,\n", constraints, demonnic.chat.container.get_height())
  if config.timestamp then
    constraints = string.format("%s  timestamp = true,\n  timestampFormat = \"%s\",\n", constraints, config.timestamp)
  else
    constraints = string.format("%s  timestamp = false,\n", constraints)
  end
  if config.timestampColor then
    constraints = string.format("%s  customTimestampColor = true,\n", constraints)
  else
    constraints = string.format("%s  customTimestampColor = false,\n", constraints)
  end
  if config.timestampFG then
    constraints = string.format("%s  timestampFGColor = \"%s\",\n", constraints, config.timestampFG)
  end
  if config.timestampBG then
    constraints = string.format("%s  timestampBGColor = \"%s\",\n", constraints, config.timestampBG)
  end
  if config.channels then
    local channels = "consoles = {\n"
    for _,channel in ipairs(config.channels) do
      if _ == #config.channels then
        channels = string.format("%s    \"%s\"", channels, channel)
      else
        channels = string.format("%s    \"%s\",\n", channels, channel)
      end
    end
    channels = string.format("%s\n  },\n", channels)
    constraints = string.format([[%s  %s]], constraints, channels)
  end
  if config.Alltab then
    constraints = string.format("%s  allTab = true,\n", constraints)
    constraints = string.format("%s  allTabName = \"%s\",\n", constraints, config.Alltab)
  else
    constraints = string.format("%s  allTab = false,\n", constraints)
  end
  if config.Maptab and config.Maptab ~= "" then
    constraints = string.format("%s  mapTab = true,\n", constraints)
    constraints = string.format("%s  mapTabName = \"%s\",\n", constraints, config.Maptab)
  else
    constraints = string.format("%s  mapTab = false,\n", constraints)
  end
  constraints = string.format("%s  blink = %s,\n", constraints, tostring(config.blink))
  constraints = string.format("%s  blinkFromAll = %s,\n", constraints, tostring(config.blinkFromAll))
  if config.fontSize then
    constraints = string.format("%s  fontSize = %d,\n", constraints, config.fontSize)
  end
  constraints = string.format("%s  preserveBackground = %s,\n", constraints, tostring(config.preserveBackground))
  constraints = string.format("%s  gag = %s,\n", constraints, tostring(config.gag))
  constraints = string.format("%s  activeTabBGColor = \"<%s,%s,%s>\",\n", constraints, config.activeColors.r, config.activeColors.g, config.activeColors.b)
  constraints = string.format("%s  inactiveTabBGColor = \"<%s,%s,%s>\",\n", constraints, config.inactiveColors.r, config.inactiveColors.g, config.inactiveColors.b)
  constraints = string.format("%s  consoleColor = \"<%s,%s,%s>\",\n", constraints, config.windowColors.r, config.windowColors.g, config.windowColors.b)
  constraints = string.format("%s  activeTabFGColor = \"%s\",\n", constraints, config.activeTabText)
  constraints = string.format("%s  inactiveTabFGColor = \"%s\"", constraints, config.inactiveTabText)
  constraints = string.format("%s\n})", constraints)
  return constraints
end

--- Scans for the old YATCO configuration values and prints out a set of constraints to use.
-- with EMCO to achieve the same effect. Is just the invocation
function EMCO:miniConvertYATCO()
  local constraints = self:readYATCO()
  cecho("<white>(<blue>EMCO<white>)<reset> Found a YATCO config. Here are the constraints to use with EMCO(x,y,width, and height have been converted to their absolute values):\n\n")
  echo(constraints .. "\n")
end

--- Echos to the main console a script object you can add which will fully convert YATCO to EMCO.
-- This replaces the demonnic.chat variable with a newly created EMCO object, so that the main 
-- functions used to place information on the consoles (append(), cecho(), etc) should continue to
-- work in the user's triggers and events.
function EMCO:convertYATCO()
  local invocation = self:readYATCO()
  local header = [[
  <white>(<blue>EMCO<white>)<reset> Found a YATCO config. Make a new script, then copy and paste the following output into it.
  <white>(<blue>EMCO<white>)<reset> Afterward, uninstall YATCO (you can leave YATCOConfig until you're sure everything is right) and restart Mudlet
  <white>(<blue>EMCO<white>)<reset> If everything looks right, you can uninstall YATCOConfig. 


-- Copy everything below this line until the next line starting with --
demonnic = demonnic or {}
demonnic.chat = ]]
  cecho(string.format("%s%s\n--- End script\n", header, invocation))
end

function EMCO:checkTabPosition(position)
  if position == nil then
    return 0
  end
  return tonumber(position) or type(position)
end

function EMCO:checkTabName(tabName)
  if not tostring(tabName) then
    return "tabName as string expected, got" .. type(tabName)
  end
  tabName = tostring(tabName)
  if table.contains(self.consoles, tabName) then
    return "tabName must be unique, and we already have a tab named " .. tabName
  else
    return "clear"
  end
end

function EMCO:ae(funcName, message)
  error(string.format("%s: Argument Error: %s", funcName, message))
end

function EMCO:ce(funcName, message)
  error(string.format("%s:gg Constraint Error: %s", funcName, message))
end

--- Adds a tab to the EMCO object
-- @tparam string tabName the name of the tab to add
-- @tparam[opt] number position position in the tab switcher to put this tab
function EMCO:addTab(tabName, position)
  local funcName = "EMCO:addTab(tabName, position)"
  position = self:checkTabPosition(position)
  if type(position) == "string" then self:ae(funcName, "position as number expected, got " .. position) end
  local tabCheck = self:checkTabName(tabName)
  if tabCheck ~= "clear" then self:ae(funcName, tabCheck) end
  if position == 0 then
    table.insert(self.consoles, tabName)
    self:createComponentsForTab(tabName)
  else
    table.insert(self.consoles, position, tabName)
    self:reset()
  end
end

function EMCO:switchTab(tabName)
  local oldTab = self.currentTab
  if oldTab ~= tabName and oldTab ~= "" then 
    self.windows[oldTab]:hide()
    self.tabs[oldTab]:setStyleSheet(self.inactiveTabCSS)
    self.tabs[oldTab]:setColor(self.inactiveTabBGColor)
    self.tabs[oldTab]:echo(oldTab, self.inactiveTabFGColor, "c")
    if self.blink then 
      if self.allTab and tabName == self.allTabName then
        self.tabsToBlink = {}
      elseif self.tabsToBlink[tabName] then
        self.tabsToBlink[tabName] = nil
      end
    end
  end
  self.tabs[tabName]:setStyleSheet(self.activeTabCSS)
  self.tabs[tabName]:setColor(self.activeTabBGColor)
  self.tabs[tabName]:echo(tabName, self.activeTabFGColor, "c")
  if oldTab and self.windows[oldTab] then
    self.windows[oldTab]:hide()
  end
  self.windows[tabName]:show()
  self.currentTab = tabName
end

function EMCO:createComponentsForTab(tabName)
  local tab = Geyser.Label:new({
    name = string.format("%sTab%s", self.name, tabName)
  }, self.tabBox)
  tab:echo(tabName, self.inactiveTabFGColor, 'c')
  -- use the inactive CSS. It's "" if unset, which is ugly, but
  tab:setStyleSheet(self.inactiveTabCSS)
  -- set the BGColor if set. if the CSS is set it overrides the setColor, but if it's "" then the setColor actually covers that.
  -- and we set a default for the inactiveBGColor
  tab:setColor(self.inactiveTabBGColor)
  tab:setClickCallback("EMCOHelper.switchTab", nil, string.format("%s+%s",self.name, tabName))
  self.tabs[tabName] = tab
  local window
  local windowConstraints = {
    x = 1,
    y = 1,
    height = "-2px",
    width = "100%",
    name = string.format("%sWindow%s", self.name, tabName)
  }
  local parent = self.consoleContainer
  if self.mapTab and tabName == self.mapTabName then
    window = Geyser.Mapper:new(windowConstraints, parent)
  else
    window = Geyser.MiniConsole:new(windowConstraints, parent)
    window:setFontSize(self.fontSize)
    window:setColor(self.consoleColor)
    if self.autoWrap then
      window:enableAutoWrap()
    else
      window:setWrap(self.wrapAt)
    end
    if self.scrollbars then
      window:enableScrollBar()
    else
      window:disableScrollBar()
    end
  end
  self.windows[tabName] = window
  window:hide()
end

--- resets the object, redrawing everything
function EMCO:reset()
  self:createContainers()
  for _,tabName in ipairs(self.consoles) do
    self:createComponentsForTab(tabName)
  end
  local default
  if self.currentTab == "" then
    default = self.allTabName or self.consoles[1]
  else
    default = self.currentTab
  end
  self:switchTab(default)
end

function EMCO:createContainers()
  self.tabBoxLabel = Geyser.Label:new({
    x=0,
    y=0,
    width = "100%",
    height = tostring(tonumber(self.tabHeight) + 2) .. "px",
    name = self.name .. "TabBoxLabel"
  }, self)
  self.tabBox = Geyser.HBox:new({
    x=0,
    y=0,
    width = "100%",
    height = "100%",
    name = self.name .. "TabBox"
  }, self.tabBoxLabel)
  self.tabBoxLabel:setStyleSheet(self.tabBoxCSS)
  self.tabBoxLabel:setColor(self.tabBoxColor)
  
  local heightPlusGap = tonumber(self.tabHeight) + tonumber(self.gap)
  self.consoleContainer = Geyser.Label:new({
    x = 0,
    y = tostring(heightPlusGap) .. "px",
    width = "100%",
    height = "-" .. tostring(heightPlusGap) .. "px",
    name = self.name .. "ConsoleContainer"
  }, self)
  self.consoleContainer:setStyleSheet(self.consoleContainerCSS)
  self.consoleContainer:setColor(self.consoleContainerColor)
end

function EMCO:stripTimeChars(str)
  return string.gsub(string.trim(str), '[hHmMszZaApPdy:. ]', '')
end

--- Expands boolean definitions to be more flexible.
-- <br>True values are "true", "yes", "0", 0, and true
-- <br>False values are "false", "no", "1", 1, false, and nil
-- @param bool item to test for truthiness
function EMCO:fuzzyBoolean(bool)
  if type(bool) == "boolean" or bool == nil then
    return bool
  elseif tostring(bool) then
    local truth = {
      "yes",
      "true",
      "0"
    }
    local untruth = {
      "no",
      "false",
      "1"
    }
    local boolstr = tostring(bool)
    if table.contains(truth, boolstr) then
      return true
    elseif table.contains(untruth, boolstr) then
      return false
    else
      return nil
    end
  else
    return nil
  end
end

--- enables custom colors for the timestamp, if displayed
function EMCO:enableCustomTimestampColor()
  self.customTimestampColor = true
end

--- disables custom colors for the timestamp, if displayed
function EMCO:disableCustomTimestampColor()
  self.customTimestampColor = false
end

--- enables the display of timestamps
function EMCO:enableTimestamp()
  self.timestamp = true
end

--- disables the display of timestamps
function EMCO:disableTimestamp()
  self.timestamp = false
end

--- Sets the formatting for the timestamp, if enabled
-- @tparam string format Format string which describes the display of the timestamp. See: https://wiki.mudlet.org/w/Manual:Lua_Functions#getTime
function EMCO:setTimestampFormat(format)
  local funcName = "EMCO:setTimestampFormat(format)"
  local strippedFormat = self:stripTimeChars(format)
  if strippedFormat ~= "" then
    self:ae(funcName, "format contains invalid time format characters. Please see https://wiki.mudlet.org/w/Manual:Lua_Functions#getTime for formatting information")
  else
    self.timestampFormat = format
  end
end

--- Sets the background color for the timestamp, if customTimestampColor is enabled.
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setTimestampBGColor(color)
  self.timestampBGColor = color
end
--- Sets the foreground color for the timestamp, if customTimestampColor is enabled.
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setTimestampFGColor(color)
  self.timestampFGColor = color
end

--- Sets the 'all' tab name.
-- <br>This is the name of the tab itself
-- @tparam string allTabName name of the tab to use as the all tab. Must be a tab which exists in the object.
function EMCO:setAllTabName(allTabName)
  local funcName = "EMCO:setAllTabName(allTabName)"
  local allTabNameType = type(allTabName)
  if allTabNameType ~= "string" then self:ae(funcName, "allTabName expected as string, got" .. allTabNameType) end
  if not table.contains(self.consoles, allTabName) then self:ae(funcName, "allTabName must be the name of one of the console tabs. Valid options are: " .. table.concat(self.containers, ",")) end
  self.allTabName = allTabName
end

--- Enables use of the 'all' tab
function EMCO:enableAllTab()
  self.allTab = true
end

--- Disables use of the 'all' tab
function EMCO:disableAllTab()
  self.allTab = false
end

--- Enables tying the Mudlet Mapper to one of the tabs.
-- <br>mapTabName must be set, or this will error. Forces a redraw of the entire object
function EMCO:enableMapTab()
  local funcName = "EMCO:enableMapTab()"
  if not self.mapTabName then
    error(funcName .. ": cannot enable the map tab, mapTabName not set. try running :setMapTabName(mapTabName) first with the name of the tab you want to bind the map to")
  end
  self.mapTab = true
  self:reset()
end

--- disables binding the Mudlet Mapper to one of the tabs.
-- <br>CAUTION: this may have unexpected behaviour, as you can only open one Mapper console per profile
-- so you can't really unbind it. Binding of the Mudlet Mapper is best decided at instantiation.
function EMCO:disableMapTab()
  self.mapTab = false
end

--- sets the name of the tab to bind the Mudlet Map.
-- <br>Forces a redraw of the object
-- <br>CAUTION: Mudlet only allows one Map object to be open at one time, so if you are going to attach the map to an object
-- you should probably do it at instantiation.
-- @tparam string mapTabName name of the tab to connect the Mudlet Map to.
function EMCO:setMapTabName(mapTabName)
  local funcName = "EMCO:setMapTabName(mapTabName)"
  local mapTabNameType = type(mapTabName)
  if mapTabNameType ~= "string" then 
    self:ae(funcName, "mapTabName as string expected, got" .. mapTabNameType) 
  end
  if not table.contains(self.consoles, mapTabName) and mapTabName ~= "" then 
    self:ae(funcName, "mapTabName must be one of the existing console tabs. Current tabs are: " .. table.concat(self.consoles, ","))
  end
  self.mapTabName = mapTabName    
end

--- Enables tab blinking even if you're on the 'all' tab
function EMCO:enableBlinkFromAll()
  self.enableBlinkFromAll = true
end

--- Disables tab blinking when you're on the 'all' tab
function EMCO:disableBlinkFromAll()
  self.enableBlinkFromAll = false
end

--- Enables gagging of the line passed in to :append(tabName)
function EMCO:enableGag()
  self.gag = true
end

--- Disables gagging of the line passed in to :append(tabName)
function EMCO:disableGag()
  self.gag = false
end

--- Enables tab blinking when new information comes in to an inactive tab
function EMCO:enableBlink()
  self.blink = true
end

--- Disables tab blinking when new information comes in to an inactive tab
function EMCO:disableBlink()
  self.blink = false
end

--- Enables preserving the chat's background over the background of an incoming :append()
function EMCO:enablePreserveBackground()
  self.preserveBackground = true
end

--- Enables preserving the chat's background over the background of an incoming :append()
function EMCO:disablePreserveBackground()
  self.preserveBackground = false
end

--- Sets how long in seconds to wait between blinks
-- @tparam number blinkTime time in seconds to wait between blinks
function EMCO:setBlinkTime(blinkTime)
  local funcName = "EMCO:setBlinkTime(blinkTime)"
  local blinkTimeNumber = tonumber(blinkTime)
  if not blinkTimeNumber then
    self:ae(funcName, "blinkTime as number expected, got ".. type(blinkeTime))
  else
    self.blinkTime = blinkTimeNumber
    if self.blinkTimerID then
      killTimer(self.blinkTimerID)
    end
    self.blinkTimerID = tempTimer(blinkTimeNumber, function() self:blink() end, true)
  end
end

function EMCO:doBlink()
  if self.hidden or self.auto_hidden or not self.blink then
    return
  end
  for tab,_ in pairs(self.tabsToBlink) do
    self.tabs[tab]:flash()
  end
end

--- Sets the font size of the attached consoles
-- @tparam number fontSize font size for attached consoles
function EMCO:setFontSize(fontSize)
  local funcName = "EMCO:setFontSize(fontSize)"
  local fontSizeNumber = tonumber(fontSize)
  local fontSizeType = type(fontSize)
  if not fontSizeNumber then
    self:ae(funcName, "fontSize as number expected, got " .. fontSizeType)
  else
    self.fontSize = fontSizeNumber
    for _,tabName in ipairs(self.consoles) do
      if self.mapTab and tabName == self.mapTabName then
        -- skip this one
      else
        local window = self.windows[tabName]
        window:setFontSize(fontSizeNumber)
      end
    end
  end
end

function EMCO:adjustTabNames()
  for _,console in ipairs(self.consoles) do
    if console == self.currentTab then
      self.tabs[console]:echo(console, self.activTabFGColor, 'c')
    else
      self.tabs[console]:echo(console, self.inactiveTabFGColor, 'c')
    end
  end
end

function EMCO:adjustTabBackgrounds()
  for _, console in ipairs(self.consoles) do
    local tab = self.tabs[console]
    if console == self.currentTab then
      tab:setStyleSheet(self.activeTabCSS)
      tab:setColor(self.activeBGColor)
    else
      tab:setStyleSheet(self.inactiveTabCSS)
      tab:setColor(self.inactiveBGColor)
    end
  end
end

--- Sets the FG color for the active tab
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setActiveTabFGColor(color)
  self.activeTabFGColor = color
  self:adjustTabNames()
end

--- Sets the FG color for the inactive tab
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setInactiveTabFGColor(color)
  self.inactiveTabFGColor = color
  self:adjustTabNames()
end

--- Sets the BG color for the active tab.
-- <br>NOTE: If you set CSS for the active tab, it will override this setting. 
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setActiveTabBGColor(color)
  self.activeTabBGColor = color
  self:adjustTabBackgrounds()
end

--- Sets the BG color for the inactive tab.
-- <br>NOTE: If you set CSS for the inactive tab, it will override this setting.
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setInactiveTabBGColor(color)
  self.inactiveTabBGColor = color
  self:adjustTabBackgrounds()
end

--- Sets the BG color for the consoles attached to this object
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setConsoleColor(color)
  self.consoleColor = color
  self:adjustConsoleColors()
end

function EMCO:adjustConsoleColors()
  for _,console in ipairs(self.consoles) do
    if self.mapTab and self.mapTabName == console then
      -- skip Map
    else
      self.windows[console]:setColor(self.consoleColor)
    end
  end
end

--- Sets the CSS to use for the tab box which contains the tabs for the object
-- @tparam string css The css styling to use for the tab box
function EMCO:setTabBoxCSS(css)
  local funcName = "EMCHO:setTabBoxCSS(css)"
  local cssType = type(css)
  if cssType ~= "string" then
    self:ae(funcName, "css as string expected, got " .. cssType)
  else
    self.tabBoxCSS = css
    self:adjustTabBoxBackground()
  end
end

--- Sets the color to use for the tab box background
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setTabBoxColor(color)
  self.tabBoxColor = color
  self:adjustTabBoxBackground()
end

function EMCO:adjustTabBoxBackground()
    self.tabBoxLabel:setStyleSheet(self.tabBoxCSS)
    self.tabBoxLabel:setColor(self.tabBoxColor)
end

--- Sets the color for the container which holds the consoles attached to this object.
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setConsoleContainerColor(color)
  self.consoleContainerColor = color
  self:adjustConsoleContainerBackground()
end

--- Sets the CSS to use for the container which holds the consoles attached to this object
-- @tparam string css CSS to use for the container
function EMCO:setConsoleContainerCSS(css)
  self.consoleContainerCSS = css
  self:adjustConsoleContainerBackground()
end

function EMCO:adjustConsoleContainerBackground()
  self.consoleContainer:setStyleSheet(self.consoleContainerCSS)
  self.consoleContainer:setColor(self.consoleContainerColor)
end

--- Sets the amount of space to use between the tabs and the consoles
-- @tparam number gap Number of pixels to keep between the tabs and consoles
function EMCO:setGap(gap)
  local gapNumber = tonumber(gap)
  local funcName = "EMCO:setGap(gap)"
  local gapType = type(gap)
  if not gapNumber then
    self:ae(funcName, "gap expected as number, got " .. gapType)
  else
    self.gap = gapNumber
    self:reset()
  end
end

--- Sets the height of the tabs in pixels
-- @tparam number tabHeight the height of the tabs for the object, in pixels
function EMCO:setTabHeight(tabHeight)
  local tabHeightNumber = tonumber(tabHeight)
  local funcName = "EMCO:setTabHeight(tabHeight)"
  local tabHeightType = type(tabHeight)
  if not tabHeightNumber then
    self:ae(funcName, "tabHeight as number expected, got ".. tabHeightType)
  else
    self.tabHeight = tabHeightNumber
    self:reset()
  end
end

--- Enables autowrap for the object, and by extension all attached consoles.
-- <br>To enable autoWrap for a specific miniconsole only, call myEMCO.windows[tabName]:enableAutoWrap()
-- but be warned if you do this it may be overwritten by future calls to EMCO:enableAutoWrap() or :disableAutoWrap()
function EMCO:enableAutoWrap()
  self.autoWrap = true
  for _,console in ipairs(self.consoles) do
    if self.mapTab and console == self.mapTabName then
      -- skip the map
    else
      self.windows[console]:enableAutoWrap()
    end
  end
end

--- Disables autowrap for the object, and by extension all attached consoles.
-- <br>To disable autoWrap for a specific miniconsole only, call myEMCO.windows[tabName]:disableAutoWrap()
-- but be warned if you do this it may be overwritten by future calls to EMCO:enableAutoWrap() or :disableAutoWrap()
function EMCO:disableAutoWrap()
  self.autoWrap = false
  for _,console in ipairs(self.consoles) do
    if self.mapTab and self.mapTabName == console then
      -- skip Map
    else
      self.windows[console]:disableAutoWrap()
    end
  end
end

--- Sets the number of characters to wordwrap the attached consoles at.
-- <br>it is generally recommended to make use of autoWrap unless you need
-- a specific width for some reason
function EMCO:setWrap(wrapAt)
  local funcName = "EMCO:setWrap(wrapAt)"
  local wrapAtNumber = tonumber(wrapAt)
  local wrapAtType = type(wrapAt)
  if not wrapAtNumber then
    self:ae(funcName, "wrapAt as number expect, got " .. wrapAtType)
  else
    self.wrapAt = wrapAtNumber
    for _,console in ipairs(self.consoles) do
      if self.mapTab and self.mapTabName == console then
        -- skip the Map
      else
        self.windows[console]:setWrap(wrapAtNumber)
      end
    end
  end
end

--- Appends the current line from the MUD to a tab.
-- <br>depending on this object's configuration, may gag the line
-- <br>depending on this object's configuration, may gag the next prompt
-- @tparam string tabName The name of the tab to append the line to
function EMCO:append(tabName)
  local funcName = "EMCO:append(tabName)"
  local tabNameType = type(tabName)
  local validTab = table.contains(self.consoles, tabName)
  if tabNameType ~= "string" then 
    self:ae(funcName, "tabName as string expected, got ".. tabNameType)
  elseif not validTab then
    self:ae(funcNAme, "tabName must be a tab which is contained in this object. Valid tabnames are: " .. table.concat(self.consoles, ","))
  end
  self:xEcho(tabName, nil, 'a')
end

function EMCO:checkEchoArgs(funcName, tabName, message)
  local tabNameType = type(tabName)
  local messageType = type(message)
  local validTabName = table.contains(self.consoles, tabName)
  if tabNameType ~= "string" then
    self:ae(funcName, "tabName as string expected, got " .. tabNameType)
  elseif messageType ~= "string" then
    self:ae(funcName, "message as string expected, got " .. messageType)
  elseif not validTabName then
    self:ae(funcName, "tabName must be the name of a tab attached to this object. Valid names are: " .. table.concat(self.consoles, ","))
  end
end

function EMCO:xEcho(tabName, message, xtype)
  if self.mapTab and self.mapTabName == tabName then
    error("You cannot send text to the Map tab")
  end
  local console = self.windows[tabName]
  local allTab,ofr,ofg,ofb,obr,obg,obb
  if self.allTab then
    allTab = self.windows[self.allTabName]
  end
  if xtype == "a" then
    selectCurrentLine()
    ofr,ofg,ofb = getFgColor()
    obr,obg,obb = getBgColor()
    if self.preserveBackground then
      local r,g,b = Geyser.Color.parse(self.consoleColor)
      setBgColor(r,g,b)
    end
    copy()    
  else
    ofr,ofg,ofb = Geyser.Color.parse("white")
    obr,obg,obb = Geyser.Color.parse(self.consoleColor)
  end
  if self.timestamp then
    local colorString = ""
    if self.customTimestampColor then
      local tfr,tfg,tfb = Geyser.Color.parse(self.timestampFGColor)
      local tbr,tbg,tbb = Geyser.Color.parse(self.timestampBGColor)
      colorString = string.format("<%s,%s,%s:%s,%s,%s>", tfr,tfg,tfb,tbr,tbg,tbb)
    else
      colorString = string.format("<%s,%s,%s:%s,%s,%s>", ofr,ofg,ofb,obr,obg,obb)
    end
    local timestamp = getTime(true, self.timestampFormat)
    local fullTimestamp = string.format("%s%s<r> ", colorString, timestamp)
    console:decho(fullTimestamp)
    if self.allTab and tabName ~= self.allTabName then
      allTab:decho(fullTimestamp)
    end
  end
  if self.blink and tabName ~= self.currentTab then
    if not (self.allTabName == self.currentTab and not self.blinkFromAll) then
      self.tabsToBlink[tabName] = true
    end
  end
  if xtype == "a" then
    console:appendBuffer()
    if self.allTab then
      allTab:appendBuffer()
    end
    if self.gag then
      deleteLine()
      if self.gagPrompt then
        tempPromptTrigger(function() deleteLine() end, 1)
      end
    end
  elseif xtype == "c" then
    console:cecho(message)
    if self.allTab then allTab:cecho(message) end  
  elseif xtype == "d" then
    console:decho(message)
    if self.allTab then allTab:decho(message) end
  elseif xtype == "h" then
    console:hecho(message)
    if self.allTab then allTab:hecho(message) end
  elseif xtype == "e" then
    console:echo(message)
    if self.allTab then allTab:echo(message) end
  end
  if self.blankLine then
    console:echo("\n")
    if self.allTab then allTab:echo("\n") end
  end
end

--- cecho to a tab, maintaining functionality
-- @tparam string tabName the name of the tab to cecho to
-- @tparam string message the message to cecho to that tab's console
function EMCO:cecho(tabName, message)
  local funcName = "EMCO:cecho(tabName, message)"
  self:checkEchoArgs(funcName, tabName, message)
  self:xEcho(tabName, message, 'c')
end

--- decho to a tab, maintaining functionality
-- @tparam string tabName the name of the tab to decho to
-- @tparam string message the message to decho to that tab's console
function EMCO:decho(tabName, message)
  local funcName = "EMCO:decho(console, message)"
  self:checkEchoArgs(funcName, tabName, message)
  self:xEcho(tabName, message, 'd')
end

--- hecho to a tab, maintaining functionality
-- @tparam string tabName the name of the tab to hecho to
-- @tparam string message the message to hecho to that tab's console
function EMCO:hecho(tabName, message)
  local funcName = "EMCO:hecho(console, message)"
  self:checkEchoArgs(funcName, tabName, message)
  self:xEcho(tabName, message, 'h')
end

--- echo to a tab, maintaining functionality
-- @tparam string tabName the name of the tab to echo to
-- @tparam string message the message to echo to that tab's console
function EMCO:echo(tabName, message)
  local funcName = "EMCO:echo(console, message)"
  self:checkEchoArgs(funcName, tabName, message)
  self:xEcho(tabName, message, 'e')
end

--- Enable placing a blank line between all messages.
function EMCO:enableBlankLine()
  self.blankLine = true
end

--- Enable placing a blank line between all messages.
function EMCO:disableBlankLine()
  self.blankLine = false
end

--- Enable scrollbars for the miniconsoles
function EMCO:enableScrollbars()
  self.scrollbars = true
  self:adjustScrollbars()
end

--- Disable scrollbars for the miniconsoles
function EMCO:disableScrollbars()
  self.scrollbars = false
  self:adjustScrollbars()
end

function EMCO:adjustScrollbars()
  for _,console in ipairs(self.consoles) do
    if self.mapTab and self.mapTabName == console then
      -- skip the Map tab
    else
      if self.scrollbars then
        self.windows[console]:enableScrollBar()
      else
        self.windows[console]:disableScrollBar()
      end
    end
  end
end

EMCOHelper = EMCOHElper or {}
EMCOHelper.items = EMCOHelper.items or {}
function EMCOHelper:switchTab(designator)
  local args = string.split(designator, "+")
  local emcoName = args[1]
  local tabName = args[2]
  for _,emco in ipairs(EMCOHelper.items) do
    if emco.name == emcoName then
      emco:switchTab(tabName)
      return
    end
  end
end

EMCO.parent = Geyser.Container

--- Creates a new Embeddable Multi Console Object.
-- <br>see https://github.com/demonnic/EMCO/wiki for information on valid constraints and defaults
-- @tparam table cons table of constraints which configures the EMCO. 
-- @tparam GeyserObject container The container to use as the parent for the EMCO
-- @return the newly created EMCO
function EMCO:new(cons, container)
  local funcName = "EMCO:new(cons, container)"
  cons = cons or {}
  cons.type = cons.type or "tabbedConsole"
  cons.consoles = cons.consoles or { "All" }
  if cons.mapTab then
    if not type(cons.mapTabName) == "string" then
      self:ce(funcName, [["mapTab" is true, thus constraint "mapTabName" and string expected, got ]] .. type(cons.mapTabName))
    elseif not table.contains(cons.consoles, cons.mapTabName) then
      self:ce(funcName, [["mapTabName" must be one of the consoles contained within constraint "consoles". Valid option for tha mapTab are: ]] .. table.concat(cons.consoles, ","))
    end
  end
  local me = self.parent:new(cons, container)
  setmetatable(me, self)
  self.__index = self
  -- set some defaults. Almost all the defaults we had for YATCO, plus a few new ones
  if me:fuzzyBoolean(cons.timestamp) then 
    me:enableTimestamp()
  else
    me:disableTimestamp()
  end
  if me:fuzzyBoolean(cons.customTimestampColor) then
    me:enableCustomTimestampColor()
  else
    me:disableCustomTimestampColor()
  end
  if me:fuzzyBoolean(cons.mapTab) then 
    me.mapTab = true
  else
    me.mapTab = false
  end
  if me:fuzzyBoolean(cons.blinkFromAll) then 
    me:enableBlinkFromAll()
  else
    me:disableBlinkFromAll()
  end
  if me:fuzzyBoolean(cons.preserveBackground) then 
    me:enablePreserveBackground()
  else
    me:disablePreserveBackground()
  end
  if me:fuzzyBoolean(cons.gag)then 
    me:enableGag() 
  else
    me:disableGag()
  end
  me:setTimestampFormat(cons.timestampFormat or "HH:mm:ss")
  me:setTimestampBGColor(cons.timestampBGColor or "blue")
  me:setTimestampFGColor(cons.timestampFGColor or "red")
  if me:fuzzyBoolean(cons.allTab) then
    me:enableAllTab(cons.allTab)
  else
    me:disableAllTab()
  end
  me:setAllTabName(cons.allTabName or "All")
  if me:fuzzyBoolean(cons.blink) then
    me:enableBlink()
  else
    me:disableBlink()
  end
  if me:fuzzyBoolean(cons.blankLine) then
    me:enableBlankLine()
  else
    me:disableBlankLine()
  end
  if me:fuzzyBoolean(cons.scrollbars) then
    me.scrollbars = true
  else
    me.scrollbars = false
  end
  me.blinkTime = cons.blinkTime or 3
  me.fontSize = cons.fontSize or 9
  me.activeTabCSS = cons.activeTabCSS or ""
  me.inactiveTabCSS = cons.inactiveTabCSS or ""
  me.activeTabFGColor = cons.activeTabFGColor or "purple"
  me.inactiveTabFGColor = cons.inactiveTabFGColor or "white"
  me.activeTabBGColor = cons.activeTabBGColor or "<0,180,0>"
  me.inactiveTabBGColor = cons.inactiveTabBGColor or "<60,60,60>"
  me.consoleColor = cons.consoleColor or "black" 
  me.tabBoxCSS = cons.tabBoxCSS or ""
  me.tabBoxColor = cons.tabBoxColor or "black"
  me.consoleContainerCSS = cons.consoleContainerCSS or ""
  me.consoleContainerColor = cons.consoleContainerColor or "black"
  me.gap = cons.gap or 1
  me.consoles = cons.consoles
  me.tabHeight = cons.tabHeight or 25
  if cons.autoWrap == nil then
    me.autoWrap = true
  else
    me.autoWrap = cons.autoWrap
  end
  me.wrapAt = cons.wrapAt or 300
  me.currentTab = ""
  me.tabs = {}
  me.tabsToBlink = {}
  me.windows = {}
  self.blinkTimerID = tempTimer(me.blinkTime, function() me:doBlink() end, true)
  me:reset()
  table.insert(EMCOHelper.items, me)
  return me
end