#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include "include/adt_trie.inc"
#include "include/keyvalues.inc"
#include "stratroulette/functional-interface.sp"

#define STRAT_FILE "addons/sourcemod/configs/stratroulette/rounds.txt"
#define LOCATION_FILE "addons/sourcemod/configs/stratroulette/locations.txt"
#define TUNNEL_VISION_OVERLAY "overlays/stratroulette/tunnel_vision_overlay"
#define SPRITE 	"materials/sprites/dot.vmt"
#define PRIMARY_LENGTH 24
#define AUTO_WEAPONS_LENGTH 20
#define SECONDARY_LENGTH 10
#define SMOKE_RADIUS 165
#define	CLIENTWIDTH	32.0
#define	CLIENTHEIGHT 72.0
#define MAX_MESSAGE_LENGTH 250
#define EF_BONEMERGE (1 << 0)
#define EF_PARENT_ANIMATES (1 << 9)

// Convar handles
ConVar g_AutoStart;
ConVar g_AutoStartMinPlayers;
ConVar g_AllowVoting;

// Primary weapons
new const String:WeaponPrimary[PRIMARY_LENGTH][] =  {
	"weapon_ak47", "weapon_aug", "weapon_bizon",
	"weapon_famas", "weapon_g3sg1", "weapon_galilar",
	"weapon_m249", "weapon_m4a1", "weapon_mac10",
	"weapon_mag7", "weapon_mp7", "weapon_mp9",
	"weapon_negev", "weapon_nova", "weapon_p90",
	"weapon_sawedoff", "weapon_scar20", "weapon_sg556",
	"weapon_ssg08", "weapon_ump45", "weapon_xm1014",
	"weapon_m4a1_silencer", "weapon_awp", "weapon_mp5sd"
};

// Automatic weapons
new const String:AutoWeapons[AUTO_WEAPONS_LENGTH][] = {
	"weapon_cz75a", "weapon_ak47", "weapon_aug",
	"weapon_famas", "weapon_g3sg1", "weapon_galilar",
	"weapon_m249", "weapon_m4a1", "weapon_mac10",
	"weapon_mp7", "weapon_mp9", "weapon_negev",
	"weapon_p90", "weapon_scar20", "weapon_sg556",
	"weapon_ump45", "weapon_xm1014", "weapon_m4a1_silencer",
	"weapon_mp5sd", "weapon_bizon"
};

// Damage taken when missing with primary
new const PrimaryDamage[PRIMARY_LENGTH] = {
	10, 10, 5,
	10, 3, 10,
	3, 10, 5,
	20, 5, 5,
	3, 20, 5,
	20, 50, 10,
	50, 7, 20,
	10, 50, 10
};

// Clip sizes of primary weapons
new const PrimaryClipSize[PRIMARY_LENGTH] = {
	30, 30, 64,
	25, 20, 35,
	100, 30, 30,
	5, 30, 30,
	150, 8, 50,
	7, 20, 30,
	10, 25, 7,
	25, 10, 30
};

// Secondary weapons
new const String:WeaponSecondary[SECONDARY_LENGTH][] =  {
	"weapon_deagle", "weapon_elite", "weapon_fiveseven",
	"weapon_glock", "weapon_hkp2000", "weapon_p250",
	"weapon_tec9", "weapon_cz75a", "weapon_usp_silencer",
	"weapon_revolver"
};

// Damage taken when missing with secondary
new const SecondaryDamage[SECONDARY_LENGTH] = {
	20, 5, 10,
	5, 10, 10,
	5, 5, 10,
	20
};

// Clip sizes of secondary weapons
new const SecondaryClipSize[PRIMARY_LENGTH] = {
	7, 30, 20,
	20, 13, 13,
	18, 12, 12,
	8
};

// Grenades
new const GrenadesAll[] =  { 15, 17, 16, 14, 18, 17 };

new bool:inGame = false;
new bool:pugSetupLoaded = false;

// Round variables
FunctionalInterface resetFunctions[128];
int resetFunctionsLength = 0;

int lastRound = -1;

new bool:nextRoundVoted = false;
new String:voteRoundNumber[16];
new bool:forceNextRound = false;
new String:forceRoundNumber[16];

