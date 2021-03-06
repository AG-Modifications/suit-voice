--[[ Hazardous EnVironment Suit Voice Module ]]

-- ConVars
suitvoice_enabled                           = CreateClientConVar( "cl_suitvoice_enabled", "1", true, true, "Enables the H.E.V. Suit voice module." );
suitvoice_counting                          = CreateClientConVar( "cl_suitvoice_counting", "0", true, true, "Enables counting H.E.V. Suit voice lines." );
suitvoice_unused                            = CreateClientConVar( "cl_suitvoice_unused", "0", true, true, "Enables unused H.E.V. Suit voice lines." );
suitvoice_extra                             = CreateClientConVar( "cl_suitvoice_extra", "0", true, true, "Enables extra H.E.V. Suit voice lines." );
suitvoice_pack                              = CreateClientConVar( "cl_suitvoice_pack", "hl", true, true, "The current H.E.V. Suit voice pack." );
suitvoice_max                               = CreateClientConVar( "cl_suitvoice_max", "4", true, true, "Specifies the maximum amount of H.E.V. Suit voice lines that can be queued." );
