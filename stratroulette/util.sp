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
    // Friction
    SetConVarFloat(sv_friction, 5.2, true, false);
    // All on map
    SetConVarInt(mp_radar_showall, 0, true, false);
    // Buddy System
    ClearBuddySystemChickens();
    // Red Green
    positionMap.Clear();
    // Winner
    SetConVarInt(mp_default_team_winner_no_objective, 3, true, false);
    // Kill round
    SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);
    // Bomberman
    SetConVarInt(mp_plant_c4_anywhere, 0, true, false);
    SetConVarInt(mp_c4timer, 40, true, false);
    SetConVarInt(mp_c4_cannot_be_defused, 0, true, false);
    SetConVarInt(mp_anyone_can_pickup_c4, 0, true, false);
    // Drop grenade
    SetConVarInt(mp_death_drop_grenade, 1, true, false);
    // Poison
    smokeMap.Clear();
    // Solid teammates
    SetConVarInt(mp_solid_teammates, 1, true, false);
    // Monkey see
    monkeyOneTeam = -1;
    // Client loop
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            // Third person
            ClientCommand(client, "firstperson");
            // Defuser
            SetEntProp(client, Prop_Send, "m_bHasDefuser", 0);
            // Armor
            Client_SetArmor(client, 0);
            // Helmet
            SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), 0);
            // Color
            SetEntityRenderColor(client, 255, 255, 255, 0);
            // Collision
            SetEntData(client, g_offsCollisionGroup, 5, 4, true);
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
                new String:message[256];
                if (team == CS_TEAM_CT) {
                    Format(message, sizeof(message), "{LIGHT_GREEN}New {NORMAL}leader is {YELLOW}%s", ctLeaderName);
                } else {
                    Format(message, sizeof(message), "{LIGHT_GREEN}New {NORMAL}leader is {YELLOW}%s", tLeaderName);
                }
                SendMessage(client, message);
            }
        }
    }
    SendMessageAlive("{LIGHT_GREEN}Follow {NORMAL}the leader or you {DARK_RED}die");
}

public SendMessage(client, char[] message) {
    Colorize(message, 512);
    CPrintToChat(client, message);
}

public SendMessageAll(char[] message) {
    Colorize(message, 512);
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && !IsFakeClient(client)) {
            CPrintToChat(client, message);
        }
    }
}

public SendMessageAlive(char[] message) {
    Colorize(message, 256);
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            CPrintToChat(client, message);
        }
    }
}

public SendMessageTeam(char[] message, int team) {
    Colorize(message, 256);
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (team == GetClientTeam(client)) {
                CPrintToChat(client, message);
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
                new String:message1[256];
                new String:message2[256];
                if (team == CS_TEAM_CT) {
                    Format(message1, sizeof(message1), "Your {DARK_RED}target{NORMAL} is {YELLOW}%s", tLeaderName);
                    Format(message2, sizeof(message2), "{GREEN}Defend{NORMAL} your VIP {YELLOW}%s", ctLeaderName);
                } else {
                    Format(message1, sizeof(message1), "Your {DARK_RED}target{NORMAL} is {YELLOW}%s", ctLeaderName);
                    Format(message2, sizeof(message2), "{GREEN}Defend{NORMAL} your VIP {YELLOW}%s", tLeaderName);
                }
                SendMessage(client, message1);
                SendMessage(client, message2);
            }
        }
    }
}

public SendKillListMessage(team) {
    new String:message[256];

    if (team == CS_TEAM_CT) {
        Format(message, sizeof(message), "Your new {DARK_RED}target{NORMAL} is {YELLOW}%s", tLeaderName);
    } else if (team == CS_TEAM_T) {
        Format(message, sizeof(message), "Your new {DARK_RED}target{NORMAL} is {YELLOW}%s", ctLeaderName);
    }

    SendMessageTeam(message, team);
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
    new c4 = GetPlayerWeaponSlot(client, 4);
    new shield = GetPlayerWeaponSlot(client, 11);

    if (primary > -1) {
        RemovePlayerItem(client, primary);
        RemoveEdict(primary);
    }

    if (secondary > -1) {
        RemovePlayerItem(client, secondary);
        RemoveEdict(secondary);
    }

    if (StrEqual(NoC4, "1") && c4 > -1) {
        RemovePlayerItem(client, c4);
        RemoveEdict(c4);
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

    SendMessage(ctLeader, "You have the {DARK_RED}hot potato{NORMAL}, hit someone to give it to them!")

    char message[256];
    Format(message, sizeof(message), "{YELLOW}%s has the {DARK_RED}hot potato{NORMAL}, don't get hit!", ctLeaderName);
    Colorize(message, sizeof(message));
    for (int i = 0; i < players.Length; i++) {
        int otherClient = players.Get(i);
        if (otherClient != ctLeader) {
            CPrintToChat(otherClient, message);
        }
    }

    GivePlayerItem(ctLeader, "weapon_fiveseven");
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

// Used to damage player by amount of damage, can also be used to heal
// with negative damage
stock void DamagePlayer(int client, int damage, int attackerUserid=-1, char[] weapon="knife") {
    new currentHealth = GetEntProp(client, Prop_Send, "m_iHealth");
    new newHealth = currentHealth - damage;
    if (damage > 0) {
        if (newHealth > 0) {
            SetEntityHealth(client, newHealth);
        } else {
            KillPlayer(client, attackerUserid, weapon);
        }
    } else if (damage < 0) {
        if (newHealth <= g_Health) {
            SetEntityHealth(client, newHealth);
        }
    }
}

stock void KillPlayer(int client, int killerUserid=-1, char[] weapon="knife", int assisterUserid=-1) {
    if (killerUserid != -1) {
        new Handle:event = CreateEvent("player_death");
        if (event != INVALID_HANDLE) {
            // Set victim to userid, not client index
            int userid = GetClientUserId(client);
            SetEventInt(event, "userid", userid);
            SetEventInt(event, "assister", assisterUserid);

            if (userid == killerUserid) {
                // Special value to indicate suicide
                SetEventInt(event, "attacker", 13371337);
            } else {
                // Set attacker
                SetEventInt(event, "attacker", killerUserid);
            }

            // TODO: Make it so that it shows the correct weapon
            // new weapon = GetEntPropEnt(killer, Prop_Data, "m_hActiveWeapon");

            SetEventString(event, "weapon", weapon); // weapon name
            FireEvent(event, false);
        }
    }
    skipNextKill = true;
    ForcePlayerSuicide(client);
}

public SetClipAmmo(client, ammo) {
    new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if(weapon < 1) {
        return;
    }

    SetEntProp(weapon, Prop_Send, "m_iClip1", 1);
}

public int GetClipAmmo(client) {
    new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if(weapon < 1) {
        return -1;
    }

    return GetEntProp(weapon, Prop_Send, "m_iClip1");
}

public SetReserveAmmo(client, ammo) {
    new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if(weapon < 1) {
        return;
    }

    if (bool:GetEntProp(weapon, Prop_Data, "m_bInReload", true)) {
        return;
    }

    new ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if(ammotype == -1) {
        return;
    }

    SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammotype);
}

stock void Colorize(char[] msg, int size, bool stripColor = false) {
    for (int colorNameIndex = 0; colorNameIndex < sizeof(_colorNames); colorNameIndex++) {
        if (stripColor) {
            ReplaceString(msg, size, _colorNames[colorNameIndex], "");  // replace with white
        } else {
            ReplaceString(msg, size, _colorNames[colorNameIndex], _colorCodes[colorNameIndex]);
        }
    }
}
