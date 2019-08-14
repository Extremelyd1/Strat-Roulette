static char _colorNames[][] = {"{NORMAL}", "{DARK_RED}",    "{PINK}",      "{GREEN}",
                               "{YELLOW}", "{LIGHT_GREEN}", "{LIGHT_RED}", "{GRAY}",
                               "{ORANGE}", "{LIGHT_BLUE}",  "{DARK_BLUE}", "{PURPLE}"};
static char _colorCodes[][] = {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06",
                               "\x07", "\x08", "\x09", "\x0B", "\x0C", "\x0E"};

// Used before each round to reset all remaining modifiers from
// previous round
public ResetConfiguration() {
	// Third person
	SetConVarInt(sv_allow_thirdperson, 0, true, false);
	// Weapons
	primaryWeapon = "";
	secondaryWeapon = "";
	RemoveWeapons();
	RemoveNades();
	// Knife
	SetKnife(true);
	// Infinite ammo
	SetConVarInt(sv_infinite_ammo, 0, true, false);
	// Gravity
	SetConVarInt(sv_gravity, 800, true, false);
	// Recoil related
	SetConVarInt(weapon_accuracy_nospread, 0, true, false);
	SetConVarFloat(weapon_recoil_cooldown, 0.55, true, false);
	SetConVarFloat(weapon_recoil_decay1_exp, 3.5, true, false);
	SetConVarInt(weapon_recoil_decay2_exp, 8, true, false);
	SetConVarInt(weapon_recoil_decay2_lin, 18, true, false);
	SetConVarInt(weapon_recoil_scale, 2, true, false);
	SetConVarInt(weapon_recoil_suppression_shots, 4, true, false);
	SetConVarFloat(weapon_recoil_view_punch_extra, 0.0555, true, false);
	// Acceleration
	SetConVarFloat(sv_accelerate, 5.5, true, false);
	SetConVarInt(sv_airaccelerate, 12, true, false);
	// Leader
	ctLeader = -1;
	tLeader = -1;
	// Friction
	SetConVarFloat(sv_friction, 5.2, true, false);
	// All on map
	SetConVarInt(mp_radar_showall, 0, true, false);
	// Buddy System
	ClearBuddySystemChickens();
	// Red Green
	positionMap.Clear();
	// Winner
	SetConVarInt(mp_default_team_winner_no_objective, -1, true, false);
	// Kill round
	SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);
	// Bomberman
	SetConVarInt(mp_plant_c4_anywhere, 0, true, false);
	SetConVarInt(mp_c4timer, 40, true, false);
	SetConVarInt(mp_c4_cannot_be_defused, 0, true, false);
	SetConVarInt(mp_anyone_can_pickup_c4, 0, true, false);
	// Drop grenade
	SetConVarInt(mp_death_drop_grenade, 1, true, false);
	// Drop defuser
	SetConVarInt(mp_death_drop_defuser, 1, true, false);
	// Drop gun
	SetConVarInt(mp_death_drop_grenade, 1, true, false);
	// Poison
	smokeMap.Clear();
	// Solid teammates
	SetConVarInt(mp_solid_teammates, 1, true, false);
	// Monkey see
	monkeyOneTeam = -1;
	// Tunnel vision
	RemoveOverlayAll();
	// Down Under
	ClearDownUnder();
	// Reincarnation
	SetConVarInt(mp_respawn_on_death_ct, 0, true, false);
	SetConVarInt(mp_respawn_on_death_t, 0, true, false);

	// Client loop
	for (int client = 1; client <= MaxClients; client++) {
	    if (IsClientInGame(client) && !IsFakeClient(client)) {
	        if (IsPlayerAlive(client)) {
	            // Third person
	            ClientCommand(client, "firstperson");
	            // Defuser
	            SetEntProp(client, Prop_Send, "m_bHasDefuser", 0);
	            // Armor
	            Client_SetArmor(client, 0);
	            // Helmet
	            SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), 0);
	            // Collision
	            SetEntData(client, g_offsCollisionGroup, 5, 4, true);
	            // Color
	            SetEntityRenderColor(client, 255, 255, 255, 0);
	        }
	        // Hardcore
	        Client_SetHideHud(client, 2050);
	    }
	}

	// Setting all state variables to false
	g_DecoySound = false;
	g_InfiniteNade = false;
	g_NoScope = false;
	g_Vampire = false;
	g_ChickenDefuse = false;
	g_HeadShot = false;
	g_SlowMotion = false;
	g_DropWeapons = false;
	g_TinyMags = false;
	g_Leader = false;
	g_Axe = false;
	g_Fists = false;
	g_BuddySystem = false;
	g_RandomNade = false;
	g_Zombies = false;
	g_HitSwap = false;
	g_RedGreen = false;
	g_Manhunt = false;
	g_HotPotato = false;
	g_KillRound = false;
	g_Bomberman = false;
	g_DontMiss = false;
	g_CrabWalk = false;
	g_RandomGuns = false;
	g_Poison = false;
	g_Bodyguard = false;
	g_ZeusRound = false;
	g_PocketTP = false;
	g_OneInTheChamber = false;
	g_Captcha = false;
	g_MonkeySee = false;
	g_Stealth = false;
	g_FlashDmg = false;
	g_KillList = false;
	g_Breach = false;
	g_Drones = false;
	g_Bumpmine = false;
	g_Panic = false;
	g_Dropshot = false;
	g_Reincarnation = false;
}

