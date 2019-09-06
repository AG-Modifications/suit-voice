--[[ Hazardous EnVironment Suit Voice Module ]]

local currentLang = GetConVar( "gmod_language" ):GetString();
local langFile = "resource/localization/%s/suitvoice.properties";

local BaseLanguageChanged = LanguageChanged;
function LanguageChanged( lang )
	if ( BaseLanguageChanged != nil ) then
		BaseLanguageChanged( lang );
	end

	currentLang = lang;

	local langPath = string.format( langFile, currentLang );
    if ( !file.Exists( langPath, "GAME" ) ) then
        langPath = string.format( langFile, 'en' );
	end
	
	if ( !file.Exists( langPath, 'GAME' ) ) then
        return;
    end

    local langData = file.Read( langPath, "GAME" );
    local langKeys = string.Split( langData, "\n" );

    for _, key in pairs( langKeys ) do
        key = string.Trim( key );
		if ( string.len( key ) == 0 || string.sub( key, 0, 1 ) == '#' ) then
			continue;
		end

        local _, _, key, value = string.find( key, '([%w%p_]+)=(.+)' );
        language.Add( key, value );
    end
end

if ( BaseLanguageChanged == LanguageChanged ) then
	BaseLanguageChanged = nil;
end

LanguageChanged( currentLang );
