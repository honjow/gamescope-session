-- Lenovo Legion Go S
-- MSI Claw 8

local panel_id = "lenovo_legiongo_lcd"
local panel_name = "Lenovo Legion Go S/MSI Claw 8 LCD"

local panel_refresh_rates = {}
for hz = 48, 120 do
  table.insert(panel_refresh_rates, hz)
end

local panel_hdr = {
    supported = false,
    force_enabled = false,
    eotf = gamescope.eotf.gamma22,
    max_content_light_level = 500,
    max_frame_average_luminance = 500,
    min_content_light_level = 0.5
}

gamescope.config.known_displays[panel_id] = {
    pretty_name = panel_name,

    colorimetry = (panel_colorimetry ~= nil) and panel_colorimetry,
    dynamic_refresh_rates = (panel_refresh_rates ~= nil) and panel_refresh_rates,
    hdr = (panel_hdr ~= nil) and panel_hdr,

    -- Detailed Timing Descriptors:
    -- DTD 1:  1920x1200  120.002 Hz   8:5   151.683 kHz 315.500 MHz (172 mm x 107 mm)
    --   Modeline "1920x1200_120.00" 315.500  1920 1968 2000 2080  1200 1254 1260 1264  -HSync -VSync
    -- DTD 2:  1920x1200   60.001 Hz   8:5    75.841 kHz 157.750 MHz (172 mm x 107 mm)
    --   Modeline "1920x1200_60.00" 157.750  1920 1968 2000 2080  1200 1254 1260 1264  -HSync -VSync
    dynamic_modegen = function(base_mode, refresh)
        debug("Generating mode "..refresh.."Hz with fixed pixel clock")
        local vfps = {
            1950, 1885, 1824, 1764, 1707, 1652, 1599, 1548, 1499, 1451, 1405,
            1361, 1318, 1277, 1237, 1198, 1160, 1124, 1088, 1054, 1021, 988,
            957, 927, 897, 868, 840, 813, 786, 760, 735, 710, 686, 663, 640,
            618, 596, 575, 554, 534, 514, 495, 476, 457, 439, 421, 404, 387,
            370, 354, 338, 322, 307, 292, 277, 263, 249, 235, 221, 208, 195,
            182, 169, 157, 145, 133, 121, 109, 98, 87, 76, 65, 54
        }
        local vfp = vfps[zero_index(refresh - 48)]
        if vfp == nil then
            warn("Couldn't do refresh "..refresh.." on "..panel_name)
            return base_mode
        end

        local mode = base_mode

        gamescope.modegen.adjust_front_porch(mode, vfp)
        mode.vrefresh = gamescope.modegen.calc_vrefresh(mode)

        --debug(inspect(mode))
        return mode
    end,

    
    matches = function(display)
        local lcd_types = {
            { vendor = "CSW", model = "PN8007QB1-1", name = "Lenovo Legion Go S LCD" }, -- product: 0x0800
            { vendor = "BOE", model = "NS080WUM-LX1", name = "Lenovo Legion Go S LCD" }, -- product: 0x0C00
            { vendor = "CSW", model = "PN8007QB1-2", name = "MSI Claw 8" }, -- product: 0x0801
        }

        for index, value in ipairs(lcd_types) do
            if value.vendor == display.vendor and value.model == display.model then
                info("["..value.name.."] Matched vendor: "..display.vendor.." model: "..display.model.." product:"..display.product)
                return 5000
            end
        end
        return -1
    end
}
debug("Registered "..panel_name.." as a known display")