public int GetNumberOfStrats() {
    KeyValues kv = new KeyValues("Strats");

    if (!kv.ImportFromFile(STRAT_FILE)) {
        PrintToServer("Strat file could not be found!");

        delete kv;
        return -1;
    }

    if (!kv.GotoFirstSubKey(false)) {
        PrintToServer("No strats in strat file!");

        delete kv;
        return -1;
    }

    int numberOfStrats = 0;

    do {
        if (kv.GetDataType(NULL_STRING) == KvData_None) {
            numberOfStrats++;
        }
    } while (kv.GotoNextKey(false));

    delete kv;

    return numberOfStrats;
}

public CreateNewDropWeaponsTimer(client) {
    float randomFloat = GetRandomFloat(3.0, 6.0);
    DataPack data = new DataPack();
    data.WriteCell(client);
    CreateTimer(randomFloat, DropWeaponsTimer, data);
}

public SendLeaderMessage(team) {
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (GetClientTeam(client) == team) {
				if (team == CS_TEAM_CT) {
					SendMessage(client, "%t", "NewLeader", ctLeaderName);
				} else {
					SendMessage(client, "%t", "NewLeader", tLeaderName);
                }
            }
        }
    }
    SendMessageTeam(team, "%t", "FollowLeader");
}

public SendMessage(client, String:szMessage[], any:...) {
	if (client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %d", client);
	}

	if (!IsClientInGame(client)) {
		ThrowError("Client %d is not in game", client);
	}

	decl String:szCMessage[MAX_MESSAGE_LENGTH];

	SetGlobalTransTarget(client);

	VFormat(szCMessage, sizeof(szCMessage), szMessage, 3);

	Colorize(szCMessage, MAX_MESSAGE_LENGTH);

	Format(szCMessage, sizeof(szCMessage), " \x01\x0B\x01%s", szCMessage);

	PrintToChat(client, "%s", szCMessage);
}

public SendMessageAll(String:szMessage[], any:...) {
	decl String:szBuffer[MAX_MESSAGE_LENGTH];

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i)) {
			SetGlobalTransTarget(i);
			VFormat(szBuffer, sizeof(szBuffer), szMessage, 2);

			Colorize(szBuffer, MAX_MESSAGE_LENGTH);

			Format(szBuffer, sizeof(szBuffer), " \x01\x0B\x01%s", szBuffer);

			PrintToChat(i, "%s", szBuffer);
		}
	}
}

