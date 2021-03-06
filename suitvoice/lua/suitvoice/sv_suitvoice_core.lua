--[[ Hazardous EnVironment Suit Voice Module ]]

-- ConVars
suitvoice_enabled							= CreateConVar( "sv_suitvoice_enabled", "-1", bit.bor( FCVAR_ARCHIVE, FCVAR_NOTIFY ), "Enables the H.E.V. Suit voice module. -1 = Use Client Value" );
suitvoice_counting 							= CreateConVar( "sv_suitvoice_counting", "-1", bit.bor( FCVAR_ARCHIVE, FCVAR_NOTIFY ), "Enables counting H.E.V. Suit voice lines. -1 = Use Client Value" );
suitvoice_unused 							= CreateConVar( "sv_suitvoice_unused", "-1", bit.bor( FCVAR_ARCHIVE, FCVAR_NOTIFY ), "Enables unused H.E.V. Suit voice lines. -1 = Use Client Value" );
suitvoice_extra 							= CreateConVar( "sv_suitvoice_extra", "-1", bit.bor( FCVAR_ARCHIVE, FCVAR_NOTIFY ), "Enables extra H.E.V. Suit voice lines. -1 = Use Client Value" );
suitvoice_pack								= CreateConVar( "sv_suitvoice_pack", "", bit.bor( FCVAR_ARCHIVE, FCVAR_NOTIFY ), "Sets the H.E.V. Suit to use this voice pack. \"\" = Use Client Value" );
suitvoice_max 								= CreateConVar( "sv_suitvoice_max", "-1", bit.bor( FCVAR_ARCHIVE, FCVAR_NOTIFY ), "Specifies the maximum amount of H.E.V. Suit voice lines that can be queued. -1 = Use Client Value" );

-- Referenced ConVars
local suitvolume							= GetConVar( "suitvolume" );
local hl2_episodic							= GetConVar( "hl2_episodic" );
local sk_battery							= GetConVar( "sk_battery" );
local old_armor								= GetConVar( "player_old_armor" );

-- Constants
local OLD_ARMOR_RATIO 						= 0.2;
local OLD_ARMOR_BONUS						= 0.5;
local ARMOR_RATIO							= 0.2;
local ARMOR_BONUS							= 1.0;
local SF_SUIT_SHORTLOGON					= 0x0001;

local MAX_NORMAL_BATTERY					= 100;
local SUIT_FIRST_UPDATE_TIME				= 0.1;
local SUIT_UPDATE_TIME						= 3.5;
SUIT_NEXT_IMMEDIATELY						= 0;
SUIT_NEXT_IN_30SEC							= 30;
SUIT_NEXT_IN_1MIN							= 60;
SUIT_NEXT_IN_5MIN							= 300;
SUIT_NEXT_IN_10MIN							= 600;
SUIT_NEXT_IN_30MIN							= 1800;
SUIT_NEXT_IN_1HOUR							= 3600;


-- Allows server operators to set global overrides.
local function SetupServerOverrides( ply )
	if ( suitvoice_enabled:GetInt() >= 0 ) then
		ply.suitPlaylistEnabled = suitvoice_enabled:GetInt();
	end

	if ( suitvoice_counting:GetInt() >= 0 ) then
		ply.suitPlaylistCounting = suitvoice_counting:GetInt();
	end

	if ( suitvoice_unused:GetInt() >= 0 ) then
		ply.suitPlaylistUnused = suitvoice_unused:GetInt();
	end

	if ( suitvoice_extra:GetInt() >= 0 ) then
		ply.suitPlaylistExtra = suitvoice_extra:GetInt();
	end

	if ( suitvoice_pack:GetString() != "" ) then
		ply.suitPlaylistPack = suitvoice_pack:GetString();
	end

	if ( suitvoice_max:GetInt() >= 0 ) then
		ply.suitPlaylistMax = suitvoice_max:GetInt();
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
		ply.suitPlaylistEnabled = ply:GetInfoNum( "cl_suitvoice_enabled", 1 );
		ply.suitPlaylistCounting = ply:GetInfoNum( "cl_suitvoice_counting", 0 );
		ply.suitPlaylistUnused = ply:GetInfoNum( "cl_suitvoice_unused", 0 );
		ply.suitPlaylistExtra = ply:GetInfoNum( "cl_suitvoice_extra", 0 );
		ply.suitPlaylistPack = ply:GetInfo( "cl_suitvoice_pack" );
		ply.suitPlaylistMax = ply:GetInfoNum( "cl_suitvoice_max", 4 );
	end

	-- Check if they're using a valid voice pack, and if not, default them to Half-Life.
	local hasVoicePack = false;
	for _, v in pairs( suitVoicePacks ) do
		if ( ply.suitPlaylistPack == v.value ) then
			hasVoicePack = true;
        	break;
        end
	end
	
	if ( hasVoicePack == false ) then
		ply.suitPlaylistPack = "hl";
	end

	SetupServerOverrides( ply );

	ply.suitUpdateTime = 0;
	ply.suitPlaylistNext = 0;
	ply.suitPlaylist = {};
	ply.suitPlaylistNoRepeat = {};
	ply.suitPlaylistNoRepeatTime = {};
	for i = 0, ply.suitPlaylistMax do
		ply.suitPlaylist[i] = nil;
		ply.suitPlaylistNoRepeat[i] = nil;
		ply.suitPlaylistNoRepeatTime[i] = 0.0;
	end

	ply.activeWeapon = nil;
	ply.ammoPrimaryEmpty = false;
	ply.ammoSecondaryEmpty = false;
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
		local sentencePrefix = string.upper( ent.suitPlaylistPack ) .. "_";
		EmitSentence( "HEV_" .. sentencePrefix .. sentence, ent:GetPos(), ent:EntIndex(), CHAN_STATIC, volume, 75, 0, pitch );
	end
