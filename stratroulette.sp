#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>
#include "include/adt_trie.inc"
#include "include/colors.inc"
#include "include/keyvalues.inc"
#include "include/pugsetup.inc"

#define STRAT_FILE "addons/sourcemod/configs/stratroulette/rounds.txt"
#define PRIMARY_LENGTH 24
#define SECONDARY_LENGTH 10
#define SMOKE_RADIUS 165

// KeyValue strings
new String:RoundName[200];
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
new String:OneInTheChamber[3];
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
new String:Teleport[3];
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

// State variables
new bool:g_DecoySound = false;
new bool:g_InfiniteNade = false;
new bool:g_NoScope = false;
new bool:g_Vampire = false;
new bool:g_ChickenDefuse = false;
new bool:g_HeadShot = false;
new bool:g_SlowMotion = false;
new bool:g_DropWeapons = false;
new bool:g_OneInTheChamber = false;
new bool:g_Leader = false;
new bool:g_Axe = false;
new bool:g_Fists = false;
new bool:g_BuddySystem = false;
new bool:g_RandomNade = false;
new bool:g_Zombies = false;
new bool:g_Teleport = false;
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

// Round setting command
new bool:setNextRound = false;
new String:forceRoundNumber[16];

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

#include "stratroulette/configure.sp"
#include "stratroulette/readfile.sp"
#include "stratroulette/util.sp"
#include "stratroulette/timers.sp"

#pragma semicolon 1

public Plugin:myinfo =  {
	name = "Strat Roulette",
	author = "Extremelyd1",
	description = "Random strats every round",
	version = "1.0"
}

public OnPluginStart() {
    //** Commands **//
    RegAdminCmd("sm_setround", cmd_setround, ADMFLAG_ROOT, "Command to forcefully set the next round strat");
    RegAdminCmd("sm_sr", cmd_setround, ADMFLAG_ROOT, "Command to forcefully set the next round strat");
    RegAdminCmd("sm_endround", cmd_endround, ADMFLAG_ROOT, "Command to forcefully end the round");
    RegAdminCmd("sm_srslots", cmd_srslots, ADMFLAG_ROOT, "Command to output items in weapons slots");
    RegAdminCmd("sm_srtest", cmd_srtest, ADMFLAG_ROOT, "Command to test something");
	//** Event **//
	HookEvent("decoy_started", SrEventDecoyStarted);
	HookEvent("weapon_zoom", SrEventWeaponZoom, EventHookMode_Post);
	HookEvent("bomb_planted", SrBombPlanted_Event);
	HookEvent("player_hurt", SrEventPlayerHurt, EventHookMode_Pre);
	HookEvent("inspect_weapon", SrEventInspectWeapon);
	HookEvent("round_end", SrEventRoundEnd);
	HookEvent("round_start", SrEventRoundStart);
	HookEvent("player_death", SrEventPlayerDeath);
    HookEvent("player_death", SrEventPlayerDeathPre, EventHookMode_Pre);
    HookEvent("other_death", SrEventEntityDeath);
    HookEvent("weapon_fire", SrEventWeaponFire);
    HookEvent("smokegrenade_detonate", SrEventSmokeDetonate);
    HookEvent("smokegrenade_expired", SrEventSmokeExpired);

    AddCommandListener(CommandDrop, "drop");

    // Hook players after plugin reload
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && !IsFakeClient(client)) {
            SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
        }
    }
}

public void OnMapStart() {
    // Nothing here yet
}

public OnClientPutInServer(client) {
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
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

    setNextRound = true;
    Format(forceRoundNumber, sizeof(forceRoundNumber), "%s", roundArg);

    ReplyToCommand(client, "Next round set to strat %s", roundArg);

    return Plugin_Handled;
}

public Action:cmd_endround(client, args) {
    CS_TerminateRound(1.0, CSRoundEnd_Draw, true);

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
    new c4 = GivePlayerItem(client, "weapon_c4");
    EquipPlayerWeapon(client, c4);
}

public Action:CommandDrop(int client, const char[] command, int args) {
    if (g_HotPotato || g_Bomberman || g_Bodyguard) {
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

	SetServerConvars();

    chickenMap = CreateTrie();
    chickenHealth = CreateTrie();
    positionMap = CreateTrie();
    smokeMap = CreateTrie();
}

public SetServerConvars() {
    // Settings for server
	new Handle:bot_quota = FindConVar("bot_quota");
	new Handle:bot_quota_mode = FindConVar("bot_quota_mode");
	new Handle:mp_buytime = FindConVar("mp_buytime");
	new Handle:mp_maxmoney = FindConVar("mp_maxmoney");
	new Handle:mp_ct_default_secondary = FindConVar("mp_ct_default_secondary");
	new Handle:mp_t_default_secondary = FindConVar("mp_t_default_secondary");
	SetConVarInt(bot_quota, 0);
	SetConVarString(bot_quota_mode, "none");
	SetConVarInt(mp_buytime, 0);
	SetConVarInt(mp_maxmoney, 0);
	SetConVarString(mp_ct_default_secondary, "");
	SetConVarString(mp_t_default_secondary, "");
}

public void PugSetup_OnLive() {
    SetServerConvars();
}

public Action:SrEventRoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
}

