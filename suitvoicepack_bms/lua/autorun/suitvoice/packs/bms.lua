--[[ Hazardous EnVironment Suit Voice Pack ]]

RegisterSuitVoicePack( "Black Mesa", "bms", "////////////////////////////////////////////////////////////////\n// H.E.V. Suit Voice Module - Black Mesa\n////////////////////////////////////////////////////////////////\n\n// Medical Systems\nHEV_BMS_MED1 hev_vox/(p140) boop, boop, boop, (p100) 05_automedic_on {Len 4.92 closecaption HEV.automedic_on}\n\nHEV_BMS_HEAL4 hev_vox/(p140) boop, boop, boop, (p100) hiss, antitoxin_shot {Len 4.38 closecaption HEV.antitoxin_shot}\nHEV_BMS_HEAL7 hev_vox/(p140) boop, boop, boop, (p100) hiss, morphine_shot {Len 4.16 closecaption HEV.morphine_shot}\n\n// Damage Monitoring\nHEV_BMS_DMG0 hev_vox/(p160) boop, boop, boop, (p100) minor_lacerations {Len 4.09 closecaption HEV.minor_lacerations}\nHEV_BMS_DMG1 hev_vox/(p160) boop, boop, boop, (p100) major_lacerations {Len 4.19 closecaption HEV.major_lacerations}\nHEV_BMS_DMG2 hev_vox/(p160) boop, boop, boop, (p100) internal_bleeding {Len 3.64 closecaption HEV.internal_bleeding}\nHEV_BMS_DMG3 hev_vox/(p160) boop, boop, boop, (p100) blood_toxins {Len 5.04 closecaption HEV.blood_toxins}\nHEV_BMS_DMG4 hev_vox/(p160) boop, boop, boop, (p100) minor_fracture {Len 3.67 closecaption HEV.minor_fracture}\nHEV_BMS_DMG5 hev_vox/(p160) boop, boop, boop, (p100) major_fracture {Len 3.67 closecaption HEV.major_fracture}\nHEV_BMS_DMG6 hev_vox/(p160) boop, boop, boop, (p100) blood_loss {Len 3.39 closecaption HEV.blood_loss}\nHEV_BMS_DMG7 hev_vox/(p140) boop, boop, boop, (p100) seek_medic {Len 3.92 closecaption HEV.seek_medic}\n\n// User Condition Monitoring\nHEV_BMS_HLTH1 hev_vox/(p120) beep, beep, (p100) health_dropping2 {Len 3.68 closecaption HEV.health_dropping2}\nHEV_BMS_HLTH2 hev_vox/(p120) beep, beep, beep, (p100) health_critical {Len 4.32 closecaption HEV.health_critical}\nHEV_BMS_HLTH3 hev_vox/(p120) beep, beep, beep, (p100) near_death {Len 4.77 closecaption HEV.near_death}\n\n// Battery Power Level\nHEV_BMS_1P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), ten percent {Len 2.75}\nHEV_BMS_2P hev_vox/(p103) fuzz (p103) fuzz, (p103) power_restored(e30), fifteen percent {Len 3.15}\nHEV_BMS_3P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), twenty percent {Len 2.99}\nHEV_BMS_4P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), twenty five percent {Len 3.87}\nHEV_BMS_5P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), thirty percent {Len 3.04}\nHEV_BMS_6P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), thirty five percent {Len 3.91}\nHEV_BMS_7P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), fourty percent {Len 3.07}\nHEV_BMS_8P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), fourty five percent {Len 3.95}\nHEV_BMS_9P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), fifty percent {Len 3.17}\nHEV_BMS_10P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), fifty five percent {Len 4.05}\nHEV_BMS_11P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), sixty percent {Len 3.16}\nHEV_BMS_12P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), sixty five percent {Len 4.04}\nHEV_BMS_13P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), seventy percent {Len 3.12}\nHEV_BMS_14P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), seventy five percent {Len 4.00}\nHEV_BMS_15P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), eighty percent {Len 2.88}\nHEV_BMS_16P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), eighty five percent {Len 3.76}\nHEV_BMS_17P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), ninety percent {Len 3.12}\nHEV_BMS_18P hev_vox/(p103) fuzz fuzz, (p103) power_restored(e30), ninety five percent {Len 4.00}\nHEV_BMS_19P hev_vox/(p103) fuzz fuzz, (p103) power_level_is onehundred percent {Len 4.62}\n\n// Ammunition Monitoring\nHEV_BMS_AMO0 hev_vox/blip ammo_depleted {Len 2.16 closecaption HEV.ammo_depleted}\n\n// Hazardous Element Detection\nHEV_BMS_DET0 hev_vox/blip blip blip, biohazard_detected {Len 3.67 closecaption HEV.biohazard_detected}\nHEV_BMS_DET1 hev_vox/blip blip blip, chemical_detected {Len 4.33 closecaption HEV.chemical_detected}\nHEV_BMS_DET2 hev_vox/blip blip blip, radiation_detected {Len 5.08 closecaption HEV.radiation_detected}\n\n" );

-- Black Mesa doesn't have voice lines recorded for these...
local function SetSuitUpdate( ply, sentence )
    if ( ply.suitPlaylistPack == "bms" ) then
        if ( sentence == "DMG2" || sentence == "SHOCK" || sentence == "FIRE" ) then
            return false;
        end
    end
end
hook.Add( "SetSuitUpdate", "SuitVoicePack_BMS_SetSuitUpdate", SetSuitUpdate );