int g_offsCollisionGroup;
int g_offsBombTicking;

// Cvars
new Handle:sv_allow_thirdperson;
new Handle:sv_infinite_ammo;
new Handle:sv_gravity;
new Handle:weapon_accuracy_nospread;
new Handle:weapon_recoil_cooldown;
new Handle:weapon_recoil_decay1_exp;
new Handle:weapon_recoil_decay2_exp;
new Handle:weapon_recoil_decay2_lin;
new Handle:weapon_recoil_scale;
new Handle:weapon_recoil_suppression_shots;
new Handle:weapon_recoil_view_punch_extra;
new Handle:sv_accelerate;
new Handle:sv_airaccelerate;
new Handle:sv_friction;
new Handle:mp_radar_showall;
new Handle:sv_cheats;
new Handle:mp_default_team_winner_no_objective;
new Handle:mp_ignore_round_win_conditions;
new Handle:mp_freezetime;
new Handle:mp_plant_c4_anywhere;
new Handle:mp_c4timer;
new Handle:mp_c4_cannot_be_defused;
new Handle:mp_give_player_c4;
new Handle:mp_death_drop_c4
new Handle:mp_anyone_can_pickup_c4;
new Handle:mp_death_drop_gun;
new Handle:mp_death_drop_defuser;
new Handle:mp_death_drop_grenade;
new Handle:mp_solid_teammates;
new Handle:mp_respawn_on_death_ct;
new Handle:mp_respawn_on_death_t;
new Handle:host_timescale;
new Handle:sv_autobunnyhopping;
new Handle:sv_enablebunnyhopping;
new Handle:sv_maxvelocity;
new Handle:mp_friendlyfire;

new Handle:hReload;

#include "stratroulette/round-modifiers-include.sp"
#include "stratroulette/events.sp"
#include "stratroulette/presets.sp"
#include "stratroulette/vote.sp"
#include "stratroulette/util.sp"
#include "stratroulette/readfile.sp"
#include "stratroulette/props.sp"
#include "stratroulette/pugsetup-integration.sp"

#pragma semicolon 1

public Plugin:myinfo =  {
	name = "Strat Roulette",
	author = "Extremelyd1",
	description = "Random strats every round",
	version = "3.0"
}

public OnPluginStart() {

	//** Convars **//
	g_AutoStart = CreateConVar(
		"sm_sr_auto_start", "0",
		"Whether to automagically start the game when enough players are present"
	);
	g_AutoStartMinPlayers = CreateConVar(
		"sm_sr_auto_start_min_players", "4",
		"The minimum number of players required to automagically start the game"
	);
	g_AllowVoting = CreateConVar(
		"sm_sr_allow_voting", "1",
		"Whether to allow players to vote on the next round"
	);

	//** Create and exec plugin's configuration file **//
	AutoExecConfig(true, "stratroulette", "sourcemod/stratroulette");

	//** Commands **//
	RegAdminCmd("sm_start", cmd_start, ADMFLAG_ROOT, "Command to start the match");
	RegAdminCmd("sm_end", cmd_end, ADMFLAG_ROOT, "Command to end the match");
	RegAdminCmd("sm_setround", cmd_setround, ADMFLAG_ROOT, "Command to forcefully set the next round strat");
	RegAdminCmd("sm_sr", cmd_setround, ADMFLAG_ROOT, "Command to forcefully set the next round strat");
	RegAdminCmd("sm_endround", cmd_endround, ADMFLAG_ROOT, "Command to forcefully end the round");

	RegAdminCmd("sm_srslots", cmd_srslots, ADMFLAG_ROOT, "Command to output items in weapons slots");
	RegAdminCmd("sm_srtest", cmd_srtest, ADMFLAG_ROOT, "Command to test something");
	//** Event **//
	HookEvent("round_end", RoundEndEvent);
	HookEvent("round_start", RoundStartEvent, EventHookMode_Pre);
	HookEvent("switch_team", SwitchTeamEvent);
	HookEvent("player_death", PlayerDeathEvent);

	LoadTranslations("stratroulette.phrases");

	LoadOffsets();

	OnConfigsExecuted();
}