end

-- Play a suit update if it's time to.
local function CheckSuitUpdate( ply )
	-- Ignore suit updates if this player has no suit or disabled the playlist altogether.
	if ( ply.suitPlaylistEnabled < 1 || !ply:IsSuitEquipped() ) then
		return;
	end

	-- Allow a hook into this function.
	if ( hook.Run( "CheckSuitUpdate", ply ) == true ) then
		return;
	end

	if ( CurTime() >= ply.suitUpdateTime && ply.suitUpdateTime > 0 ) then
		-- Play a sentence at the end of the queue.
		local search = ply.suitPlaylistNext;
		local sentence = nil;
		for i = 0, ply.suitPlaylistMax do
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
			-- Play the sentence from the player.
			ply.suitPlaylist[search] = nil;
			UTIL_EmitSoundSuit( ply, sentence );
			ply.suitUpdateTime = CurTime() + SUIT_UPDATE_TIME;
		else
			-- Queue is empty, don't check.
			ply.suitUpdateTime = 0;
		end
	end

	-- Warn if the ammo for their current weapon is empty.
	-- NOTE: This isn't accurate to the original code, 
	-- but it's the best way to do this at the moment.
	if ( ply.activeWeapon != nil ) then
		local ammoType = ply.activeWeapon:GetPrimaryAmmoType();
		if ( ammoType != -1 && ply.activeWeapon:Clip1() <= 0 && ply:GetAmmoCount( ammoType ) == 0 ) then
			if ( ply.ammoPrimaryEmpty == false ) then
				SetSuitUpdate( ply, "AMO0", SUIT_NEXT_IMMEDIATELY );
				ply.ammoPrimaryEmpty = true;
			end
		else
			ply.ammoPrimaryEmpty = false;
		end

		ammoType = ply.activeWeapon:GetSecondaryAmmoType();
		if ( ammoType != -1 && ply.activeWeapon:Clip2() <= 0 && ply:GetAmmoCount( ammoType ) == 0 ) then
			if ( ply.ammoSecondaryEmpty == false ) then
				SetSuitUpdate( ply, "AMO0", SUIT_NEXT_IMMEDIATELY );
				ply.ammoSecondaryEmpty = true;
			end
		else
			ply.ammoSecondaryEmpty = false;
		end
	else
		ply.ammoPrimaryEmpty = false;
		ply.ammoSecondaryEmpty = false;
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

