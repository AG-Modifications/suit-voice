--[[ Hazardous EnVironment Suit Voice Module ]]

-- ConVars
local suitvoice_enabled_override			= CreateConVar( "suitvoice_enabled_override", "-1", FCVAR_NOTIFY, "Enables the H.E.V. Suit voice module. -1 = Per-Player Choice" );
local suitvoice_counting_override 			= CreateConVar( "suitvoice_counting_override", "-1", FCVAR_NOTIFY, "Enables counting H.E.V. Suit voice lines. -1 = Per-Player Choice" );
local suitvoice_unused_override 			= CreateConVar( "suitvoice_unused_override", "-1", FCVAR_NOTIFY, "Enables unused H.E.V. Suit voice lines. -1 = Per-Player Choice" );
local suitvoice_extra_override 				= CreateConVar( "suitvoice_extra_override", "-1", FCVAR_NOTIFY, "Enables extra H.E.V. Suit voice lines. -1 = Per-Player Choice" );
local suitvoice_pack_override				= CreateConVar( "suitvoice_pack_override", "", FCVAR_NOTIFY, "Sets the H.E.V. Suit to use this voice pack. \"\" = Per-Player Choice" );
local suitvoice_max_override 				= CreateConVar( "suitvoice_max_override", "-1", FCVAR_NOTIFY, "Specifies the maximum amount of H.E.V. Suit voice lines that can be queued. -1 = Per-Player Choice" );

-- Referenced ConVars
local suitvolume							= GetConVar( "suitvolume" );
local hl2_episodic							= GetConVar( "hl2_episodic" );
local sk_battery							= GetConVar( "sk_battery" );
local old_armor								= GetConVar( "player_old_armor" );

-- Constants
local OLD_ARMOR_RATIO 						= 0.2
local OLD_ARMOR_BONUS						= 0.5
local ARMOR_RATIO							= 0.2
local ARMOR_BONUS							= 1.0

local MAX_NORMAL_BATTERY					= 100;
local SUIT_FIRST_UPDATE_TIME				= 0.1;
local SUIT_UPDATE_TIME						= 3.5;
SUIT_NEXT_IN_30SEC							= 30;
SUIT_NEXT_IN_1MIN							= 60;
SUIT_NEXT_IN_5MIN							= 300;
SUIT_NEXT_IN_10MIN							= 600;
SUIT_NEXT_IN_30MIN							= 1800;
SUIT_NEXT_IN_1HOUR							= 3600;

-- Checks to see if an invalid pack was set, just incase it's been deleted.
cvars.AddChangeCallback( "suitvoice_pack_override", function( _, _, new )
    for _, v in pairs( suitVoicePacks ) do
        if ( v.value == new ) then
            return;
        end
    end

    suitvoice_pack_override:SetString( suitvoice_pack_override:GetDefault() );
end )

-- Allows server operators to set global overrides.
local function SetupServerOverrides( ply )
	if ( suitvoice_enabled_override:GetInt() >= 0 ) then
		ply.suitPlaylistEnabled = suitvoice_enabled_override:GetInt();
	end

	if ( suitvoice_counting_override:GetInt() >= 0 ) then
		ply.suitPlaylistCounting = suitvoice_counting_override:GetInt();
	end

	if ( suitvoice_unused_override:GetInt() >= 0 ) then
		ply.suitPlaylistUnused = suitvoice_unused_override:GetInt();
	end

	if ( suitvoice_extra_override:GetInt() >= 0 ) then
		ply.suitPlaylistExtra = suitvoice_extra_override:GetInt();
	end

	if ( suitvoice_pack_override:GetString() != "" ) then
		ply.suitPlaylistPack = suitvoice_pack_override:GetString();
	end

	if ( suitvoice_max_override:GetInt() >= 0 ) then
		ply.suitPlaylistMax = suitvoice_max_override:GetInt();
	end
end

