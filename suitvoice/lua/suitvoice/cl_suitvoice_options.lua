--[[ Hazardous EnVironment Suit Voice Module Configurator ]]

local function SuitVoiceOptions( panel )
	panel:ClearControls();

	panel:AddControl( "Label", {
		Text = "#suitvoice.options.note",
		Command = "cl_suitvoice_enabled",
	} );

	panel:AddControl( "CheckBox", {
		Label = "#GameUI_Enabled",
		Command = "cl_suitvoice_enabled",
	} );

	panel:AddControl( "CheckBox", {
		Label = "#suitvoice.options.counting",
		Command = "cl_suitvoice_counting",
	} );

	panel:AddControl( "CheckBox", {
		Label = "#suitvoice.options.unused",
		Command = "cl_suitvoice_unused",
	} );

	panel:AddControl( "CheckBox", {
		Label = "#suitvoice.options.extra",
		Command = "cl_suitvoice_extra",
	} );

	panel:AddControl( "Slider", {
		Type = "int",
		Label = "#suitvoice.options.max",
		Command = "cl_suitvoice_max",
		Min = 1,
		Max = 16
	} );

	-- Parse over the voicepacks and add them to a single combo box for selecting.
	local voicepackComboBox, _ = panel:ComboBox( "#suitvoice.options.voicepack", "cl_suitvoice_pack" );
	for _, v in pairs( suitVoicePacks ) do
		if ( v.name == nil || v.value == nil ) then
			break;
		end

		voicepackComboBox:AddChoice( v.name, v.value );
	end
end

hook.Add( "PopulateToolMenu", "PopulateSuitVoiceMenus", function()
	spawnmenu.AddToolMenuOption( "Options", "Half-Life", "SuitVoiceOptions", "Suit Voice", "", "", SuitVoiceOptions );
end );
