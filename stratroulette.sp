#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>
#include "include/adt_trie.inc"
#include "include/colors.inc"
#include "include/keyvalues.inc"

#define STRAT_FILE "addons/sourcemod/configs/stratroulette/rounds.txt"
#define TUNNEL_VISION_OVERLAY "overlays/stratroulette/tunnel_vision_overlay"
#define PRIMARY_LENGTH 24
#define SECONDARY_LENGTH 10
#define SMOKE_RADIUS 165
#define	CLIENTWIDTH	35.0
#define	CLIENTHEIGHT 90.0

// Convar handles
ConVar g_AutoStart;
ConVar g_AutoStartMinPlayers;

// KeyValue strings
new String:RoundName[200];
new String:Collision[20];
new String:ThirdPerson[3];
new String:Weapon[70];
new String:Health[70];
new String:DecoySound[70];
new String:NoKnife[3];
new String:InfiniteAmmo[3];
new String:InfiniteNade[50];
new String:PlayerSpeed[20];
new String:PlayerGravity[20];
new String:NoRecoil[3];
new String:NoScope[3];
new String:Vampire[3];
new String:PColor[15];
new String:Backwards[3];
new String:Fov[10];
new String:ChickenDefuse[3];
new String:HeadShot[3];
new String:SlowMotion[3];
new String:RecoilView[7];
new String:AlwaysMove[3];
new String:DropWeapons[3];
new String:TinyMags[3];
new String:Leader[3];
new String:AllOnMap[3];
new String:Invisible[3];
new String:Defuser[3];
new String:Armor[20];
new String:Helmet[3];
new String:NoC4[3];
new String:Zombies[3];
new String:Axe[3];
new String:Fists[3];
new String:HitSwap[3];
new String:BuddySystem[3];
new String:RandomNade[3];
new String:RedGreen[3];
new String:Manhunt[3];
new String:Winner[20];
new String:HotPotato[3];
new String:KillRound[3];
new String:Bomberman[3];
new String:DontMiss[3];
new String:CrabWalk[3];
new String:RandomGuns[3];
new String:Poison[3];
new String:Bodyguard[3];
new String:ZeusRound[3];
new String:PocketTP[3];
new String:OneInTheChamber[3];
new String:Captcha[3];
new String:MonkeySee[3];
new String:Stealth[3];
new String:FlashDmg[3];
new String:KillList[3];
new String:Breach[3];
new String:Drones[3];
new String:Bumpmine[3];
new String:Panic[3];
new String:Dropshot[3];
new String:Hardcore[3];
new String:TunnelVision[3];

// State variables
new bool:g_DecoySound = false;
new bool:g_InfiniteNade = false;
new bool:g_NoScope = false;
new bool:g_Vampire = false;
new bool:g_ChickenDefuse = false;
new bool:g_HeadShot = false;
new bool:g_SlowMotion = false;
new bool:g_DropWeapons = false;
new bool:g_TinyMags = false;
new bool:g_Leader = false;
new bool:g_Axe = false;
new bool:g_Fists = false;
new bool:g_BuddySystem = false;
new bool:g_RandomNade = false;
new bool:g_Zombies = false;
new bool:g_HitSwap = false;
new bool:g_RedGreen = false;
new bool:g_Manhunt = false;
new bool:g_HotPotato = false;
new bool:g_KillRound = false;
new bool:g_Bomberman = false;
new bool:g_DontMiss = false;
new bool:g_CrabWalk = false;
new bool:g_RandomGuns = false;
new bool:g_Poison = false;
new bool:g_Bodyguard = false;
new bool:g_ZeusRound = false;
new bool:g_PocketTP = false;
new bool:g_OneInTheChamber = false;
new bool:g_Captcha = false;
new bool:g_MonkeySee = false;
new bool:g_Stealth = false;
new bool:g_FlashDmg = false;
new bool:g_KillList = false;
new bool:g_Breach = false;
new bool:g_Drones = false;
new bool:g_Bumpmine = false;
new bool:g_Panic = false;
new bool:g_Dropshot = false;

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

// Grenades
new const GrenadesAll[] =  { 15, 17, 16, 14, 18, 17 };

new bool:inGame = false;
new bool:pugSetupLoaded = false;

new g_Health;
// Leader/Manhunt/Hot potato
new String:ctLeaderName[128];
new ctLeader;
new String:tLeaderName[128];
new tLeader;
// Speed change
new bool:g_HighSpeed = false;
// Red light, green light
new bool:g_RedLight = false;
new StringMap:positionMap;
// Buddy system
new StringMap:chickenMap;
new StringMap:chickenHealth;
// Poison
new StringMap:smokeMap;
// Weapons
char primaryWeapon[256];
char secondaryWeapon[256];
// Captcha
char captchaAnswer[64];
ArrayList captchaClients;
// Monkey see
int monkeyOneTeam = -1;
// Stealth
new stealthVisible[MAXPLAYERS + 1];
// Drones
new StringMap:droneMap;
// Kill method
new bool:skipNextKill = false;

