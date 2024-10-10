local winmini_lcd_refresh_rates = {
    60, 80, 90, 100, 110, 120
}

gamescope.config.known_displays.gpd_winmini2023_lcd = {
    pretty_name = "GPD Win Mini 2023",
    hdr = {
        -- Setup some fallbacks for undocking with HDR, meant
        -- for the internal panel. It does not support HDR.
        supported = false,
        force_enabled = false,
        eotf = gamescope.eotf.gamma22,
        max_content_light_level = 500,
        max_frame_average_luminance = 500,
        min_content_light_level = 0.5
    },
    -- Use the EDID colorimetry for now, but someone should check
    -- if the EDID colorimetry truly matches what the display is capable of.
    dynamic_refresh_rates = winmini_lcd_refresh_rates,

    dynamic_modegen = function(base_mode, refresh)
        info("Generating mode "..refresh.."Hz for GPD Win Mini 2023 with fixed pixel clock")
        info("base_mode: "..inspect(base_mode))

        local vfps = {
            [60] = 2016,
            [80] = 1024,
            [90] = 692,
            [100] = 428,
            [110] = 208,
            [120] = 30
        }

        local vfp = vfps[refresh]
        if vfp == nil then
            warn("Couldn't do refresh "..refresh.." on GPD Win Mini")
            return base_mode
        end

        local mode = base_mode

        gamescope.modegen.set_resolution(mode, 1080, 1920)

        gamescope.modegen.adjust_front_porch(mode, vfp)
        mode.vrefresh = gamescope.modegen.calc_vrefresh(mode)

        info("mode: "..inspect(mode))
        return base_mode
    end,
    
    matches = function(display)
        info("[TTT] vendor: "..display.vendor.." model: "..display.model.." product:"..display.product)
        if display.vendor == "TMX" and display.model == "TL070FVXS01-0" and display.product == 0x0002 then
            return 5000
        end
        -- if display.vendor == "GPD" and display.model == "MINI" then
        --     debug("[gpd_winmini2023_lcd] Matched vendor: "..display.vendor.." model: "..display.model.." product:"..display.product)
        --     return 5000
        -- end
        return -1
    end
}
info("Registered GPD Win Mini 2023 as a known display")
info(inspect(gamescope.config.known_displays.gpd_winmini2023_lcd))