public OnPluginEnd() {
	UnhookEvent("round_end", RoundEndEvent);
	UnhookEvent("round_start", RoundStartEvent, EventHookMode_Pre);
	UnhookEvent("switch_team", SwitchTeamEvent);
	UnhookEvent("player_death", PlayerDeathEvent);

	ForceEndVote();
	ResetLastRound();
}

public void OnMapStart() {
	// Check if PugSetup is loaded
	if (GetFeatureStatus(FeatureType_Native, "PugSetup_IsMatchLive") == FeatureStatus_Available) {
		pugSetupLoaded = true;
		PrintToServer("PugSetup is loaded, using it for match handling");
	} else {
		pugSetupLoaded = false;
	}

	inGame = false;
	if (!pugSetupLoaded) {
		// Indefinite warmup
		ServerCommand("mp_do_warmup_period 1");
		ServerCommand("mp_warmup_start");
		ServerCommand("mp_warmup_pausetimer 1");
		ServerCommand("mp_warmup_pausetimer 1");
	}

	// Precache necessary models
	int precache = PrecacheModel("models/props_survival/dronegun/dronegun.mdl", true);
	if (precache == 0) {
		SetFailState("models/props_survival/dronegun/dronegun.mdl not precached !");
	}

	PrecacheModel("models/props_survival/dronegun/dronegun_gib1.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib2.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib3.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib4.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib5.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib6.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib7.mdl", true);
	PrecacheModel("models/props_survival/dronegun/dronegun_gib8.mdl", true);

	PrecacheModel("models/props/de_dust/hr_dust/dust_fences/dust_chainlink_fence_001_256.mdl", true);
	PrecacheModel("models/props/de_dust/hr_dust/dust_fences/dust_chainlink_fence_001_256_links.mdl", true);
	PrecacheModel("models/props/de_vertigo/scaffolding_walkway_03.mdl", true);

	PrecacheSound("sound/survival/turret_death_01.wav", true);
	PrecacheSound("sound/survival/turret_idle_01.wav", true);

	PrecacheSound("sound/survival/turret_takesdamage_01.wav", true);
	PrecacheSound("sound/survival/turret_takesdamage_02.wav", true);
	PrecacheSound("sound/survival/turret_takesdamage_03.wav", true);

	PrecacheSound("sound/survival/turret_lostplayer_01.wav", true);
	PrecacheSound("sound/survival/turret_lostplayer_02.wav", true);
	PrecacheSound("sound/survival/turret_lostplayer_03.wav", true);

	PrecacheSound("sound/survival/turret_sawplayer_01.wav", true);

	PrecacheDecalAnyDownload(TUNNEL_VISION_OVERLAY);
}

public Action:cmd_start(client, args) {
	if (!pugSetupLoaded) {
		ServerCommand("mp_warmup_end 1");
		inGame = true;
	} else {
		SendMessage(client, "%t", "MatchHandlingPugSetup");
	}
}

public Action:cmd_end(client, args) {
	if (!pugSetupLoaded) {
		if (inGame) {
			ServerCommand("mp_do_warmup_period 1");
			ServerCommand("mp_warmup_start");
			ServerCommand("mp_warmup_pausetimer 1");
			inGame = false;

			ResetLastRound();
			ForceEndVote();
		} else {
			ReplyToCommand(client, "Game is not in progress!");
		}
	} else {
		SendMessage(client, "%t", "MatchHandlingPugSetup");
	}
}

public Action:cmd_setround(client, args) {
	char roundArg[128];
	GetCmdArg(1, roundArg, sizeof(roundArg));

	KeyValues kv = new KeyValues("Strats");

	if (!kv.ImportFromFile(STRAT_FILE)) {
		PrintToServer("Strat file could not be found!");

		delete kv;
		return Plugin_Handled;
	}

	if (!kv.JumpToKey(roundArg)) {
		PrintToServer("Strat number %s could not be found!", roundArg);

		delete kv;
		return Plugin_Handled;
	}

	Format(forceRoundNumber, sizeof(forceRoundNumber), "%s", roundArg);
	forceNextRound = true;

	SendMessage(client, "%t", "ForceRoundSet", roundArg);

	return Plugin_Handled;
}