// Round variables
int lastRound = -1;

new Handle:voteTimer = INVALID_HANDLE;

new bool:nextRoundVoted = false;
new String:voteRoundNumber[16];
new bool:forceNextRound = false;
new String:forceRoundNumber[16];

int g_offsCollisionGroup;

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
new Handle:mp_anyone_can_pickup_c4;
new Handle:mp_death_drop_grenade;
new Handle:mp_solid_teammates;
new Handle:host_timescale;

#include "stratroulette/configure.sp"
#include "stratroulette/readfile.sp"
#include "stratroulette/events.sp"
#include "stratroulette/hooks.sp"
#include "stratroulette/timers.sp"
#include "stratroulette/util.sp"
#include "stratroulette/pugsetup-integration.sp"

#pragma semicolon 1

public Plugin:myinfo =  {
	name = "Strat Roulette",
	author = "Extremelyd1",
	description = "Random strats every round",
	version = "1.0"
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
	HookEvent("decoy_started", SrEventDecoyStarted);
	HookEvent("weapon_zoom", SrEventWeaponZoom, EventHookMode_Post);
	HookEvent("bomb_planted", SrBombPlanted_Event);
	HookEvent("inspect_weapon", SrEventInspectWeapon);
	HookEvent("round_end", SrEventRoundEnd);
	HookEvent("round_start", SrEventRoundStart);
	HookEvent("player_death", SrEventPlayerDeath);
    HookEvent("player_death", SrEventPlayerDeathPre, EventHookMode_Pre);
    HookEvent("other_death", SrEventEntityDeath);
    HookEvent("weapon_fire", SrEventWeaponFire);
    HookEvent("smokegrenade_detonate", SrEventSmokeDetonate);
    HookEvent("smokegrenade_expired", SrEventSmokeExpired);
    HookEvent("player_blind", SrEventPlayerBlind);
    HookEvent("switch_team", SrEventSwitchTeam);

    AddCommandListener(CommandDrop, "drop");

    // Hook players after plugin reload
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && !IsFakeClient(client)) {
            SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
        }
    }

    if (voteTimer != INVALID_HANDLE) {
        CloseHandle(voteTimer);
        voteTimer = INVALID_HANDLE;
    }
}

public OnPluginEnd() {
    UnhookEvent("decoy_started", SrEventDecoyStarted);
	UnhookEvent("weapon_zoom", SrEventWeaponZoom, EventHookMode_Post);
	UnhookEvent("bomb_planted", SrBombPlanted_Event);
	UnhookEvent("inspect_weapon", SrEventInspectWeapon);
	UnhookEvent("round_end", SrEventRoundEnd);
	UnhookEvent("round_start", SrEventRoundStart);
	UnhookEvent("player_death", SrEventPlayerDeath);
    UnhookEvent("player_death", SrEventPlayerDeathPre, EventHookMode_Pre);
    UnhookEvent("other_death", SrEventEntityDeath);
    UnhookEvent("weapon_fire", SrEventWeaponFire);
    UnhookEvent("smokegrenade_detonate", SrEventSmokeDetonate);
    UnhookEvent("smokegrenade_expired", SrEventSmokeExpired);
    UnhookEvent("player_blind", SrEventPlayerBlind);

    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && !IsFakeClient(client)) {
            SDKUnhook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
        }
    }
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