-- Adds a sentence to suit playlist queue.
function SetSuitUpdate( ply, sentence, norepeattime )
	if ( sentence == nil ) then
		return;
	end

	-- Allow a hook into this function.
	if ( hook.Run( "SetSuitUpdate", ply, sentence, norepeattime ) == true ) then
		return;
	end

	-- Check norepeat list - this list lets us cancel
	-- the playback of words or sentences that have already
	-- been played within a certain time.
	local empty = -1
	for i = 0, ply.suitPlaylistMax do
		if ( sentence == ply.suitPlaylistNoRepeat[i] ) then
			-- This sentence or group is already in the norepeat list.
			if ( ply.suitPlaylistNoRepeatTime[i] < CurTime() ) then
				-- The norepeattime has expired, clear it out.
				ply.suitPlaylistNoRepeat[i] = nil;
				ply.suitPlaylistNoRepeatTime[i] = 0.0;
				empty = i;
				break;
			else
				-- Don't play, this sentence is still marked with a norepeattime.
				return;
			end
		end

		-- Keep track of an empty slot
		if ( ply.suitPlaylistNoRepeat[i] == nil ) then
			empty = i;
		end
	end

	-- Sentence was not found in the norepeattime list, add it if norepeattime was given.
	if ( norepeattime ) then
		if ( empty < 0 ) then
			-- Pick a random slot to take over.
			empty = math.random( 0, ply.suitPlaylistMax - 1 );
		end

		ply.suitPlaylistNoRepeat[empty] = sentence;
		ply.suitPlaylistNoRepeatTime[empty] = norepeattime + CurTime();
	end

	-- Find an empty spot in the queue, or overwrite last spot.
	ply.suitPlaylist[ply.suitPlaylistNext] = sentence;
	ply.suitPlaylistNext = ply.suitPlaylistNext + 1;
	if ( ply.suitPlaylistNext == ply.suitPlaylistMax ) then
		ply.suitPlaylistNext = 0;
	end

	if ( ply.suitUpdateTime <= CurTime() ) then
		if ( ply.suitUpdateTime == 0 ) then
			-- Play queue is empty, don't delay for too long before playback.
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

	-- Armor calculations are needed to get a proper diagnosis.
	local bonus = ARMOR_BONUS;
	local ratio = ARMOR_RATIO;
	if ( old_armor:GetBool() ) then
		bonus = OLD_ARMOR_BONUS;
		ratio = OLD_ARMOR_RATIO;
	end
	
	-- Keep track of amount of damage last sustained.
	local lastDamage = dmginfo:GetDamage();
	local damageType = dmginfo:GetDamageType();

	if ( bit.band( damageType, DMG_BLAST ) && !game.SinglePlayer() ) then
		-- Blasts damage armor more.
		bonus = bonus * 2;
	end

	-- Armor doesn't protect against fall or drown damage!
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

	-- How bad is it, doc?
	local trivial = ( newHealth > 75 || lastDamage < 5 );
	local major = ( dmginfo:GetDamage() > 25 );
	local critical = ( newHealth < 30 );
	
	-- Handle all bits set in this damage message,
	-- let the suit give player the diagnosis.
	local damageFound = true;
	local requiresAntidote = false;
	while ( lastDamage && ( !trivial || Damage_IsTimeBased( damageType ) ) && damageFound && damageType ) do
		damageFound = false;

		if ( bit.band( damageType, DMG_CLUB ) != 0 ) then
			if ( major ) then
				SetSuitUpdate( ply, "DMG4", SUIT_NEXT_IN_30SEC );				-- Minor Fracture Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_CLUB ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, bit.bor( DMG_FALL, DMG_CRUSH ) ) != 0 ) then
			if ( major ) then
				SetSuitUpdate( ply, "DMG5", SUIT_NEXT_IN_30SEC );				-- Major Fracture Detected.
			else
				SetSuitUpdate( ply, "DMG4", SUIT_NEXT_IN_30SEC );				-- Minor Fracture Detected.
			end

			damageType = bit.band( damageType, bit.bxor( damageType, bit.bor( DMG_FALL, DMG_CRUSH ) ) );
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

		if ( bit.band( damageType, DMG_PARALYZE ) != 0 ) then
			SetSuitUpdate( ply, "DMG3", SUIT_NEXT_IN_1MIN );					-- Blood-Toxin Levels Detected.

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_PARALYZE ) );
			damageFound = true;
		end
		
		if ( bit.band( damageType, DMG_POISON ) != 0 ) then
			SetSuitUpdate( ply, "DMG3", SUIT_NEXT_IN_1MIN );					-- Blood-Toxin Levels Detected.
			requiresAntidote = true

			damageType = bit.band( damageType, bit.bxor( damageType, DMG_POISON ) );
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
			-- First time we take major damage,
			-- turn automedic on if not on.
			SetSuitUpdate( ply, "MED1", SUIT_NEXT_IN_30MIN );					-- Automatic Medical Systems Engaged.

			if ( requiresAntidote && ply.suitPlaylistUnused > 0 ) then
				SetSuitUpdate( ply, "HEAL5", SUIT_NEXT_IN_30MIN );				-- Antidote Administered.
			else
				SetSuitUpdate( ply, "HEAL7", SUIT_NEXT_IN_30MIN );				-- Morphine Administered.
			end
		end

		if ( oldHealth < 75 ) then
			if ( !trivial && critical ) then
				-- Already took major damage, now it's critical...
				if ( newHealth < 6 ) then
					SetSuitUpdate( ply, "HLTH3", SUIT_NEXT_IN_10MIN );			-- Emergency, User Death Imminent.
				elseif ( newHealth < 20 ) then
					SetSuitUpdate( ply, "HLTH2", SUIT_NEXT_IN_10MIN );			-- Vital Signs Critical.
				end

				-- Give critical health warnings.
				if ( math.random( 0, 3 ) == 0 && oldHealth < 50 ) then
					SetSuitUpdate( ply, "DMG7", SUIT_NEXT_IN_5MIN );			-- Seek Medical Attention.
				end
			end

			-- If we're taking time based damage, warn about its continuing effects.
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
	if ( ply.suitPlaylistCounting > 0 && ( item:GetClass() == "item_battery" || item:GetClass() == "hl1_item_battery" ) ) then
		if ( ply:IsSuitEquipped() && ply:Armor() < MAX_NORMAL_BATTERY ) then
			local batteryLevel = ( math.min( ply:Armor() + sk_battery:GetInt(), MAX_NORMAL_BATTERY ) * 100.0 ) * ( 1.0 / MAX_NORMAL_BATTERY ) + 0.5;
			batteryLevel = math.floor( batteryLevel / 5 );
			if ( batteryLevel > 0 ) then
				batteryLevel = batteryLevel - 1;
			end

			SetSuitUpdate( ply, batteryLevel .. "P", SUIT_NEXT_IN_30SEC );
		end
	elseif ( !ply:IsSuitEquipped() && item:GetClass() == "item_suit" ) then
		if ( bit.band( item:GetSpawnFlags(), SF_SUIT_SHORTLOGON ) > 0 ) then
			SetSuitUpdate( ply, "A0", SUIT_NEXT_IMMEDIATELY );
		else
			SetSuitUpdate( ply, "AAx", SUIT_NEXT_IMMEDIATELY );
		end
	end