public Action:SrEventRoundStart(Handle:event, const String:name[], bool:dontBroadcast) {
    if (PugSetup_IsMatchLive()) {
       ReadNewRound();
   }
}

public Action:SrEventDecoyStarted(Handle:event, const String:name[], bool:dontBroadcast) {
	if (g_DecoySound) {
		new entity = GetEventInt(event, "entityid");
		if (IsValidEntity(entity)) {
			RemoveEdict(entity);
		}
	}
}

public OnEntityCreated(iEntity, const String:classname[]) {
	if (g_InfiniteNade || g_RandomNade) {
		if (StrContains(classname, "_projectile") != -1) {
			SDKHook(iEntity, SDKHook_SpawnPost, OnEntitySpawned);
		}
	}
}

/*  Edict class names:
    smokegrenade_projectile
    flashbang_projectile
    decoy_projectile
    hegrenade_projectile
    molotov_projectile
    incgrenade_projectile
*/
public OnEntitySpawned(iGrenade) {
	new client = GetEntPropEnt(iGrenade, Prop_Send, "m_hOwnerEntity");
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
		new nadeslot = GetPlayerWeaponSlot(client, 3);
		if (nadeslot > -1) {
			RemovePlayerItem(client, nadeslot);
		}
        RemoveEdict(nadeslot);
        char className[128];
        int randomInt = -1;
        if (g_RandomNade) {
            randomInt = GetRandomInt(1, 6);
        } else {
            GetEdictClassname(iGrenade, className, sizeof(className));
        }

        if (StrEqual(className, "smokegrenade_projectile") || randomInt == 1) {
            GivePlayerItem(client, "weapon_smokegrenade");
        } else if (StrEqual(className, "flashbang_projectile") || randomInt == 2) {
            GivePlayerItem(client, "weapon_flashbang");
        } else if (StrEqual(className, "decoy_projectile") || randomInt == 3) {
            GivePlayerItem(client, "weapon_decoy");
        } else if (StrEqual(className, "hegrenade_projectile") || randomInt == 4) {
            GivePlayerItem(client, "weapon_hegrenade");
        } else if (StrEqual(className, "molotov_projectile") || randomInt == 5) {
            GivePlayerItem(client, "weapon_molotov");
        } else if (StrEqual(className, "incgrenade_projectile") || randomInt == 6) {
            GivePlayerItem(client, "weapon_incgrenade");
        }
	}
}

public Action:SrEventWeaponZoom(Handle:event, const String:name[], bool:dontBroadcast) {
	if (g_NoScope) {
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			new ent = GetPlayerWeaponSlot(client, 0);
			CS_DropWeapon(client, ent, true, true);
			PrintToChat(client, "This is noscope round! Don't try to scope!");
		}
	}
}

public Action:Hook_DenyTransmit(entity, client) {
    if (entity != client) {
        if (IsClientInGame(entity)) {
            if (!IsPlayerAlive(client)) {
                if (GetClientTeam(entity) != GetClientTeam(client)) {
                        return Plugin_Handled;
                }
            } else {
                return Plugin_Handled;
            }
        }
    }
    return Plugin_Continue;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
    if (g_Bomberman) {
        new victimHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
        if (victimHealth <= damage) {
            // Victim would have been killed by bomb damage

            // Check whether team is wiped
            bool ctWiped = true;
            bool tWiped = true;

            for (int client = 1; client <= MaxClients; client++) {
                if (IsClientInGame(client) && IsPlayerAlive(client)
                    && !IsFakeClient(client) && client != victim) {
                    if (GetClientTeam(client) == CS_TEAM_CT) {
                        ctWiped = false;
                    } else if (GetClientTeam(client) == CS_TEAM_T) {
                        tWiped = false;
                    }
                }
            }

            if (!ctWiped && !tWiped) {
                KillPlayer(victim, victim);
                return Plugin_Handled;
            }

            DataPack data = new DataPack();

            if (ctWiped) {
                data.WriteCell(CS_TEAM_CT);
            } else if (tWiped) {
                data.WriteCell(CS_TEAM_T);
            }

            // Wait 0.1 seconds before killing player manually,
            // to allow round end by bomb to be bypassed
            CreateTimer(0.1, WipeTeamTimer, data);

            return Plugin_Handled;
        }
    }

    if (g_Bodyguard) {
        if (victim != ctLeader && victim != tLeader) {
            return Plugin_Handled;
        }
    }

    if (g_BuddySystem) {
        new String:victimIdString[64];
        IntToString(victim, victimIdString, sizeof(victimIdString));
        float currentChickenHealth;
        if (chickenHealth.GetValue(victimIdString, currentChickenHealth)) {
            if (damage < currentChickenHealth) {
                chickenHealth.SetValue(victimIdString, currentChickenHealth - damage);
                return Plugin_Handled;
            }
            chickenHealth.Remove(victimIdString);
            return Plugin_Continue;
        }
    }

    if (g_BuddySystem || g_HotPotato) {
        if (g_HotPotato) {
            if (attacker != victim && victim != 0 && attacker != 0 &&
                GetClientTeam(victim) != GetClientTeam(attacker)) {
                SelectHotPotato(victim);
            }
        }

        return Plugin_Handled;
    }

    if (g_Vampire) {
		if (attacker == 0) {
			return Plugin_Continue;
		}

		new attackerHealth = GetEntProp(attacker, Prop_Send, "m_iHealth");
		if (IsClientInGame(attacker) && IsPlayerAlive(attacker) && !IsFakeClient(attacker)) {
			new giveHealth = RoundToNearest(attackerHealth + damage);
    		SetEntityHealth(attacker, giveHealth);
		}
	}

    return Plugin_Continue;
}

