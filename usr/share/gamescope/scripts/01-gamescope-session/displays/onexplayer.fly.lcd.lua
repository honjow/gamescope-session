local onexplayer_fly_lcd_refresh_rates = {}
for i = 60, 120 do
    table.insert(onexplayer_fly_lcd_refresh_rates, i)
end

gamescope.config.known_displays.oxpfly_lcd = {
    pretty_name = "OneXPlayer Fly",
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
    dynamic_refresh_rates = onexplayer_fly_lcd_refresh_rates,
    -- Follow the Steam Deck OLED style for modegen by variang the VFP (Vertical Front Porch)
    --
    -- Given that this display is VRR and likely has an FB/Partial FB in the DDIC:
    -- it should be able to handle this method, and it is more optimal for latency
    -- than elongating the clock.
    dynamic_modegen = function(base_mode, refresh)
        debug("Generating mode "..refresh.."Hz for OneXPlayer Fly with fixed pixel clock")
        local vfps = {
            2014, 1949, 1886, 1825, 1766, 
            1709, 1653, 1599, 1547, 1496, 
            1447, 1399, 1352, 1307, 1263, 
            1220, 1178, 1137, 1098, 1059, 
            1021, 985, 949, 914, 880, 
            846, 814, 782, 751, 720, 
            691, 661, 633, 605, 578, 
            551, 525, 500, 474, 450, 
            426, 402, 379, 356, 334, 
            312, 291, 270, 249, 229, 
            209, 190, 171, 152, 133, 
            115, 97, 80, 62, 45, 29
        }
        local vfp = vfps[zero_index(refresh - 60)]
        if vfp == nil then
            warn("Couldn't do refresh "..refresh.." on OneXPlayer Fly")
            return base_mode
        end

        local mode = base_mode

        gamescope.modegen.adjust_front_porch(mode, vfp)
        mode.vrefresh = gamescope.modegen.calc_vrefresh(mode)

        --debug(inspect(mode))
        return mode
    end,


    matches = function(display)
        if display.vendor == "BOE" and ""..display.model == "" then
            debug("[oxpfly_lcd] Matched vendor: "..display.vendor.." model: "..display.model.." product:"..display.product)
            return 5000
        end
        return -1
    end
}
debug("Registered OneXPlayer Fly as a known display")
debug(inspect(gamescope.config.known_displays.oxpfly_lcd))