public SendMessageAlive(String:szMessage[], any:...) {
	decl String:szBuffer[MAX_MESSAGE_LENGTH];

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i)) {
			SetGlobalTransTarget(i);
			VFormat(szBuffer, sizeof(szBuffer), szMessage, 2);

			Colorize(szBuffer, MAX_MESSAGE_LENGTH);

			Format(szBuffer, sizeof(szBuffer), " \x01\x0B\x01%s", szBuffer);

			PrintToChat(i, "%s", szBuffer);
		}
	}
}

public SendMessageTeam(int team, String:szMessage[], any:...) {
	decl String:szBuffer[MAX_MESSAGE_LENGTH];

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i)) {
			if (team == GetClientTeam(i)) {
				SetGlobalTransTarget(i);
				VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);

				Colorize(szBuffer, MAX_MESSAGE_LENGTH);

				Format(szBuffer, sizeof(szBuffer), " \x01\x0B\x01%s", szBuffer);

				PrintToChat(i, "%s", szBuffer);
			}
		}
	}
}

public CreateNewRedGreenTimer() {
    float randomFloat;
    if (g_RedLight) {
        randomFloat = GetRandomFloat(2.0, 4.0);
    } else {
        randomFloat = GetRandomFloat(4.0, 12.0);
    }

    CreateTimer(randomFloat, RedGreenMessageTimer);
}

public SetLeader(team) {
    if (team == CS_TEAM_CT) {
        ctLeader = -1;
    } else {
        tLeader = -1;
    }
    ArrayList players = new ArrayList();

    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (GetClientTeam(client) == team) {
                players.Push(client);
            }
        }
    }

    if (players.Length > 0) {
        int randomPlayer = GetRandomInt(0, players.Length - 1);
        if (team == CS_TEAM_CT) {
            ctLeader = players.Get(randomPlayer);
            GetClientName(ctLeader, ctLeaderName, sizeof(ctLeaderName));
        } else {
            tLeader = players.Get(randomPlayer);
            GetClientName(tLeader, tLeaderName, sizeof(tLeaderName));
        }
    }
}

public SendVIPMessage(team) {
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (GetClientTeam(client) == team) {
                if (team == CS_TEAM_CT) {
					SendMessage(client, "%t", "VIPTarget", tLeaderName);
					SendMessage(client, "%t", "VIPProtect", ctLeaderName);
                } else {
					SendMessage(client, "%t", "VIPTarget", ctLeaderName);
					SendMessage(client, "%t", "VIPProtect", tLeaderName);
                }
            }
        }
    }
}

public SendKillListMessage(team) {
    if (team == CS_TEAM_CT) {
		SendMessageTeam(team, "%t", "NewTarget", tLeaderName);
    } else if (team == CS_TEAM_T) {
		SendMessageTeam(team, "%t", "NewTarget", ctLeaderName);
    }
}

public RemoveWeapons() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            RemoveWeaponsClient(client);
		}
	}
}

public RemoveWeaponsClient(int client) {
    // Primary = 0
    // Secondary = 1
    // Knife = 2
    // C4 = 4
    // Shield = 11

    new primary = GetPlayerWeaponSlot(client, 0);
    new secondary = GetPlayerWeaponSlot(client, 1);
    new c4Slot = GetPlayerWeaponSlot(client, 4);
    new shield = GetPlayerWeaponSlot(client, 11);

    if (primary > -1) {
        RemovePlayerItem(client, primary);
        RemoveEdict(primary);
    }

    if (secondary > -1) {
        RemovePlayerItem(client, secondary);
        RemoveEdict(secondary);
    }

    char classname[128];
    if (c4Slot != -1) {
        GetEdictClassname(c4Slot, classname, sizeof(classname));

        if (!StrEqual(classname, "weapon_c4") || StrEqual(NoC4, "1")) {
            RemovePlayerItem(client, c4Slot);
            RemoveEdict(c4Slot);
        }
    }

    if (shield > -1) {
        RemovePlayerItem(client, shield);
        RemoveEdict(shield);
    }
}