-- Reset a player's suit voice.
local function ResetSuitPlaylist( ply )
	if ( ply:IsBot() ) then
		ply.suitPlaylistEnabled = 1;
		ply.suitPlaylistCounting = 0;
		ply.suitPlaylistUnused = 1;
		ply.suitPlaylistExtra = 1;
		ply.suitPlaylistPack = "hl";
		ply.suitPlaylistMax = 4;
	else
		ply.suitPlaylistEnabled = ply:GetInfoNum( "suitvoice_enabled", 1 );
		ply.suitPlaylistCounting = ply:GetInfoNum( "suitvoice_counting", 0 );
		ply.suitPlaylistUnused = ply:GetInfoNum( "suitvoice_unused", 0 );
		ply.suitPlaylistExtra = ply:GetInfoNum( "suitvoice_extra", 0 );
		ply.suitPlaylistPack = ply:GetInfo( "suitvoice_pack" );
		ply.suitPlaylistMax = ply:GetInfoNum( "suitvoice_max", 4 );
	end

	SetupServerOverrides( ply );

	ply.suitUpdateTime = 0;
	ply.suitPlaylistNext = 0;
	ply.suitPlaylist = {};
	ply.suitPlaylistNoRepeat = {};
	ply.suitPlaylistNoRepeatTime = {};
	for i = 0, ply.suitPlaylistMax, 1 do
		ply.suitPlaylist[i] = nil;
		ply.suitPlaylistNoRepeat[i] = nil;
		ply.suitPlaylistNoRepeatTime[i] = 0.0;
	end

	return nil;
end
hook.Add( "PlayerSpawn", "SuitVoice_Spawn", ResetSuitPlaylist );
hook.Add( "PlayerDeath", "SuitVoice_Death", ResetSuitPlaylist );

-- Emits a voiceline with some variation in pitch.
local function UTIL_EmitSoundSuit( ent, sentence )
	local volume = suitvolume:GetFloat();
	local pitch = 100;
	if ( math.random( 0, 1 ) == 1 ) then
		pitch = math.random( 0, 6 ) + 98;
	end

	if ( volume > 0.05 ) then
		EmitSentence( "HEV_" .. string.upper( ent.suitPlaylistPack ) .. "_" .. sentence, ent:GetPos(), ent:EntIndex(), ( game:SinglePlayer() && CHAN_STATIC || CHAN_AUTO ), volume, 75, 0, pitch );
	end
end

-- Runs and constantly checks to see if a voiceline is queued up.
local function CheckSuitUpdate( ply )
	if ( ply.suitPlaylistEnabled < 1 || !ply:IsSuitEquipped() ) then
		return;
	end

	-- Allow a hook into this function.
	if ( hook.Run( "CheckSuitUpdate", ply ) == true ) then
		return nil;
	end

	if ( CurTime() >= ply.suitUpdateTime && ply.suitUpdateTime > 0 ) then
		local search = ply.suitPlaylistNext;
		local sentence = nil;
		for i = 0, ply.suitPlaylistMax, 1 do
			sentence = ply.suitPlaylist[search];
			if ( sentence != nil ) then
				break;
			end

			search = search + 1;
			if ( search == ply.suitPlaylistMax ) then
				search = 0;
			end
		end

		if ( sentence != nil ) then
			ply.suitPlaylist[search] = nil;
			UTIL_EmitSoundSuit( ply, sentence );
			ply.suitUpdateTime = CurTime() + SUIT_UPDATE_TIME;
		else
			ply.suitUpdateTime = 0;
		end
	end
end
hook.Add( "PlayerPostThink", "SuitVoice_Think", CheckSuitUpdate );

-- Damage types that are tagged as time-based.
local function Damage_IsTimeBased( damageType )
	if ( hl2_episodic:GetBool() ) then
		return ( bit.band( damageType, bit.bor( DMG_PARALYZE, DMG_NERVEGAS, DMG_POISON, DMG_RADIATION, DMG_DROWNRECOVER, DMG_SLOWBURN ) ) ) != 0;
	else
		return ( bit.band( damageType, bit.bor( DMG_PARALYZE, DMG_NERVEGAS, DMG_POISON, DMG_RADIATION, DMG_DROWNRECOVER, DMG_ACID, DMG_SLOWBURN ) ) ) != 0;
	end
end

-- Queues up a new voiceline to be played.
function SetSuitUpdate( ply, sentence, norepeattime )
	if ( sentence == nil ) then
		return;
	end

	-- Allow a hook into this function.
	if ( hook.Run( "SetSuitUpdate", ply, sentence, norepeattime ) == true ) then
		return;
	end

	local empty = -1
	for i = 0, ply.suitPlaylistMax, 1 do
		if ( sentence == ply.suitPlaylistNoRepeat[i] ) then
			if ( ply.suitPlaylistNoRepeatTime[i] < CurTime() ) then
				ply.suitPlaylistNoRepeat[i] = nil;
				ply.suitPlaylistNoRepeatTime[i] = 0.0;
				empty = i;
				break;
			else
				return;
			end
		end

		if ( ply.suitPlaylistNoRepeat[i] == nil ) then
			empty = i;
		end
	end

	if ( norepeattime ) then
		if ( empty < 0 ) then
			empty = math.random( 0, ply.suitPlaylistMax - 1 );
		end

		ply.suitPlaylistNoRepeat[empty] = sentence;
		ply.suitPlaylistNoRepeatTime[empty] = norepeattime + CurTime();
	end

	ply.suitPlaylist[ply.suitPlaylistNext] = sentence;
	ply.suitPlaylistNext = ply.suitPlaylistNext + 1;
	if ( ply.suitPlaylistNext == ply.suitPlaylistMax ) then
		ply.suitPlaylistNext = 0;
	end

	if ( ply.suitUpdateTime <= CurTime() ) then
		if ( ply.suitUpdateTime == 0 ) then
			ply.suitUpdateTime = CurTime() + SUIT_FIRST_UPDATE_TIME;
		else
			ply.suitUpdateTime = CurTime() + SUIT_UPDATE_TIME;
		end
	end
