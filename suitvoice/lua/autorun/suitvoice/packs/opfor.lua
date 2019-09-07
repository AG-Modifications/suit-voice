--[[ Hazardous EnVironment Suit Voice Pack ]]

RegisterSuitVoicePack( "Opposing Force", "opfor", "////////////////////////////////////////////////////////////////\n// H.E.V. Suit Voice Pack - Opposing Force\n////////////////////////////////////////////////////////////////\n\n// Vital Sign Monitoring\nHEV_OPFOR_DMG0 fvox/boop\n\nHEV_OPFOR_SHOCK fvox/boop\nHEV_OPFOR_FIRE fvox/boop\n\n// High Impact Reactive Armor\nHEV_OPFOR_0P fvox/fuzz\nHEV_OPFOR_1P fvox/fuzz\nHEV_OPFOR_2P fvox/fuzz\nHEV_OPFOR_3P fvox/fuzz\nHEV_OPFOR_4P fvox/fuzz\nHEV_OPFOR_5P fvox/fuzz\nHEV_OPFOR_6P fvox/fuzz\nHEV_OPFOR_7P fvox/fuzz\nHEV_OPFOR_8P fvox/fuzz\nHEV_OPFOR_9P fvox/fuzz\nHEV_OPFOR_10P fvox/fuzz\nHEV_OPFOR_11P fvox/fuzz\nHEV_OPFOR_12P fvox/fuzz\nHEV_OPFOR_13P fvox/fuzz\nHEV_OPFOR_14P fvox/fuzz\nHEV_OPFOR_15P fvox/fuzz\nHEV_OPFOR_16P fvox/fuzz\nHEV_OPFOR_17P fvox/fuzz\nHEV_OPFOR_18P fvox/fuzz\nHEV_OPFOR_19P fvox/fuzz\n\n// Munition Level Monitoring\nHEV_OPFOR_AMO0 fvox/blip\n\n// Atmospheric Contaminant Sensors\nHEV_OPFOR_DET0 fvox/blip blip blip\nHEV_OPFOR_DET1 fvox/blip blip blip\nHEV_OPFOR_DET2 fvox/blip blip blip\n" );

-- Opposing Force went for minimalism with these voice lines.
local function SetSuitUpdate( ply, sentence )
    if ( ply.suitPlaylistPack == "opfor" ) then
        if ( string.StartWith( sentence, "MED" ) ) then
            return true;
        end

        if ( string.StartWith( sentence, "HEAL" ) ) then
            return true;
        end

        if ( sentence != "DMG0" && string.StartWith( sentence, "DMG" ) ) then
            return true;
        end

        if ( string.StartWith( sentence, "HLTH" ) ) then
            return true;
        end
    end
end
hook.Add( "SetSuitUpdate", "SuitVoicePack_OPFOR_SetSuitUpdate", SetSuitUpdate );