public RemoveNades() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			for (int j = 0; j < 6; j++) {
				SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, GrenadesAll[j]);
			}
		}
	}
}

public SetKnife(bool add) {
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            new knife = GetPlayerWeaponSlot(client, 2);
            if (add) {
                if (knife == -1) {
                    new newKnife = GivePlayerItem(client, "weapon_knife");
                    EquipPlayerWeapon(client, newKnife);
                }
            } else {
                if (knife != -1) {
                    RemovePlayerItem(client, knife);
                    RemoveEdict(knife);
                }
            }
        }
    }
}

public GiveAllPlayersItem(char[] item) {
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (!g_Zombies || GetClientTeam(client) == CS_TEAM_CT) {
                GivePlayerItem(client, item);
            }
        }
    }
}

public bool IsWiped() {
	bool ctWiped = true;
	bool tWiped = true;

	if (GetConVarInt(mp_respawn_on_death_ct) == 1) {
		ctWiped = false;
	}
	if (GetConVarInt(mp_respawn_on_death_t) == 1) {
		tWiped = false;
	}

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			if (GetClientTeam(client) == CS_TEAM_CT) {
				ctWiped = false;
			} else if (GetClientTeam(client) == CS_TEAM_T) {
				tWiped = false;
			}
		}
	}

	return ctWiped || tWiped;
}

stock void SelectHotPotato(int client = -1) {
	RemoveWeapons();
	ArrayList players = new ArrayList();

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
			players.Push(i);
		}
	}

	if (client == -1) {
		int randomInt = GetRandomInt(0, players.Length - 1);
		// Used to store hot potato holder,
		// has nothing to do with CT
		ctLeader = players.Get(randomInt);
	} else {
		ctLeader = client;
	}

	GetClientName(ctLeader, ctLeaderName, sizeof(ctLeaderName));

	SendMessage(ctLeader, "%t", "ReceivedPotato");

	for (int i = 0; i < players.Length; i++) {
		int otherClient = players.Get(i);
		if (otherClient != ctLeader) {
			SendMessage(otherClient, "%t", "PlayerHasPotato", ctLeaderName);
		}
	}

	GiveHotPotato(ctLeader);
}

public GiveHotPotato(client) {
	GivePlayerItem(client, "weapon_fiveseven");

	int potato = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);

	SetClipAmmo(potato, magazineSize);
	SetReserveAmmo(potato, magazineSize);

	SDKHook(potato, SDKHook_Reload, Hook_OnWeaponReload);
	SDKHook(potato, SDKHook_ReloadPost, Hook_OnWeaponReloadPost);
}

public ClearBuddySystemChickens() {
    if (chickenHealth.Size != 0) {
        StringMapSnapshot snapshot = chickenHealth.Snapshot();
        for (int i = 0; i < snapshot.Length; i++) {
            char key[64];
            snapshot.GetKey(i, key, sizeof(key));

            int chickenRef = EntIndexToEntRef(StringToInt(key));
            AcceptEntityInput(chickenRef, "kill");
        }

        delete snapshot;
        chickenMap.Clear();
        chickenHealth.Clear();
    }
}

public ClearDownUnder() {
    downUnderMap.Clear();
    g_DownUnder = false;

    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            // Reset player angle
            float angles[3];
            GetClientEyeAngles(i, angles);

            angles[2] = 0.0;

            TeleportEntity(i, NULL_VECTOR, angles, NULL_VECTOR);

            // Reset view
            SetClientViewEntity(i, i);
        }
    }
}

stock void HealPlayer(int client, int amount) {
	new currentHealth = GetEntProp(client, Prop_Send, "m_iHealth");
	new newHealth = currentHealth + amount;

	if (newHealth > g_Health) {
		newHealth = g_Health;
	}

	SetEntityHealth(client, newHealth);
}

