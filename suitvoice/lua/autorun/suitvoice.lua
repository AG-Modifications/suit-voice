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

-- Load the important parts.
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

    -- Parse any sentence file found here for use by the suit voice.
    local files, directories = file.Find( "suitvoice/packs/*.txt", "DATA" );
    for _, sentencePackFile in pairs( files ) do
        local sentencePackFileNoExt = string.StripExtension( sentencePackFile );
        if ( !file.Exists( "autorun/suitvoice/packs/" .. sentencePackFileNoExt .. ".lua", "LUA" ) ) then
            file.Delete( "suitvoice/packs/" .. sentencePackFile );
            return;
        end

        PrecacheSentenceFile( "data/suitvoice/packs/" .. sentencePackFile );
        file.Delete( "suitvoice/packs/" .. sentencePackFile );
    end

    local files, directories = file.Find( "suitvoice/packs/loose/*.txt", "DATA" );
    for _, sentencePackFile in pairs( files ) do
        PrecacheSentenceFile( "data/suitvoice/packs/loose" .. sentencePackFile );
    end
end
