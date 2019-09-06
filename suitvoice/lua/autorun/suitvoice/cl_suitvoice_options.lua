--[[ Hazardous EnVironment Suit Voice Module Configurator ]]

local function SuitVoiceOptions( panel )
	panel:ClearControls();

	panel:AddControl( "Label", {
		Text = "#suitvoice.options.note",
		Command = "suitvoice_enabled",
	} );

	panel:AddControl( "CheckBox", {
		Label = "#GameUI_Enabled",
		Command = "suitvoice_enabled",
	} );

	panel:AddControl( "CheckBox", {
		Label = "#suitvoice.options.counting",
		Command = "suitvoice_counting",
	} );

	panel:AddControl( "CheckBox", {
		Label = "#suitvoice.options.unused",
		Command = "suitvoice_unused",
	} );

	panel:AddControl( "CheckBox", {
		Label = "#suitvoice.options.extra",
		Command = "suitvoice_extra",
	} );

	panel:AddControl( "Slider", {
		Type = "int",
		Label = "#suitvoice.options.max",
		Command = "suitvoice_max",
		Min = 1,
		Max = 16
	} );

	-- Parse over the voicepacks and add them to a single combo box for selecting.
	local voicepackComboBox, _ = panel:ComboBox( "#suitvoice.options.voicepack", "suitvoice_pack" );
	for _, v in pairs( suitVoicePacks ) do
		if ( v.name == nil || v.value == nil ) then
			break;
		end

		voicepackComboBox:AddChoice( v.name, v.value );
	end

	local issueLink = panel:AddControl( "Button", {
		Label = "#suitvoice.options.report"
	} );
	issueLink.DoClick = function()
		gui.OpenURL( "http://steamcommunity.com/workshop/filedetails/discussion/470004201/530645446317199228/" )
	end
end

hook.Add( "PopulateToolMenu", "PopulateSuitVoiceMenus", function()
	spawnmenu.AddToolMenuOption( "Utilities", "Half-Life", "SuitVoiceOptions", "Suit Voice", "", "", SuitVoiceOptions );
end );