public SetClipAmmo(weapon, ammo) {
	SetEntProp(weapon, Prop_Send, "m_iClip1", ammo);
}

public SetActiveWeaponClipAmmo(client, ammo) {
    new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if(weapon < 1) {
        return;
    }

    SetClipAmmo(weapon, ammo);
}

public int GetClipAmmo(weapon) {
	return GetEntProp(weapon, Prop_Send, "m_iClip1");
}

public int GetActiveWeaponClipAmmo(client) {
    new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if(weapon < 1) {
        return -1;
    }

    return GetClipAmmo(weapon);
}

public SetReserveAmmo(weapon, ammo) {
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
}

public SetActiveWeaponReserveAmmo(client, ammo) {
    new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if(weapon < 1) {
        return;
    }

    SetReserveAmmo(weapon, ammo);
}

stock void Colorize(String:msg[], int size, bool stripColor = false) {
	for (int colorNameIndex = 0; colorNameIndex < sizeof(_colorNames); colorNameIndex++) {
		if (stripColor) {
			ReplaceString(msg, size, _colorNames[colorNameIndex], "");  // replace with white
		} else {
			ReplaceString(msg, size, _colorNames[colorNameIndex], _colorCodes[colorNameIndex]);
		}
    }
}

// Precache & prepare download for overlays & decals
stock void PrecacheDecalAnyDownload(char[] sOverlay) {
    char sBuffer[256];
    Format(sBuffer, sizeof(sBuffer), "%s.vmt", sOverlay);
    PrecacheDecal(sBuffer, true);
    Format(sBuffer, sizeof(sBuffer), "materials/%s.vmt", sOverlay);
    AddFileToDownloadsTable(sBuffer);

    Format(sBuffer, sizeof(sBuffer), "%s.vtf", sOverlay);
    PrecacheDecal(sBuffer, true);
    Format(sBuffer, sizeof(sBuffer), "materials/%s.vtf", sOverlay);
    AddFileToDownloadsTable(sBuffer);
}

// Show overlay to a client with lifetime | 0.0 = no auto remove
stock void ShowOverlay(int client, char[] path, float lifetime) {
    if (!IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client)) {
        return;
    }

    ClientCommand(client, "r_screenoverlay \"%s.vtf\"", path);

    if (lifetime != 0.0) {
        CreateTimer(lifetime, DeleteOverlay, GetClientUserId(client));
    }
}

// Show overlay to all clients with lifetime | 0.0 = no auto remove
stock void ShowOverlayAll(char[] path, float lifetime) {
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || IsFakeClient(i) || IsClientSourceTV(i) || IsClientReplay(i)) {
            continue;
        }

        ClientCommand(i, "r_screenoverlay \"%s.vtf\"", path);

        if (lifetime != 0.0) {
            CreateTimer(lifetime, DeleteOverlay, GetClientUserId(i));
        }
    }
}

stock void RemoveOverlayAll() {
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || IsFakeClient(i) || IsClientSourceTV(i) || IsClientReplay(i)) {
            continue;
        }

        ClientCommand(i, "r_screenoverlay \"\"");
    }
}

// Remove overlay from a client - Timer!
stock Action DeleteOverlay(Handle timer, any userid) {

    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client)) {
        return;
    }

    ClientCommand(client, "r_screenoverlay \"\"");
}

int CreateViewEntity(int client, float pos[3]) {

	int entity = CreateEntityByName("env_sprite");
	if (entity != -1) {
		DispatchKeyValue(entity, "model", SPRITE);
		DispatchKeyValue(entity, "renderamt", "0");
		DispatchKeyValue(entity, "rendercolor", "0 0 0");
		DispatchSpawn(entity);

		float angle[3];
		GetClientEyeAngles(client, angle);

		TeleportEntity(entity, pos, angle, NULL_VECTOR);
		TeleportEntity(client, NULL_VECTOR, angle, NULL_VECTOR);

		SetClientViewEntity(client, entity);
		return entity;
	}

	return -1;
}