public OnClientPutInServer(client) {
    SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

public Action:cmd_start(client, args) {
    if (!pugSetupLoaded) {
        ServerCommand("mp_warmup_end 1");
        inGame = true;
    } else {
        SendMessage(client, "Match handling is done by {LIGHT_GREEN}PugSetup{NORMAL}, please use that");
    }
}

public Action:cmd_end(client, args) {
    if (!pugSetupLoaded) {
        if (inGame) {
            ServerCommand("mp_do_warmup_period 1");
            ServerCommand("mp_warmup_start");
            ServerCommand("mp_warmup_pausetimer 1");
            inGame = false;

            ResetConfiguration();
        } else {
            ReplyToCommand(client, "Game is not in progress!");
        }
    } else {
        SendMessage(client, "Match handling is done by {LIGHT_GREEN}PugSetup{NORMAL}, please use that");
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

    ReplyToCommand(client, "Next round set to strat %s", roundArg);

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

public Action:cmd_srtest(client, args) {
}

public Action:CommandDrop(int client, const char[] command, int args) {
    if (g_HotPotato || g_Bomberman || g_Bodyguard || g_RandomGuns) {
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

public Action:OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
    if (g_CrabWalk) {
        if (buttons & IN_FORWARD) {
            return Plugin_Handled;
        }
        if (buttons & IN_BACK) {
            return Plugin_Handled;
        }
    }

    if (g_Stealth) {
        int walkMask = IN_FORWARD | IN_BACK | IN_LEFT | IN_RIGHT;
        int otherMask = IN_ATTACK | IN_RELOAD;
        if (buttons & otherMask || (buttons & walkMask && !(buttons & IN_SPEED))) {
            stealthVisible[client] = true;
        } else {
            stealthVisible[client] = false;
        }
    }

    return Plugin_Continue;
}

public Action:OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
    if (g_Captcha) {
        if (captchaClients.FindValue(client) != -1) {
            if (StrEqual(sArgs, captchaAnswer)) {
                GivePlayerItem(client, primaryWeapon);
                GivePlayerItem(client, secondaryWeapon);
                captchaClients.Erase(captchaClients.FindValue(client));
            } else {
                SendMessage(client, "{DARK_RED}Wrong{NORMAL} answer!");
            }
            return Plugin_Stop;
        }
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
    mp_death_drop_grenade = FindConVar("mp_death_drop_grenade");
    mp_solid_teammates = FindConVar("mp_solid_teammates");
    host_timescale = FindConVar("host_timescale");

    g_offsCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");

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

	SetServerConvars();

    chickenMap = CreateTrie();
    chickenHealth = CreateTrie();
    positionMap = CreateTrie();
    smokeMap = CreateTrie();
    droneMap = CreateTrie();
    captchaClients = new ArrayList();
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
	SetConVarInt(bot_quota, 0);
	SetConVarString(bot_quota_mode, "none");
	SetConVarInt(mp_buytime, 0);
	SetConVarInt(mp_maxmoney, 0);
	SetConVarString(mp_ct_default_secondary, "");
	SetConVarString(mp_t_default_secondary, "");
    SetConVarInt(mp_autokick, 0);
    if (!pugSetupLoaded) {
        SetConVarInt(mp_freezetime, 5, true, false);
    }
}

public void PugSetup_OnLive() {
    SetServerConvars();
}

public OnEntityCreated(iEntity, const String:classname[]) {
	if (g_InfiniteNade || g_RandomNade) {
		if (StrContains(classname, "_projectile") != -1) {
			SDKHook(iEntity, SDKHook_SpawnPost, OnEntitySpawned);
		}
	}
}

public CreateRoundVoteMenu() {
    Menu menu = new Menu(VoteMenuHandler, MENU_ACTIONS_ALL);
    menu.SetTitle("Vote for a new round:");

    ArrayList options = new ArrayList();
    int numberOfStrats = GetNumberOfStrats();
    for (int i = 1; i <= numberOfStrats; i++) {
        if (i != lastRound) {
            options.Push(i);
        }
    }

    for (int i = 1; i < 6; i++) {
        if (options.Length == 0) {
            break;
        }

        int randomRound = options.Get(GetRandomInt(0, options.Length - 1));

        options.Erase(options.FindValue(randomRound));

        char randomRoundString[16];
        IntToString(randomRound, randomRoundString, sizeof(randomRoundString));

        KeyValues kv = new KeyValues("Strats");
        kv.ImportFromFile(STRAT_FILE);

        if (!kv.JumpToKey(randomRoundString)) {
            PrintToServer("Strat number %s could not be found for voting!", randomRoundString);

            delete kv;
            continue;
        }

        kv.GetString("name", RoundName, sizeof(RoundName), "No name round!");
        Colorize(RoundName, sizeof(RoundName), true);

        menu.AddItem(randomRoundString, RoundName);

        delete kv;
    }

    menu.ExitButton = false;

    menu.DisplayVoteToAll(20);
}

public int VoteMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_VoteEnd) {
        char winningRound[32];
        char winningRoundName[256];
        int style;
        menu.GetItem(param1, winningRound, sizeof(winningRound), style, winningRoundName, sizeof(winningRoundName));

        Format(voteRoundNumber, sizeof(voteRoundNumber), winningRound);
        nextRoundVoted = true;

        char message[256];
        Format(message, sizeof(message), "Round voting {LIGHT_GREEN}finished{NORMAL}, next round is {DARK_BLUE}%s", winningRoundName);

        for (int i = 1; i <= MaxClients; i++) {
            if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
                SendMessage(i, message);
            }
        }
    }

    if (action == MenuAction_End) {
		delete menu;
	}
}

public bool:RayFilter(entity, mask, any:data) {
    if (entity == data) {
        return false;
    }
    return true;
}
