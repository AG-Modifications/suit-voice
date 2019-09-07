--[[ Hazardous EnVironment Suit Voice Module ]]
-- Original Code: Valve
-- Lua Port: Agent Agrimar

suitVoicePacks = {};
function RegisterSuitVoicePack( name, value, sentences )
    table.Add( suitVoicePacks, { {
        name = name,
        value = value,
        rawsentencedata = sentences
    } } )
end

if ( !game.SinglePlayer() ) then
    print( "Custom H.E.V. Suit voice packs can't support remote servers without assistance from Facepunch..." );
    print( "If you can, tell them to add a 'PrecacheSentenceFile' Lua binding to client!" );
else
    -- Check to see if there's any addon packs.
    local files, directories = file.Find( "autorun/suitvoice/packs/*.lua", "LUA" );
    for _, luaPackFile in pairs( files ) do
        include( "suitvoice/packs/" .. luaPackFile );
        if SERVER then
            AddCSLuaFile( "suitvoice/packs/" .. luaPackFile );
        end
        print( "Included H.E.V. Suit Voice Pack: " .. string.StripExtension( luaPackFile ) );
    end

    if SERVER then
        -- Parse over the table and create sentence files necessary for use by the suit voice.
        for _, v in pairs( suitVoicePacks ) do
            if ( v.rawsentencedata == nil ) then
                break;
            end

            if ( !file.Exists( "suitvoice/packs", "DATA" ) ) then
                file.CreateDir( "suitvoice/packs" );
                file.CreateDir( "suitvoice/packs/loose" );
            end

            file.Write( "suitvoice/packs/" .. v.value .. ".txt", v.rawsentencedata );
        end

        local files, directories = file.Find( "suitvoice/packs/loose/*.txt", "DATA" );
        for _, sentencePackFile in pairs( files ) do
            PrecacheSentenceFile( "data/suitvoice/packs/loose/" .. sentencePackFile );
        end

        -- Parse any sentence file found here for use by the suit voice.
        local files, directories = file.Find( "suitvoice/packs/*.txt", "DATA" );
        for _, sentencePackFile in pairs( files ) do
            -- If we find the same file here, then we're using the loose one instead.
            if ( !file.Exists( "suitvoice/packs/loose/" .. sentencePackFile, "DATA" ) ) then
                if ( file.Exists( "autorun/suitvoice/packs/" .. string.StripExtension( sentencePackFile ) .. ".lua", "LUA" ) ) then
                    PrecacheSentenceFile( "data/suitvoice/packs/" .. sentencePackFile );
                end
            end

            file.Delete( "suitvoice/packs/" .. sentencePackFile );
        end
    end
end

-- Now load the important parts.
if SERVER then
    include( "suitvoice/sv_suitvoice_core.lua" );

    AddCSLuaFile( "suitvoice/cl_suitvoice_core.lua" );
    AddCSLuaFile( "suitvoice/cl_suitvoice_localization.lua" );
    AddCSLuaFile( "suitvoice/cl_suitvoice_options.lua" );
elseif CLIENT then
    include( "suitvoice/cl_suitvoice_core.lua" );
    include( "suitvoice/cl_suitvoice_localization.lua" );
    include( "suitvoice/cl_suitvoice_options.lua" );
end

local packConVar = suitvoice_pack;
if SERVER then
    packConVar = suitvoice_pack_override;
end

-- Checks to see if an invalid pack was set, just incase it's been deleted.
local function CheckVoicePackConVar( value )
    if SERVER then
        if ( value == "" ) then
            return;
        end
    end

    for _, v in pairs( suitVoicePacks ) do
        if ( value == v.value ) then
            return;
        end
    end

    packConVar:SetString( packConVar:GetDefault() );
end

CheckVoicePackConVar( packConVar:GetString() );
cvars.AddChangeCallback( packConVar:GetName(), function( _, _, new )
    CheckVoicePackConVar( new );
end )