end

-- Detects whatever harm this player has gotten themselves into.
local function OnTakeDamage( ply, dmginfo )
	if ( ( !ply:IsPlayer() || !ply:IsSuitEquipped() ) || ply.suitPlaylistEnabled < 1 ) then
		return;
	end

	-- Armor calculations needed to get a proper diagnosis.
	local bonus = ARMOR_BONUS;
	local ratio = ARMOR_RATIO;
	if ( old_armor:GetBool() ) then
		bonus = OLD_ARMOR_BONUS;
		ratio = OLD_ARMOR_RATIO;
	end

	local lastDamage = dmginfo:GetDamage();
	local damageType = dmginfo:GetDamageType();
	if ( ply:Armor() > 0 && bit.band( damageType, bit.bor( DMG_FALL, DMG_DROWN, DMG_POISON, DMG_RADIATION ) ) == 0 ) then
		local new = lastDamage * ratio;
		local armor = ( lastDamage - new ) * bonus;

		if ( !old_armor:GetBool() ) then
			if ( armor < 1.0 ) then
				armor = 1.0;
			end
		end

		if ( armor > ply:Armor() ) then
			armor = ply:Armor();
			armor = armor * ( 1 / bonus );
			new = lastDamage - armor;
		end

		lastDamage = new;
	end

	local oldHealth = ply:Health();
	local newHealth = oldHealth - lastDamage;

	local trivial = ( newHealth > 75 || lastDamage < 5 );
	local major = ( dmginfo:GetDamage() > 25 );
	local critical = ( newHealth < 30 );
	
	local damageFound = true;
	local requiresAntitoxin = false;
	while ( lastDamage && ( !trivial || Damage_IsTimeBased( damageType ) ) && damageFound && damageType ) do
		damageFound = false;

		if ( bit.band( damageType, DMG_CLUB ) != 0 ) then
			if ( major ) then
				SetSuitUpdate( ply, "DMG4", SUIT_NEXT_IN_30SEC );				-- Minor Fracture Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_CLUB ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, DMG_FALL ) != 0 ) then
			if ( major ) then
				SetSuitUpdate( ply, "DMG5", SUIT_NEXT_IN_30SEC );				-- Major Fracture Detected.
			else
				SetSuitUpdate( ply, "DMG4", SUIT_NEXT_IN_30SEC );				-- Minor Fracture Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_FALL ) );
			damageFound = true;
		end

		if ( bit.band( damageType, DMG_CRUSH ) != 0 ) then
			if ( major ) then
				SetSuitUpdate( ply, "DMG5", SUIT_NEXT_IN_30SEC );				-- Major Fracture Detected.
			else
				SetSuitUpdate( ply, "DMG4", SUIT_NEXT_IN_30SEC );				-- Minor Fracture Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_CRUSH ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, DMG_BULLET ) != 0 ) then
			if ( dmginfo:GetDamage() > 5 ) then
				SetSuitUpdate( ply, "DMG6", SUIT_NEXT_IN_30SEC );				-- Blood Loss Detected.
			elseif ( ply.suitPlaylistUnused > 0 ) then
				SetSuitUpdate( ply, "DMG0", SUIT_NEXT_IN_30SEC );				-- Minor Laceration Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_BULLET ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, DMG_SLASH ) != 0 ) then
			if ( major ) then
				SetSuitUpdate( ply, "DMG1", SUIT_NEXT_IN_30SEC );				-- Major Laceration Detected.
			else
				SetSuitUpdate( ply, "DMG0", SUIT_NEXT_IN_30SEC );				-- Minor Laceration Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_SLASH ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, DMG_SONIC ) != 0 ) then
			if ( major ) then
				SetSuitUpdate( ply, "DMG2", SUIT_NEXT_IN_1MIN );				-- Internal Bleeding Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_SONIC ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, bit.bor( DMG_POISON, DMG_PARALYZE ) ) != 0 ) then
			SetSuitUpdate( ply, "DMG3", SUIT_NEXT_IN_1MIN );					-- Blood Toxin Levels Detected.
			requiresAntitoxin = true

			damageType = bit.band( damageType, bit.bxor( damageType, bit.bor( DMG_POISON, DMG_PARALYZE ) ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, DMG_ACID ) != 0 ) then
			SetSuitUpdate( ply, "DET1", SUIT_NEXT_IN_1MIN );					-- Hazardous Chemical Detected.

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_ACID ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, DMG_NERVEGAS ) != 0 ) then
			SetSuitUpdate( ply, "DET0", SUIT_NEXT_IN_1MIN );					-- Biohazard Detected.

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_NERVEGAS ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, DMG_RADIATION ) != 0 ) then
			SetSuitUpdate( ply, "DET2", SUIT_NEXT_IN_1MIN );					-- Hazardous Radiation Levels Detected.

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_RADIATION ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, DMG_SHOCK ) != 0 ) then
			if ( ply.suitPlaylistUnused > 0 ) then
				SetSuitUpdate( ply, "SHOCK", SUIT_NEXT_IN_1MIN );				-- Electrical Damage Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_SHOCK ) );
			damageFound = true;
		end
				
		if ( bit.band( damageType, DMG_BURN ) != 0 ) then
			if ( ply.suitPlaylistUnused > 0 ) then
				SetSuitUpdate( ply, "FIRE", SUIT_NEXT_IN_1MIN );				-- Extreme Heat Damage Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_BURN ) );
			damageFound = true;
		end

		if ( bit.band( damageType, DMG_BLAST ) != 0 ) then
			if ( major && ply.suitPlaylistExtra > 0 ) then
				SetSuitUpdate( ply, "DMG2", SUIT_NEXT_IN_1MIN );				-- Internal Bleeding Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_BLAST ) );
			damageFound = true;
		end
	end

	if ( lastDamage > 0 ) then
		if ( !trivial && major && oldHealth >= 75 ) then
			SetSuitUpdate( ply, "MED1", SUIT_NEXT_IN_30MIN );					-- Automatic Medical Systems Engaged.

			if ( requiresAntitoxin && ply.suitPlaylistUnused > 0 ) then
				SetSuitUpdate( ply, "HEAL4", SUIT_NEXT_IN_30MIN );				-- Antitoxin Administered.
			else
				SetSuitUpdate( ply, "HEAL7", SUIT_NEXT_IN_30MIN );				-- Morphine Administered.
			end
		end

		if ( oldHealth < 75 ) then
			if ( !trivial && critical ) then
				if ( newHealth < 6 ) then
					SetSuitUpdate( ply, "HLTH3", SUIT_NEXT_IN_10MIN );			-- Emergency, User Death Imminent.
				elseif ( newHealth < 20 ) then
					SetSuitUpdate( ply, "HLTH2", SUIT_NEXT_IN_10MIN );			-- Vital Signs Critical.
				end

				if ( math.random( 0, 3 ) == 0 && oldHealth < 50 ) then
					SetSuitUpdate( ply, "DMG7", SUIT_NEXT_IN_5MIN );			-- Seek Medical Attention.
				end
			end

			if ( Damage_IsTimeBased( dmginfo:GetDamageType() ) ) then
				if ( oldHealth < 50 ) then
					if ( math.random( 0, 3 ) == 0 ) then
						SetSuitUpdate( ply, "DMG7", SUIT_NEXT_IN_5MIN );		-- Seek Medical Attention.
					end
				else
					SetSuitUpdate( ply, "HLTH1", SUIT_NEXT_IN_10MIN );			-- Vital Signs are Dropping.
				end
			end
		end
	end

	return;
end
hook.Add( "EntityTakeDamage", "SuitVoice_OnTakeDamage", OnTakeDamage );

-- Used for counting battery levels on pickup.
local function ItemPickup( ply, item )
	if ( ply.suitPlaylistCounting > 0 && item:GetClass() == "item_battery" ) then
		if ( ply:Armor() < 100 && ply:IsSuitEquipped() ) then
			local batteryLevel = ( ( ply:Armor() + sk_battery:GetInt() ) * 100.0 ) * ( 1.0 / MAX_NORMAL_BATTERY ) + 0.5;
			batteryLevel = math.Clamp( math.floor( batteryLevel / 5 ), 0, 20 );
			if ( batteryLevel > 0 ) then
				batteryLevel = batteryLevel - 1;
			end
			SetSuitUpdate( ply, batteryLevel .. "P", SUIT_NEXT_IN_30SEC );
		end
	end

	return;
end
hook.Add( "PlayerCanPickupItem", "SuitVoice_ItemPickup", ItemPickup );
