--[[
    Misc Functions
--]]

function table.contains(t, value)
    if (type(t) == "table" and #t > 0) then
        for i = 1, #t do
            if (t[i] == value) then
                return true
            end
        end
    end

    return false
end

function math.clamp(value, min, max)
    if (min) then if (value < min) then value = min end end
    if (max) then if (value > max) then value = max end end

    return value
end

function math.point_inside(x, y, x2, y2, w, h)
    if (x >= x2 and x <= x2 + w) then
        if (y >= y2 and y <= y2 + h) then
            return true
        end
    end

    return false
end

--[[
    Input Library
--]]

local keyState = input.key_down local keys = {}
function client.key_state_run()
    if (#keys > 0) then
        for i = 1, #keys do
            if (keyState(keys[i].id)) then
                if (not keys[i].down) then
                    keys[i].pressed = true
                elseif (keys[i].pressed) then
                    keys[i].pressed = false
                end

                keys[i].down = true
            else
                if (keys[i].down) then
                    keys[i].released = true
                elseif (keys[i].released) then 
                    keys[i].released = false
                end

                keys[i].down, keys[i].pressed = false, false
            end
        end
    end
end

function input.key_down(keycode)
    local function contain(tbl, code)
        if (#tbl > 0) then
            for i = 1, #tbl do
                if (tbl[i].id == code) then
                    return true
                end
            end
        end

        return false
    end

    if (not contain(keys, keycode)) then table.insert(keys, {id = keycode, down = false, pressed = false, released = false}) return end
    
    for i = 1, #keys do
        if (keys[i].id == keycode) then
            return keys[i]
        end
    end
end

--[[
    Window Library
--]]

local window = {} window.__index = window

window.flags = {
    no_draw = 1,
    no_title = 2,
    use_dpi = 3,
    one_collumn = 4,
}

window.colors = {
    tab_color = color.new(18, 18, 18, 255),
    body_color = color.new(25, 25, 25, 255),
    top_bar_color = color.new(37, 37, 37, 255),
    lines_color = color.new(48, 48, 48, 255),
    highlight_color = color.new(242, 182, 201, 255),
    sub_highlight_color = color.new(207, 130, 154, 255),
    control_highlight_color = color.new(55, 55, 55, 255),
    control_base_color = color.new(35, 35, 35, 255),
}

window.windows = {}

function window.find_window(id)
    if (#window.windows > 0) then
        for i = 1, #window.windows do
            if (window.windows[i].id == id) then
                return i
            end
        end
    end
end

function window.find_tab(id, tab)
    id = window.find_window(id)

    if (id) then
        for i = 1, #window.windows[id].tabs do
            if (window.windows[id].tabs[i].id == tab) then
                return i
            end
        end
    end
end

function window.find_control(id, tab, group)
    tab = window.find_tab(id, tab)
    id = window.find_window(id)

    if (id and tab) then
        for i = 1, #window.windows[id].tabs[tab].controls do
            if (window.windows[id].tabs[tab].controls[i].id == group) then
                return i
            end
        end
    end
end

function window.get(ctrl)
    if (type(ctrl) == "table") then
        if (#ctrl >= 3) then
            if (#window.windows >= ctrl[1]) then
                local wnd = window.windows[ctrl[1]]

                if (#wnd.tabs >= ctrl[2]) then
                    local tb = wnd.tabs[ctrl[2]]

                    if (#tb.controls >= ctrl[3]) then
                        local ctl = tb.controls[ctrl[3]]

                        if (ctl.type == 1) then
                            return ctl.enabled
                        elseif (ctl.type == 2) then
                            return ctl.text
                        elseif (ctl.type == 3) then
                            return ctl.value
                        elseif (ctl.type == 4) then
                            return ctl.key
                        elseif (ctl.type == 5) then
                            return ctl.col
                        end
                    end
                end
            end
        end
    end
end

function window.set(ctrl, value)
    if (type(ctrl) == "table") then
        if (#ctrl >= 3) then
            if (#window.windows >= ctrl[1]) then
                local wnd = window.windows[ctrl[1]]

                if (#wnd.tabs >= ctrl[2]) then
                    local tb = wnd.tabs[ctrl[2]]

                    if (#tb.controls >= ctrl[3]) then
                        local ctl = tb.controls[ctrl[3]]

                        if (ctl.type == 1) then
                            ctl.enabled = value
                        elseif (ctl.type == 2) then
                            ctl.text = value
                        elseif (ctl.type == 3) then
                            ctl.value = value
                        elseif (ctl.type == 4) then
                            ctl.key = value
                        elseif (ctl.type == 5) then
                            ctl.col = value
                        end
                    end
                end
            end
        end
    end
end

function window.new_window(id, name, x, y, w, h, tab_cap, ...)
    local wnd = window.find_window(id)
    if (wnd) then return end

    local flags = {...}

    table.insert(window.windows, {id = id, name = name, tabs = {}, x = x, y = y, w = w, h = h, tab_cap = tab_cap, tab = 1, lastSpace = {0, 0},
                                  over_tab = false, over_control = false, movement = { x = 0, y = 0, selected = false }, color = 0, flags = 
                                {
                                    no_draw = table.contains(flags, 1), no_title = table.contains(flags, 2), dpi = table.contains(flags, 3),
                                    one_collumn = table.contains(flags, 4)
                                }})
end

function window.new_tab(id, tab, name)
    local wnd = window.find_window(id)
    local tb = window.find_tab(id, tab)
    if (tb) then return end

    table.insert(window.windows[wnd].tabs, {id = tab, name = name, scroll = 0, hovered = false, controls = {}})
end

function window.new_control(id, tab, group, name, collumn, type)
    local wnd = window.find_window(id)
    local tb = window.find_tab(id, tab)
    local gp = window.find_control(id, tab, group)
    if (gp or not wnd or not tb) then return end
    
    table.insert(window.windows[wnd].tabs[tb].controls, {id = group, name = name, collumn = collumn, type = type, enabled = false, hovered = false})
    return {wnd, tb, #window.windows[wnd].tabs[tb].controls}
end

function window.new_checkbox(id, tab, group, name, collumn)
    return window.new_control(id, tab, group, name, collumn, 1)
end

function window.new_textbox(id, tab, group, name, collumn)
    return window.new_control(id, tab, group, name, collumn, 2)
end

function window.new_slider(id, tab, group, name, collumn, min, max, value)
    if (not value) then value = min end
    value = math.clamp(value, min, max)
    local wnd = window.find_window(id)
    local tb = window.find_tab(id, tab)
    local gp = window.find_control(id, tab, group)
    if (gp) then return end
    
    table.insert(window.windows[wnd].tabs[tb].controls, {id = group, name = name, collumn = collumn, type = 3, x = 0, w = 0, enabled = false, hovered = false, min = min, max = max, value = value})
    return {wnd, tb, #window.windows[wnd].tabs[tb].controls}
end

function window.new_hotkey(id, tab, group, name, collumn)
    return window.new_control(id, tab, group, name, collumn, 4)
end

function window.new_colorpicker(id, tab, group, name, collumn, value)
    local wnd = window.find_window(id)
    local tb = window.find_tab(id, tab)
    local gp = window.find_control(id, tab, group)
    if (gp) then return end

    if (not value) then value = color.new(0, 0, 0, 255) end
    if (type(value) ~= "userdata" or not value.r or not value.g or not value.b or not value.a) then value = color.new(0, 0, 0, 255) end
    
    table.insert(window.windows[wnd].tabs[tb].controls, {id = group, name = name, collumn = collumn, type = 5, enabled = false, hovered = false, col = value})
    return {wnd, tb, #window.windows[wnd].tabs[tb].controls}
end

local keyTable = {{"A", 0x41}, {"B", 0x42}, {"C", 0x43}, {"D", 0x44}, {"E", 0x45}, {"F", 0x46}, {"G", 0x47}, {"H", 0x48}, {"I", 0x49},
                  {"J", 0x4A}, {"K", 0x4B}, {"L", 0x4C}, {"M", 0x4D}, {"N", 0x4E}, {"O", 0x4F}, {"P", 0x50}, {"Q", 0x51}, {"R", 0x52},
                  {"S", 0x53}, {"T", 0x54}, {"U", 0x55}, {"V", 0x56}, {"W", 0x57}, {"X", 0x58}, {"Y", 0x59}, {"Z", 0x5A}, {" ", 0x20},
                  {"0", 0x30}, {"1", 0x31}, {"2", 0x32}, {"3", 0x33}, {"4", 0x34}, {"5", 0x35}, {"6", 0x36}, {"7", 0x37}, {"8", 0x38},
                  {"9", 0x39}, {"-", 0xBD, "_"}, {"M1", 0x01}, {"M2", 0x02}, {"ALT", 0x12}, {"CTRL", 0x11}, {"SHIFT", 0x10}}

local multiKey = {"M1", "M2", "ALT", "CTRL", "SHIFT"}

window.new_window("color_window", "Color Window", 20, 20, 350, 350, 0, window.flags.one_collumn)
window.new_tab("color_window", "main_tab", "Main")
local color_r = window.new_slider("color_window", "main_tab", "color_r", "Red", 1, 0, 255)
local color_g = window.new_slider("color_window", "main_tab", "color_g", "Green", 1, 0, 255)
local color_b = window.new_slider("color_window", "main_tab", "color_b", "Blue", 1, 0, 255)
local color_a = window.new_slider("color_window", "main_tab", "color_a", "Alpha", 1, 0, 255, 255)

function window.run_movement()
    if (windows.is_active()) then
        local mousePos = input.mouse_position()
        local screenSize = engine.get_screen_size()
        local state = input.key_down(0x01)
        local backState = input.key_down(0x08)
        local shiftState = input.key_down(0x10)
        local escapeState = input.key_down(0x1B)
        if (not state or not backState or not shiftState) then return end

        local addedText = ""
        for g = 1, #keyTable do
            local st = input.key_down(keyTable[g][2])

            if (st and st.pressed ~= nil and shiftState and shiftState.down ~= nil) then
                if (st.pressed) then
                    if (shiftState.down) then
                        if (#keyTable[g] == 3) then
                            addedText = addedText .. keyTable[g][3]
                        else
                            addedText = addedText .. keyTable[g][1]
                        end
                    else
                        addedText = addedText .. string.lower(keyTable[g][1])
                    end
                end
            end
        end

        if (#window.windows > 0) then
            for i = #window.windows, 1, -1 do
                for f = 1, #window.windows[i].tabs[window.windows[i].tab].controls do
                    local ctl = window.windows[i].tabs[window.windows[i].tab].controls[f]
                    local adTXT = string.upper(addedText)

                    if (ctl.type == 2 and ctl.typing) then
                        if (adTXT ~= "M1" and adTXT ~= "M2" and adTXT ~= "ALT" and adTXT ~= "CTRL" and adTXT ~= "SHIFT") then
                            if (ctl.text) then
                                ctl.text = ctl.text .. addedText

                                if (backState.pressed) then
                                    ctl.text = string.sub(ctl.text, 1, #ctl.text - 1)
                                end
                            else
                                ctl.text = addedText
                            end
                        end
                    elseif (ctl.type == 3 and state.down) then
                        if (ctl.hovered) then
                            local percent, val = ((mousePos.x - ctl.x) / ctl.w), ctl.value
                            if (mousePos.x < ctl.x) then percent, val = 0, ctl.min end
                            if (mousePos.x > ctl.x + ctl.w) then percent, val = 1, ctl.max end
                            val = ctl.min + (ctl.max - ctl.min) * percent

                            math.clamp(val, ctl.min, ctl.max)
                            ctl.value = math.floor(val)
                        end
                    elseif (ctl.type == 4 and ctl.typing) then
                        if (escapeState.pressed) then ctl.typing, ctl.key, ctl.keyname = false, nil, nil else
                            local function findKey(keyname)
                                for hh = 1, #keyTable do
                                    if (string.upper(keyname) == keyTable[hh][1]) then return keyTable[hh] end
                                end
                            end

                            local function containsString(str)
                                for hh = 1, #multiKey do
                                    if (str == multiKey[hh]) then return true end
                                end

                                return false
                            end

                            if (addedText and addedText ~= "" and addedText ~= " ") then
                                if (#addedText > 1) then if (not containsString(adTXT)) then goto jump_that_shit end end
                                local ky = findKey(adTXT)

                                ctl.key, ctl.keyname = ky[2], ky[1]
                                ctl.enabled, ctl.typing = false, false

                                ::jump_that_shit::
                            end
                        end
                    end
                end
            end
        end

        if (state.down) then
            if (#window.windows > 0) then
                for i = #window.windows, 1, -1 do
                    if (state.pressed) then
                        for f = 1, #window.windows[i].tabs do
                            if (window.windows[i].tabs[f].hovered) then
                                window.windows[i].tab = f
                            end
                        end

                        for f = 1, #window.windows[i].tabs[window.windows[i].tab].controls do
                            local ctl = window.windows[i].tabs[window.windows[i].tab].controls[f]

                            if (ctl.hovered) then
                                if (ctl.type == 1) then
                                    ctl.enabled = not ctl.enabled
                                elseif (ctl.type == 2) then
                                    ctl.typing = not ctl.typing
                                elseif (ctl.type == 4) then
                                    ctl.typing = not ctl.typing
                                elseif (ctl.type == 5) then
                                    ctl.enabled = not ctl.enabled
                                    if (ctl.enabled) then
                                        window.windows[i].color = f
                                        if (not ctl.col) then ctl.col = color.new(0, 0, 0, 255) end

                                        window.set(color_r, ctl.col.r)
                                        window.set(color_g, ctl.col.g)
                                        window.set(color_b, ctl.col.b)
                                        window.set(color_a, ctl.col.a)
                                    end
                                end
                            else
                                if (ctl.type == 2) then
                                    ctl.typing = false
                                elseif (ctl.type == 4) then
                                    ctl.typing = false
                                elseif (ctl.type == 5) then
                                    ctl.enabled = false
                                end
                            end
                        end

                        if (not window.windows[i].over_tab and not window.windows[i].over_control and not window.windows[i].flags.no_draw) then
                            if (math.point_inside(mousePos.x, mousePos.y, window.windows[i].x, window.windows[i].y, window.windows[i].w, window.windows[i].h)) then
                                window.windows[i].movement = { x = mousePos.x - window.windows[i].x, y = mousePos.y - window.windows[i].y, selected = true } return
                            end
                        end
                    else
                        if (window.windows[i].movement.selected) then
                            window.windows[i].x, window.windows[i].y = mousePos.x - window.windows[i].movement.x, mousePos.y - window.windows[i].movement.y

                            if (window.windows[i].x < 0) then window.windows[i].x = 0 end
                            if (window.windows[i].x > screenSize.x - window.windows[i].w) then window.windows[i].x = screenSize.x - window.windows[i].w end
                            if (window.windows[i].y < 0) then window.windows[i].y = 0 end
                            if (window.windows[i].y > screenSize.y - window.windows[i].h) then window.windows[i].y = screenSize.y - window.windows[i].h end
                        end
                    end
                end
            end
        elseif (state.released) then
            if (#window.windows > 0) then
                for i = 1, #window.windows do
                    window.windows[i].movement.selected = false
                end
            end
        end
    end
end

function window.run_drawing()
    local mousePos = input.mouse_position()

    if (#window.windows > 0) then
        for i = 1, #window.windows do
            local wnd = window.windows[i]
            if (not wnd.flags.no_draw) then
                local tab_size = math.clamp(wnd.w / 4, 0, wnd.tab_cap)
                renderer.set_clip(vector2.new(wnd.x, wnd.y), vector2.new(wnd.w, wnd.h))
                local scroll, heights = renderer.get_scroll() * 15, { 0, 0 }
                
                -- Tab
                if (wnd.tab_cap ~= 0) then
                    renderer.rectangle_filled(vector2.new(wnd.x, wnd.y), vector2.new(tab_size + 8, wnd.h), window.colors.tab_color, 6)
                end

                -- Body
                renderer.rectangle_filled(vector2.new(wnd.x + tab_size, wnd.y), vector2.new(wnd.w - tab_size, wnd.h), window.colors.body_color, 6)
                if (wnd.tab_cap ~= 0) then
                    renderer.rectangle_filled(vector2.new(wnd.x + tab_size - 8, wnd.y), vector2.new(16, wnd.h), window.colors.body_color, 0)
                end  

                -- Top Bar
                if (wnd.tab_cap ~= 0) then
                    renderer.rectangle_filled(vector2.new(wnd.x + tab_size - 8, wnd.y), vector2.new(wnd.w - tab_size + 8, wnd.h / 9), window.colors.top_bar_color, 6)
                    renderer.rectangle_filled(vector2.new(wnd.x + tab_size - 8, wnd.y + 12), vector2.new(wnd.w - tab_size + 8, wnd.h / 9 - 12), window.colors.top_bar_color, 0)
                else
                    renderer.rectangle_filled(vector2.new(wnd.x, wnd.y), vector2.new(wnd.w, wnd.h / 9), window.colors.top_bar_color, 6)
                    renderer.rectangle_filled(vector2.new(wnd.x + tab_size - 8, wnd.y + 24), vector2.new(wnd.w - tab_size + 8, wnd.h / 9 - 24), window.colors.top_bar_color, 0)
                end

                -- Highlights
                renderer.rectangle_filled(vector2.new(wnd.x + tab_size - 8, wnd.y), vector2.new(1, wnd.h), window.colors.lines_color, 0)
                renderer.rectangle_filled(vector2.new(wnd.x + tab_size - 8, math.floor(wnd.y + wnd.h / 9)), vector2.new(wnd.w - tab_size + 8, 1), window.colors.lines_color, 0)

                local overCtl = false
                renderer.pop_clip()
                renderer.set_clip(vector2.new(wnd.x, wnd.y), vector2.new(tab_size, wnd.h))

                if (#wnd.tabs > 0) then
                    local tabUsage = vector2.new(0, 0)
                    for f = 1, #wnd.tabs do
                        local textSize = renderer.text_size(wnd.tabs[f].name, 24)
                        local inside = false
                        if (math.point_inside(mousePos.x, mousePos.y, wnd.x + tab_size / 2 - textSize.x / 2, wnd.y + wnd.h / 9 + 8 + tabUsage.y, textSize.x, textSize.y)) then
                            inside, wnd.tabs[f].hovered = true, true
                            overCtl = true
                        else
                            wnd.tabs[f].hovered = false
                        end

                        if (f == wnd.tab) then
                            renderer.circle_filled(vector2.new(wnd.x + 16, wnd.y + wnd.h / 9 + 8 + tabUsage.y + textSize.y / 2), 4, window.colors.highlight_color)
                            renderer.text(vector2.new(wnd.x + tab_size / 2 - textSize.x / 2, wnd.y + wnd.h / 9 + 8 + tabUsage.y), wnd.tabs[f].name, color.new(255, 255, 255, 255), 24, false, false)
                        elseif (inside) then
                            renderer.text(vector2.new(wnd.x + tab_size / 2 - textSize.x / 2, wnd.y + wnd.h / 9 + 8 + tabUsage.y), wnd.tabs[f].name, color.new(210, 210, 210, 255), 24, false, false)
                        else
                            renderer.text(vector2.new(wnd.x + tab_size / 2 - textSize.x / 2, wnd.y + wnd.h / 9 + 8 + tabUsage.y), wnd.tabs[f].name, color.new(155, 155, 155, 255), 24, false, false)
                        end

                        tabUsage.y = tabUsage.y + textSize.y + 16
                    end
                end

                renderer.pop_clip()
                renderer.set_clip(vector2.new(wnd.x, wnd.y + wnd.h / 9 + 1), vector2.new(wnd.w, wnd.h - (wnd.h / 9) - 1))

                if (#wnd.tabs >= wnd.tab) then
                    if (math.point_inside(mousePos.x, mousePos.y, wnd.x + tab_size, wnd.y, wnd.w - tab_size, wnd.h)) then
                        local lastSpc = 0 if (wnd.lastSpace[1] > wnd.lastSpace[2]) then lastSpc = wnd.lastSpace[1] else lastSpc = wnd.lastSpace[2] end
                        wnd.tabs[wnd.tab].scroll = math.clamp(wnd.tabs[wnd.tab].scroll + scroll, -lastSpc, 0)
                    end

                    local usedSpace = { vector2.new(0, wnd.tabs[wnd.tab].scroll + wnd.h / 9), vector2.new(0, wnd.tabs[wnd.tab].scroll + wnd.h / 9) };

                    for f = 1, #wnd.tabs[wnd.tab].controls do
                        local ctl = wnd.tabs[wnd.tab].controls[f]
                        local collumnPadding = vector2.new(16, 12)
                        local collumnSize = math.floor((wnd.w - tab_size) / 2 - collumnPadding.x * 2)
                        local groupSize = rect.new(wnd.x + tab_size + collumnPadding.x, wnd.y + collumnPadding.y + usedSpace[1].y, collumnSize, 25)
                        
                        if (ctl.collumn == 2) then
                            groupSize.x, groupSize.y = wnd.x + tab_size + collumnPadding.x * 3 + collumnSize, wnd.y + collumnPadding.y + usedSpace[2].y
                        end

                        if (wnd.flags.one_collumn) then
                            groupSize.x, groupSize.y = wnd.x + tab_size + collumnPadding.x, wnd.y + collumnPadding.y + usedSpace[2].y
                            groupSize = rect.new(wnd.x + tab_size + collumnPadding.x, wnd.y + collumnPadding.y + usedSpace[1].y, collumnSize * 2 + collumnPadding.x * 2, 25)
                        end

                        local inside, additional = false, 0
                        if (ctl.type == 1) then
                            local textSize = renderer.text_size(ctl.name, 16)
                            if (math.point_inside(groupSize.x, groupSize.y, wnd.x + tab_size, wnd.y + wnd.h / 9, wnd.w - tab_size, wnd.h)) then
                                if (math.point_inside(groupSize.x, groupSize.y + groupSize.h, wnd.x + tab_size, wnd.y + wnd.h / 9, wnd.w - tab_size, wnd.h)) then
                                    if (math.point_inside(mousePos.x, mousePos.y, groupSize.x, groupSize.y, groupSize.h + 8 + textSize.x, groupSize.h)) then
                                        inside, overCtl, ctl.hovered = true, true, true
                                    else
                                        ctl.hovered = false
                                    end
                                else ctl.hovered = false end
                            else ctl.hovered = false end

                            if (ctl.enabled) then
                                renderer.rectangle_filled(vector2.new(groupSize.x, groupSize.y), vector2.new(groupSize.h, groupSize.h), window.colors.highlight_color, 5)
                            elseif (inside) then
                                renderer.rectangle_filled(vector2.new(groupSize.x, groupSize.y), vector2.new(groupSize.h, groupSize.h), window.colors.control_highlight_color, 5)
                            else
                                renderer.rectangle_filled(vector2.new(groupSize.x, groupSize.y), vector2.new(groupSize.h, groupSize.h), window.colors.control_base_color, 5)
                            end

                            renderer.text(vector2.new(groupSize.x + groupSize.h + 8, groupSize.y + groupSize.h / 2), ctl.name, color.new(255, 255, 255, 255), 16, false, true)
                        elseif (ctl.type == 2) then
                            local textSize = renderer.text_size(ctl.name, 16)
                            renderer.text(vector2.new(groupSize.x, groupSize.y), ctl.name, color.new(255, 255, 255, 255), 16, false, false)
                            additional = additional + textSize.y + 2

                            renderer.pop_clip()
                            renderer.set_clip(vector2.new(groupSize.x, wnd.y + wnd.h / 9 + 1), vector2.new(groupSize.w, wnd.h - (wnd.h / 9) - 1))

                            if (math.point_inside(groupSize.x, groupSize.y + textSize.y + 2, wnd.x + tab_size, wnd.y + wnd.h / 9, wnd.w - tab_size, wnd.h)) then
                                if (math.point_inside(groupSize.x, groupSize.y + textSize.y + 2 + groupSize.h, wnd.x + tab_size, wnd.y + wnd.h / 9, wnd.w - tab_size, wnd.h)) then
                                    if (math.point_inside(mousePos.x, mousePos.y, groupSize.x, groupSize.y + textSize.y + 2, groupSize.w, groupSize.h)) then
                                        inside, overCtl, ctl.hovered = true, true, true
                                    else
                                        ctl.hovered = false
                                    end
                                else ctl.hovered = false end
                            else ctl.hovered = false end

                            if (ctl.typing) then
                                renderer.rectangle_filled(vector2.new(groupSize.x, groupSize.y + textSize.y + 2), vector2.new(groupSize.w, groupSize.h), window.colors.control_base_color, 5)
                                renderer.rectangle(vector2.new(math.floor(groupSize.x), math.floor(groupSize.y + textSize.y + 2)), vector2.new(math.floor(groupSize.w), math.floor(groupSize.h)), window.colors.highlight_color, 5)

                                local textSize = renderer.text_size(ctl.text, 16)
                                renderer.rectangle_filled(vector2.new(groupSize.x + textSize.x + 8, groupSize.y + math.floor(groupSize.h / 4) + textSize.y + 2), vector2.new(2, math.floor(groupSize.h / 2)), window.colors.highlight_color, 0)
                            elseif (inside) then
                                renderer.rectangle_filled(vector2.new(groupSize.x, groupSize.y + textSize.y + 2), vector2.new(groupSize.w, groupSize.h), window.colors.control_base_color, 5)
                                renderer.rectangle(vector2.new(math.floor(groupSize.x), math.floor(groupSize.y + textSize.y + 2)), vector2.new(math.floor(groupSize.w), math.floor(groupSize.h)), window.colors.sub_highlight_color, 5)
                            else
                                renderer.rectangle_filled(vector2.new(groupSize.x, groupSize.y + textSize.y + 2), vector2.new(groupSize.w, groupSize.h), window.colors.control_base_color, 5)
                            end

                            renderer.text(vector2.new(groupSize.x + 8, groupSize.y + textSize.y + 2 + groupSize.h / 2), ctl.text, color.new(255, 255, 255, 255), 16, false, true)

                            renderer.pop_clip()
                            renderer.set_clip(vector2.new(wnd.x, wnd.y + wnd.h / 9 + 1), vector2.new(wnd.w, wnd.h - (wnd.h / 9) - 1))
                        elseif (ctl.type == 3) then
                            local textSize = renderer.text_size(ctl.value ~= nil and (ctl.name .. ": " .. ctl.value) or ctl.name, 16)
                            renderer.text(vector2.new(groupSize.x, groupSize.y), ctl.value ~= nil and (ctl.name .. ": " .. ctl.value) or ctl.name, color.new(255, 255, 255, 255), 16, false, false)
                            additional = additional + textSize.y - 8

                            renderer.pop_clip()
                            renderer.set_clip(vector2.new(groupSize.x, wnd.y + wnd.h / 9 + 1), vector2.new(groupSize.w, wnd.h - (wnd.h / 9) - 1))

                            ctl.x, ctl.w = groupSize.x, groupSize.w
                            if (math.point_inside(groupSize.x, groupSize.y + textSize.y + 2, wnd.x + tab_size, wnd.y + wnd.h / 9, wnd.w - tab_size, wnd.h)) then
                                if (math.point_inside(groupSize.x, groupSize.y + textSize.y + 2 + groupSize.h, wnd.x + tab_size, wnd.y + wnd.h / 9, wnd.w - tab_size, wnd.h)) then
                                    if (math.point_inside(mousePos.x, mousePos.y, groupSize.x, groupSize.y + textSize.y + 2, groupSize.w, groupSize.h)) then
                                        inside, overCtl, ctl.hovered = true, true, true
                                    else
                                        ctl.hovered = false
                                    end
                                else ctl.hovered = false end
                            else ctl.hovered = false end

                            if (inside) then
                                renderer.rectangle_filled(vector2.new(groupSize.x, groupSize.y + textSize.y + 2 + (groupSize.h / 6)), vector2.new(groupSize.w, groupSize.h / 3), window.colors.control_highlight_color, groupSize.h / 6)
                            else
                                renderer.rectangle_filled(vector2.new(groupSize.x, groupSize.y + textSize.y + 2 + (groupSize.h / 6)), vector2.new(groupSize.w, groupSize.h / 3), window.colors.control_base_color, groupSize.h / 6)
                            end

                            local percent = (ctl.value - ctl.min) / (ctl.max - ctl.min)
                            if (ctl.value > ctl.min) then
                                if (groupSize.w * percent > groupSize.h / 3) then
                                    renderer.rectangle_filled(vector2.new(groupSize.x, groupSize.y + textSize.y + 2 + (groupSize.h / 6)), vector2.new(groupSize.w * percent, groupSize.h / 3), window.colors.highlight_color, groupSize.h / 6)
                                else
                                    renderer.rectangle_filled(vector2.new(groupSize.x, groupSize.y + textSize.y + 2 + (groupSize.h / 6)), vector2.new(groupSize.h / 3, groupSize.h / 3), window.colors.highlight_color, groupSize.h / 6)
                                end
                            end

                            renderer.pop_clip()
                            renderer.set_clip(vector2.new(wnd.x, wnd.y + wnd.h / 9 + 1), vector2.new(wnd.w, wnd.h - (wnd.h / 9) - 1))
                        elseif (ctl.type == 4) then
                            local textSize = renderer.text_size(ctl.name .. ": ", 16)
                            local textSize2 = renderer.text_size(ctl.keyname ~= nil and ctl.keyname or "?", 16)

                            if (math.point_inside(groupSize.x, groupSize.y, wnd.x + tab_size, wnd.y + wnd.h / 9, wnd.w - tab_size, wnd.h)) then
                                if (math.point_inside(groupSize.x, groupSize.y + groupSize.h, wnd.x + tab_size, wnd.y + wnd.h / 9, wnd.w - tab_size, wnd.h)) then
                                    if (math.point_inside(mousePos.x, mousePos.y, groupSize.x, groupSize.y, (textSize2.x > groupSize.h and (textSize2.x + 12) or groupSize.h) + 8 + textSize.x, groupSize.h)) then
                                        inside, overCtl, ctl.hovered = true, true, true
                                    else
                                        ctl.hovered = false
                                    end
                                else ctl.hovered = false end
                            else ctl.hovered = false end

                            renderer.text(vector2.new(groupSize.x, math.floor(groupSize.y) + math.floor(groupSize.h / 2) - math.floor(textSize.y / 2)), ctl.name .. ": ", color.new(255, 255, 255, 255), 16, false, false)
                            
                            if (ctl.typing) then
                                renderer.rectangle_filled(vector2.new(groupSize.x + textSize.x + 8, groupSize.y), vector2.new(textSize2.x > groupSize.h and (textSize2.x + 12) or groupSize.h, groupSize.h), window.colors.highlight_color, 6)
                            elseif (inside) then
                                renderer.rectangle_filled(vector2.new(groupSize.x + textSize.x + 8, groupSize.y), vector2.new(textSize2.x > groupSize.h and (textSize2.x + 12) or groupSize.h, groupSize.h), window.colors.control_highlight_color, 6)
                            else
                                renderer.rectangle_filled(vector2.new(groupSize.x + textSize.x + 8, groupSize.y), vector2.new(textSize2.x > groupSize.h and (textSize2.x + 12) or groupSize.h, groupSize.h), window.colors.control_base_color, 6)
                            end

                            if (ctl.typing) then
                                renderer.text(vector2.new(groupSize.x + textSize.x + 8 + (textSize2.x > groupSize.h and (textSize2.x + 12) or groupSize.h) / 2 - textSize2.x / 2, math.floor(groupSize.y) + math.floor(groupSize.h / 2) - math.floor(textSize2.y / 2)), ctl.keyname ~= nil and ctl.keyname or "?", color.new(35, 35, 35, 255), 16, false, false)
                            else
                                renderer.text(vector2.new(groupSize.x + textSize.x + 8 + (textSize2.x > groupSize.h and (textSize2.x + 12) or groupSize.h) / 2 - textSize2.x / 2, math.floor(groupSize.y) + math.floor(groupSize.h / 2) - math.floor(textSize2.y / 2)), ctl.keyname ~= nil and ctl.keyname or "?", color.new(255, 255, 255, 255), 16, false, false)
                            end
                        elseif (ctl.type == 5) then
                            local textSize = renderer.text_size(ctl.name .. ": ", 16)
                            if (not ctl.col) then ctl.col = color.new(0, 0, 0, 255) end

                            if (math.point_inside(groupSize.x, groupSize.y, wnd.x + tab_size, wnd.y + wnd.h / 9, wnd.w - tab_size, wnd.h)) then
                                if (math.point_inside(groupSize.x, groupSize.y + groupSize.h, wnd.x + tab_size, wnd.y + wnd.h / 9, wnd.w - tab_size, wnd.h)) then
                                    if (math.point_inside(mousePos.x, mousePos.y, groupSize.x, groupSize.y, groupSize.h + 8 + textSize.x, groupSize.h)) then
                                        inside, overCtl, ctl.hovered = true, true, true
                                    else
                                        ctl.hovered = false
                                    end
                                else ctl.hovered = false end
                            else ctl.hovered = false end

                            if (f == wnd.color) then
                                ctl.col = color.new(window.get(color_r), window.get(color_g), window.get(color_b), window.get(color_a))
                            end

                            renderer.text(vector2.new(groupSize.x, math.floor(groupSize.y) + math.floor(groupSize.h / 2) - math.floor(textSize.y / 2)), ctl.name .. ": ", color.new(255, 255, 255, 255), 16, false, false)
                            renderer.rectangle_filled(vector2.new(groupSize.x + textSize.x + 8, groupSize.y), vector2.new(groupSize.h, groupSize.h), ctl.col, 6)
                        end

                        if (wnd.flags.one_collumn) then
                            usedSpace[2].y = usedSpace[2].y + 25 + collumnPadding.y + additional
                            usedSpace[1].y = usedSpace[1].y + 25 + collumnPadding.y + additional
                            heights[2] = heights[2] + 25 + collumnPadding.y + additional
                            heights[1] = heights[1] + 25 + collumnPadding.y + additional
                        else
                            if (ctl.collumn == 2) then
                                usedSpace[2].y = usedSpace[2].y + 25 + collumnPadding.y + additional
                                heights[1] = heights[1] + 25 + collumnPadding.y + additional
                            else
                                usedSpace[1].y = usedSpace[1].y + 25 + collumnPadding.y + additional
                                heights[2] = heights[2] + 25 + collumnPadding.y + additional
                            end
                        end
                    end

                    wnd.over_control = overCtl
                end

                wnd.lastSpace = heights
                renderer.pop_clip()
            end
        end
    end
end

function window.run_windows()
    if (client.gui_open()) then
        window.run_movement()
        window.run_drawing()
    end
end