public Action:SrEventWeaponFire(Handle:event, const String:name[], bool:dontBroadcast) {
    if (g_DontMiss) {
        new client = GetClientOfUserId(GetEventInt(event, "userid"));
        char weaponname[128];
        Client_GetActiveWeaponName(client, weaponname, sizeof(weaponname));

        for (int i = 0; i < PRIMARY_LENGTH; i++) {
            if (StrEqual(weaponname, WeaponPrimary[i])) {
                DataPack data = new DataPack();
                data.WriteCell(client);
                data.WriteCell(PrimaryDamage[i]);

                CreateTimer(0.1, DontMissDamageTimer, data);
                return Plugin_Continue;
            }
        }
        for (int i = 0; i < SECONDARY_LENGTH; i++) {
            if (StrEqual(weaponname, WeaponSecondary[i])) {
                DataPack data = new DataPack();
                data.WriteCell(client);
                data.WriteCell(SecondaryDamage[i]);

                CreateTimer(0.1, DontMissDamageTimer, data);
                return Plugin_Continue;
            }
        }
    }

    return Plugin_Continue;
}

public Action:SrEventPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast) {
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (g_HeadShot) {
		new hitgroup = GetEventInt(event, "hitgroup");
		new damageDone = GetEventInt(event, "dmg_health");
		new newHealth = GetEventInt(event, "health");

		if (hitgroup != 1) {
			if (attacker != victim && victim != 0 && attacker != 0) {
				if (damageDone > 0) {
					new giveHealth = newHealth + damageDone;
					SetEntityHealth(victim, giveHealth);
				}
			}
		}
	}

    if (g_DontMiss) {
        char weapon[128];
        GetEventString(event, "weapon", weapon, sizeof(weapon));
        Format(weapon, sizeof(weapon), "weapon_%s", weapon);

        for (int i = 0; i < PRIMARY_LENGTH; i++) {
            if (StrEqual(weapon, WeaponPrimary[i])) {
                DamagePlayer(attacker, -PrimaryDamage[i]);
                return Plugin_Continue;
            }
        }
        for (int i = 0; i < SECONDARY_LENGTH; i++) {
            if (StrEqual(weapon, WeaponSecondary[i])) {
                DamagePlayer(attacker, -SecondaryDamage[i]);
                return Plugin_Continue;
            }
        }
    }

    if (g_Teleport) {
        if (attacker != victim && victim != 0 && attacker != 0) {
            float victimPos[3];
            GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);
            float attackerPos[3];
            GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", attackerPos);

            TeleportEntity(victim, attackerPos, NULL_VECTOR, NULL_VECTOR);
            TeleportEntity(attacker, victimPos, NULL_VECTOR, NULL_VECTOR);
        }
    }

    return Plugin_Continue;
}

public Action:SrBombPlanted_Event(Handle:event, const String:name[], bool:dontBroadcast) {
	if (g_ChickenDefuse) {
		new c4 = -1;
		c4 = FindEntityByClassname(c4, "planted_c4");
		if (c4 != -1) {
			new chicken = CreateEntityByName("chicken");
			if (chicken != -1) {
				new player = GetClientOfUserId(GetEventInt(event, "userid"));
				decl Float:pos[3];
				GetEntPropVector(player, Prop_Data, "m_vecOrigin", pos);
				pos[2] += -15.0;
				DispatchSpawn(chicken);
				SetEntProp(chicken, Prop_Data, "m_takedamage", 0);
				SetEntProp(chicken, Prop_Send, "m_fEffects", 0);
				TeleportEntity(chicken, pos, NULL_VECTOR, NULL_VECTOR);
				TeleportEntity(c4, NULL_VECTOR, Float: { 0.0, 0.0, 0.0 }, NULL_VECTOR);
				SetVariantString("!activator");
				AcceptEntityInput(c4, "SetParent", chicken, c4, 0);
			}
		}
	}
}