end
hook.Add( "PlayerCanPickupItem", "SuitVoice_ItemPickup", ItemPickup );

-- Used for detecting the active weapon, and if its empty early.
local function SwitchWeapon( ply, oldWeapon, newWeapon )
	ply.activeWeapon = newWeapon;

	if ( oldWeapon != newWeapon ) then
		local ammoType = ply.activeWeapon:GetPrimaryAmmoType();
		ply.ammoPrimaryEmpty = ammoType != -1 && ply.activeWeapon:Clip1() <= 0 && ply:GetAmmoCount( ammoType ) == 0;

		ammoType = ply.activeWeapon:GetSecondaryAmmoType();
		ply.ammoSecondaryEmpty = ammoType != -1 && ply.activeWeapon:Clip2() <= 0 && ply:GetAmmoCount( ammoType ) == 0;
	end
end
hook.Add( "PlayerSwitchWeapon", "SuitVoice_SwitchWeapon", SwitchWeapon );


-- Console Commands

-- Returns the requested player via SteamID.
local function GetTargetedPlayer( ply, id )
	-- I think its possible that someone could have the same number for any of these 
	-- three ID identifiers, but for now we'll assume that they're all different.
	local targetedPlayer = ply;
	if ( id != nil ) then
		targetedPlayer = player.GetBySteamID64( id );
		if ( targetedPlayer == false ) then
			targetedPlayer = player.GetBySteamID( id );
			if ( targetedPlayer == false ) then
				targetedPlayer = player.GetByID( id );
				if ( targetedPlayer == nil ) then
					targetedPlayer = ply;
				end
			end
		end
	end

	return targetedPlayer;
end

function SuitUpdateReset( ply, _, args )
	if ( ply == nil || !ply:IsAdmin() ) then
		return;
	end

	local targetedPlayer = GetTargetedPlayer( ply, args[1] );
	if ( targetedPlayer != nil ) then
		ResetSuitPlaylist( targetedPlayer );
	else
		for _, plyOther in ipairs( player.GetAll() ) do
			ResetSuitPlaylist( plyOther );
		end
	end
end
concommand.Add( "sv_suitvoice_reset", SuitUpdateReset, nil, "Resets the suit voice system." );

function SuitUpdateSpeak( ply, _, args )
	if ( ply == nil || !ply:IsAdmin() ) then
		return;
	end

	local targetedPlayer = GetTargetedPlayer( ply, args[3] );
	if ( targetedPlayer != nil ) then
		SetSuitUpdate( targetedPlayer, args[1], args[2] );
	else
		for _, plyOther in ipairs( player.GetAll() ) do
			SetSuitUpdate( plyOther, args[1], args[2] );
		end
	end
end
concommand.Add( "sv_suitvoice_speak", SuitUpdateSpeak, nil, "Speaks a suit voice line." );
