--[[ Hazardous EnVironment Suit Voice Module ]]

-- Client ConVars
suitvoice_enabled                           = CreateClientConVar( "suitvoice_enabled", "1", true, true, "Enables the H.E.V. Suit voice module." );
suitvoice_counting                          = CreateClientConVar( "suitvoice_counting", "0", true, true, "Enables counting H.E.V. Suit voice lines." );
suitvoice_unused                            = CreateClientConVar( "suitvoice_unused", "0", true, true, "Enables unused H.E.V. Suit voice lines." );
suitvoice_extra                             = CreateClientConVar( "suitvoice_extra", "0", true, true, "Enables extra H.E.V. Suit voice lines." );
suitvoice_pack                              = CreateClientConVar( "suitvoice_pack", "hl", true, true, "The current H.E.V. Suit voice lines." );
suitvoice_max                               = CreateClientConVar( "suitvoice_max", "4", true, true, "Specifies the maximum amount of H.E.V. Suit voice lines that can be queued." );

-- Checks to see if an invalid pack was set, just incase it's been deleted.
local function CheckVoicePackConVar( value )
    for _, v in pairs( suitVoicePacks ) do
        if ( v.value == value ) then
            return;
        end
    end

    suitvoice_pack:SetString( suitvoice_pack:GetDefault() );
end

CheckVoicePackConVar( suitvoice_pack:GetString() );
cvars.AddChangeCallback( "suitvoice_pack", function( _, _, new )
    CheckVoicePackConVar( new );
end )