public Action:SrEventInspectWeapon(Handle:event, const String:name[], bool:dontBroadcast) {
	// Nothing implement here yet
}

public Action:SrEventPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
    new killerUserid = GetEventInt(event, "attacker");
    new assisterUserid = GetEventInt(event, "assister");
    char weapon[128];
    GetEventString(event, "weapon", weapon, sizeof(weapon));

	if (IsClientInGame(client)) {

        if (g_Leader) {
            // Follow the leader
            if (client == ctLeader) {
                SetLeader(CS_TEAM_CT);
            } else if (client == tLeader) {
                SetLeader(CS_TEAM_T);
            }
        }

        if (g_Manhunt || g_Bodyguard) {
            // Manhunt
            new killTeam;
            if (client == ctLeader) {
                killTeam = CS_TEAM_CT;
            } else if (client == tLeader) {
                killTeam = CS_TEAM_T;
            }
            if (killTeam == CS_TEAM_CT || CS_TEAM_T) {
                for (int i = 1; i <= MaxClients; i++) {
                    if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)
                                          && GetClientTeam(i) == killTeam) {
                        KillPlayer(i, killerUserid, weapon, assisterUserid);
                    }
                }
            }
        }

        if (g_ZeusRound) {
            int killer = GetClientOfUserId(killerUserid);
            if (IsClientInGame(killer) && !IsFakeClient(killer) && IsPlayerAlive(killer)) {
                CreateTimer(1.2, AwardZeusTimer, killer);
            }
        }

        if (!IsFakeClient(client)) {
            // Third person
        	SendConVarValue(client, sv_allow_thirdperson, "0");

        	// Fov
        	SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
        	SetEntProp(client, Prop_Send, "m_iFOV", 90);
        }
	}
}

public Action:SrEventPlayerDeathPre(Handle:event, const String:name[], bool:dontBroadcast) {
    if (g_KillRound && !g_Bomberman) {
        bool ctWiped = true;
        bool tWiped = true;

        for (int client = 1; client <= MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                if (GetClientTeam(client) == CS_TEAM_CT) {
                    ctWiped = false;
                } else if (GetClientTeam(client) == CS_TEAM_T) {
                    tWiped = false;
                }
            }
        }

        if (ctWiped || tWiped) {
            SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);

            return Plugin_Continue;
        }
    }

    if (g_BuddySystem || g_Bomberman) {
        new userid = GetEventInt(event, "userid");
        new attackerUserid = GetEventInt(event, "attacker");

        if (attackerUserid == 13371337) {
            SetEventInt(event, "attacker", userid);
            return Plugin_Continue;
        }

        if (userid == attackerUserid) {
            return Plugin_Stop;
        }
    }

    return Plugin_Continue;
}

public Action:SrEventEntityDeath(Handle:event, const String:name[], bool:dontBroadcast) {
    if (g_BuddySystem) {
        new entity = GetEventInt(event, "otherid");
        new attackerUserid = GetEventInt(event, "attacker");
        char weapon[128];
        GetEventString(event, "weapon", weapon, sizeof(weapon));
        for (new i = 1; i <= MaxClients; i++) {
            if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
                // Convert player id to string
                new String:playerIdString[64];
                IntToString(i, playerIdString, sizeof(playerIdString));
                // Get chicken that belongs to player
                new chicken;
                chickenMap.GetValue(playerIdString, chicken);

                if (chicken == entity) {
                    KillPlayer(i, attackerUserid, weapon);
                    chickenMap.Remove(playerIdString);
                }
            }
        }
    }
}

public Action:SrEventSmokeDetonate(Handle:event, const String:name[], bool:dontBroadcast) {
    if (g_Poison) {
        new entity = GetEventInt(event, "entityid");
        float pos[3];
        pos[0] = GetEventFloat(event, "x");
        pos[1] = GetEventFloat(event, "y");
        pos[2] = GetEventFloat(event, "z");

        new String:entityIdString[64];
        IntToString(entity, entityIdString, sizeof(entityIdString));

        smokeMap.SetArray(entityIdString, pos, 3);
    }
}

public Action:SrEventSmokeExpired(Handle:event, const String:name[], bool:dontBroadcast) {
    if (g_Poison) {
        new entity = GetEventInt(event, "entityid");

        new String:entityIdString[64];
        IntToString(entity, entityIdString, sizeof(entityIdString));

        smokeMap.Remove(entityIdString);
    }
}