public Action:cmd_endround(client, args) {
	CS_TerminateRound(1.0, CSRoundEnd_Draw, false);

	return Plugin_Handled;
}

public Action:cmd_srslots(client, args) {
	for (new i = 0; i < 100; i++) {
		new edict = GetPlayerWeaponSlot(client, i);

		if (edict > -1) {
			char className[128];
			GetEdictClassname(edict, className, sizeof(className));

			PrintToServer("Slot=%d, name=%s", i, className);
		}
	}
}

int lastSmokeEntity = -1;

public Action:SmokeRemoveTimer(Handle timer) {
	if (lastSmokeEntity != -1) {
		AcceptEntityInput(lastSmokeEntity, "DestroyImmediately");
	}
}

public Action:cmd_srtest(client, args) {
}

public Action:OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (CrabWalkOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse) == Plugin_Handled) {
		return Plugin_Handled;
	}

	if (OneDirectionOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse) == Plugin_Handled) {
		return Plugin_Handled;
	}

	StealthOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);

	DownUnderOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);

	JumpshotOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);

	TimeTravelOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);

	CrouchOnlyOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);

	GTAOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);

	EnderpearlOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);

	AllOrNothingOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);

	ScreenCheatOnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);

	return Plugin_Continue;
}

public Action:OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
	if (CaptchaOnClientSayCommand(client, command, sArgs) == Plugin_Stop) {
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public OnConfigsExecuted() {
	//** CVARS **//
	sv_allow_thirdperson = FindConVar("sv_allow_thirdperson");
	sv_infinite_ammo = FindConVar("sv_infinite_ammo");
	sv_gravity = FindConVar("sv_gravity");
	weapon_accuracy_nospread = FindConVar("weapon_accuracy_nospread");
	weapon_recoil_cooldown = FindConVar("weapon_recoil_cooldown");
	weapon_recoil_decay1_exp = FindConVar("weapon_recoil_decay1_exp");
	weapon_recoil_decay2_exp = FindConVar("weapon_recoil_decay2_exp");
	weapon_recoil_decay2_lin = FindConVar("weapon_recoil_decay2_lin");
	weapon_recoil_scale = FindConVar("weapon_recoil_scale");
	weapon_recoil_suppression_shots = FindConVar("weapon_recoil_suppression_shots");
	weapon_recoil_view_punch_extra = FindConVar("weapon_recoil_view_punch_extra");
	sv_accelerate = FindConVar("sv_accelerate");
	sv_airaccelerate = FindConVar("sv_airaccelerate");
	sv_friction = FindConVar("sv_friction");
	mp_radar_showall = FindConVar("mp_radar_showall");
	sv_cheats = FindConVar("sv_cheats");
	mp_default_team_winner_no_objective = FindConVar("mp_default_team_winner_no_objective");
	mp_ignore_round_win_conditions = FindConVar("mp_ignore_round_win_conditions");
	mp_freezetime = FindConVar("mp_freezetime");
	mp_plant_c4_anywhere = FindConVar("mp_plant_c4_anywhere");
	mp_c4timer = FindConVar("mp_c4timer");
	mp_c4_cannot_be_defused = FindConVar("mp_c4_cannot_be_defused");
	mp_anyone_can_pickup_c4 = FindConVar("mp_anyone_can_pickup_c4");
	mp_give_player_c4 = FindConVar("mp_give_player_c4");
	mp_death_drop_c4 = FindConVar("mp_death_drop_c4");
	mp_death_drop_gun = FindConVar("mp_death_drop_gun");
	mp_death_drop_defuser = FindConVar("mp_death_drop_defuser");
	mp_death_drop_grenade = FindConVar("mp_death_drop_grenade");
	mp_solid_teammates = FindConVar("mp_solid_teammates");
	mp_respawn_on_death_ct = FindConVar("mp_respawn_on_death_ct");
	mp_respawn_on_death_t = FindConVar("mp_respawn_on_death_t");
	host_timescale = FindConVar("host_timescale");
	sv_autobunnyhopping = FindConVar("sv_autobunnyhopping");
	sv_enablebunnyhopping = FindConVar("sv_enablebunnyhopping");
	sv_maxvelocity = FindConVar("sv_maxvelocity");
	mp_friendlyfire = FindConVar("mp_friendlyfire");

	g_offsCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	g_offsBombTicking = FindSendPropInfo("CPlantedC4", "m_bBombTicking");

	//** KEYVALUES **//
	new flags = GetConVarFlags(sv_gravity);
	SetConVarFlags(sv_gravity, flags & ~FCVAR_NOTIFY);
	flags = GetConVarFlags(sv_accelerate);
	SetConVarFlags(sv_accelerate, flags & ~FCVAR_NOTIFY);
	flags = GetConVarFlags(sv_airaccelerate);
	SetConVarFlags(sv_airaccelerate, flags & ~FCVAR_NOTIFY);
	flags = GetConVarFlags(sv_friction);
	SetConVarFlags(sv_friction, flags & ~FCVAR_NOTIFY);
	flags = GetConVarFlags(sv_cheats);
	SetConVarFlags(sv_cheats, flags & ~FCVAR_NOTIFY);
	flags = GetConVarFlags(mp_c4timer);
	SetConVarFlags(mp_c4timer, flags & ~FCVAR_NOTIFY);
	flags = GetConVarFlags(host_timescale);
	SetConVarFlags(host_timescale, flags & ~FCVAR_CHEAT);
	flags = GetConVarFlags(mp_freezetime);
	SetConVarFlags(mp_freezetime, flags & ~FCVAR_NOTIFY);
	flags = GetConVarFlags(mp_freezetime);
	SetConVarFlags(mp_friendlyfire, flags & ~FCVAR_NOTIFY);

	SetServerConvars();
}

public SetServerConvars() {
	// Settings for server
	new Handle:bot_quota = FindConVar("bot_quota");
	new Handle:bot_quota_mode = FindConVar("bot_quota_mode");
	new Handle:mp_buytime = FindConVar("mp_buytime");
	new Handle:mp_maxmoney = FindConVar("mp_maxmoney");
	new Handle:mp_ct_default_secondary = FindConVar("mp_ct_default_secondary");
	new Handle:mp_t_default_secondary = FindConVar("mp_t_default_secondary");
	new Handle:mp_autokick = FindConVar("mp_autokick");
	SetConVarInt(bot_quota, 3);
	SetConVarString(bot_quota_mode, "normal");
	SetConVarInt(mp_buytime, 0);
	SetConVarInt(mp_maxmoney, 0);
	SetConVarString(mp_ct_default_secondary, "");
	SetConVarString(mp_t_default_secondary, "");
	SetConVarInt(mp_autokick, 0);
	SetConVarInt(mp_default_team_winner_no_objective, -1);
	SetConVarInt(mp_ignore_round_win_conditions, 0);
	SetConVarInt(mp_respawn_on_death_ct, 0);
	SetConVarInt(mp_respawn_on_death_t, 0);
	/* SetConVarInt(game_mode, 0);
	SetConVarInt(game_type, 0); */
	if (!pugSetupLoaded) {
		SetConVarInt(mp_freezetime, 5, true, false);
	}
}

public LoadOffsets() {
	Handle hGameConf = LoadGameConfigFile("strat-roulette.games");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "Reload");
	if ((hReload = EndPrepSDKCall()) == null) {
		LogError("Unable to load Reload offset");

		return;
	}
}

public void PugSetup_OnLive() {
	SetServerConvars();
}

public OnEntityCreated(entity, const String:className[]) {
	InfiniteNadesOnEntitySpawn(entity, className);
	RandomNadesOnEntitySpawn(entity, className);
	TinyMagsOnEntitySpawn(entity, className);
	EnderpearlOnEntitySpawn(entity, className);
}

public ResetLastRound() {
	if (resetFunctionsLength > 0) {
		for (int i = 0; i < resetFunctionsLength; i++) {
			Call_StartFunction(INVALID_HANDLE, resetFunctions[i]);
			Call_Finish();
		}
	}

	resetFunctionsLength = 0;
}
