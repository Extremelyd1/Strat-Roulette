public Action:EnableThirdPerson(Handle:timer) {
	for (new i = 1; i < MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
			ClientCommand(i, "thirdperson");
		}
	}
}

public Action:SlowMotionTimer(Handle timer) {
    if (!g_SlowMotion) {
        return Plugin_Stop;
    }
    int randomInt = GetRandomInt(0, 2);

    if (randomInt == 0) {
        for (new i = 1; i < MaxClients; i++) {
            if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
                g_HighSpeed = !g_HighSpeed;
                if (g_HighSpeed) {
                    SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
                    SetConVarInt(sv_gravity, 800);
                } else {
                    SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.3);
                    SetConVarInt(sv_gravity, 400);
                }
            }
        }
    }

    return Plugin_Continue;
}

public Action:DropWeaponsTimer(Handle timer, DataPack data) {
    if (!g_DropWeapons) {
        return Plugin_Stop;
    }

    if (data == INVALID_HANDLE) {
        return Plugin_Stop;
    }

    data.Reset();
    new client = data.ReadCell();

    if (client == -1) {
        return Plugin_Stop;
    }

    new currentWeapon = GetPlayerWeaponSlot(client, 1);

    if (currentWeapon != -1) {
        CS_DropWeapon(client, currentWeapon, true, true);
    }

    CreateNewDropWeaponsTimer(client);

    return Plugin_Stop;
}

public Action:SetWeaponAmmo(Handle timer) {
    if (!g_OneInTheChamber) {
        return Plugin_Stop;
    }

    for (new i = 1; i < MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            if (GetClipAmmo(i) > 1) {
                SetClipAmmo(i, 1);
            }

            SetReserveAmmo(i, 1);
        }
    }

    return Plugin_Continue;
}

// Simply here to delay starting the timer
// so players can walk to their leader at
// start of the round
public Action:StartLeaderTimer(Handle timer) {
    CreateTimer(3.0, CheckLeaderTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:CheckLeaderTimer(Handle timer) {
    if (!g_Leader) {
        return Plugin_Stop;
    }

    ArrayList ctPlayers = new ArrayList();
    ArrayList tPlayers = new ArrayList();

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            if (GetClientTeam(i) == CS_TEAM_CT) {
                ctPlayers.Push(i);
            } else if (GetClientTeam(i) == CS_TEAM_T) {
                tPlayers.Push(i);
            }
        }
    }

    if (ctPlayers.Length > 0 && ctLeader != -1) {
        float vec[3];
        GetClientEyePosition(ctLeader, vec);

        for (int i = 0; i < ctPlayers.Length; i++) {
            int client = ctPlayers.Get(i);

            float pos[3];
            GetClientEyePosition(client, pos);

            float distance = GetVectorDistance(vec, pos);

            if (distance > 300) {
                DamagePlayer(client, 5);
                new String:message[256];
                Format(message, sizeof(message), "{DARK_RED}Warning {NORMAL}too far from the {YELLOW}leader");
                Colorize(message, sizeof(message));
                CPrintToChat(client, message);
            }
        }
    }

    if (tPlayers.Length > 0 && tLeader != -1) {
        float vec[3];
        GetClientEyePosition(tLeader, vec);

        for (int i = 0; i < tPlayers.Length; i++) {
            int client = tPlayers.Get(i);

            float pos[3];
            GetClientEyePosition(client, pos);

            float distance = GetVectorDistance(vec, pos);

            if (distance > 300) {
                DamagePlayer(client, 5);
                new String:message[256];
                Format(message, sizeof(message), "{DARK_RED}Warning {NORMAL}too far from the {YELLOW}leader");
                Colorize(message, sizeof(message));
                CPrintToChat(client, message);
            }
        }
    }

    return Plugin_Continue;
}

public Action:CheckAxeFistsTimer(Handle timer) {
    if (!g_Axe && !g_Fists) {
        return Plugin_Stop;
    }

    for (new i = 1; i < MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            new meleeSlot = GetPlayerWeaponSlot(i, 2);

            if (meleeSlot < 0) {
                if (g_Axe) {
                    new axe = GivePlayerItem(i, "weapon_axe");
                    EquipPlayerWeapon(i, axe);
                } else if (g_Fists) {
                    new fists = GivePlayerItem(i, "weapon_fists");
                    EquipPlayerWeapon(i, fists);
                }
            }
        }
    }

    return Plugin_Continue;
}

public Action:BuddyTimer(Handle timer) {
    if (!g_BuddySystem) {
        return Plugin_Stop;
    }
    for (new i = 1; i < MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            // Convert player id to string
            new String:playerIdString[64];
            IntToString(i, playerIdString, sizeof(playerIdString));
            // Get chicken that belongs to player
            new chicken;
            if (chickenMap.GetValue(playerIdString, chicken)) {
                if (chicken != 0) {
                    // Set the leader property again
                    SetEntPropEnt(chicken, Prop_Send, "m_leader", i);
                }
            }
        }
    }
    return Plugin_Continue;
}

public Action:RedGreenMessageTimer(Handle timer) {
    if (!g_RedGreen) {
        return Plugin_Stop;
    }
    new String:message[256];
    if (!g_RedLight) {
        Format(message, sizeof(message), "{DARK_RED}Red light{NORMAL}: Don't move!");
        // Only enforce no move after certain time
        CreateTimer(1.0, RedLightTimer);
    } else {
        Format(message, sizeof(message), "{GREEN}Green light{NORMAL}: You can move!");
        // Immediately enforce move period
        g_RedLight = false;
        CreateNewRedGreenTimer();
    }
    Colorize(message, sizeof(message));
    for (new i = 1; i < MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i)) {
            CPrintToChat(i, message);
        }
    }

    return Plugin_Continue;
}

public Action:RedLightTimer(Handle timer) {
    g_RedLight = true;

    // Save player positions
    for (new i = 1; i < MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            // Store client id in string
            new String:playerIdString[64];
            IntToString(i, playerIdString, sizeof(playerIdString));

            float playerPos[3];
            GetClientEyePosition(i, playerPos);
            positionMap.SetArray(playerIdString, playerPos, 3);
        }
    }

    CreateNewRedGreenTimer();

    return Plugin_Continue;
}

public Action:RedGreenDamageTimer(Handle timer) {
    if (!g_RedGreen) {
        return Plugin_Stop;
    }
    new String:message[256];
    Format(message, sizeof(message), "Don't {DARK_RED}move{NORMAL} during {DARK_RED}red{NORMAL} light");
    Colorize(message, sizeof(message));

    for (new i = 1; i < MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            // Store client id in string
            new String:playerIdString[64];
            IntToString(i, playerIdString, sizeof(playerIdString));

            float playerPos[3];
            GetClientEyePosition(i, playerPos);

            float oldPlayerPos[3];
            if (positionMap.GetArray(playerIdString, oldPlayerPos, sizeof(oldPlayerPos))) {

                float distance = GetVectorDistance(oldPlayerPos, playerPos);

                if (g_RedLight && distance > 10) {
                    new currentHealth = GetEntProp(i, Prop_Send, "m_iHealth");
                    if (currentHealth > 5) {
                        SetEntityHealth(i, currentHealth - 5);
                    } else {
                        ForcePlayerSuicide(i);
                    }
                    CPrintToChat(i, message);
                }
            }

            positionMap.SetArray(playerIdString, playerPos, 3);
        }
    }

    return Plugin_Continue;
}

public Action:NewHotPotatoTimer(Handle timer) {
    if (!g_HotPotato) {
        return Plugin_Stop;
    }

    SelectHotPotato();
    CreateTimer(5.0, HotPotatoMessage1Timer);
    CreateTimer(10.0, HotPotatoMessage2Timer);
    CreateTimer(15.0, HotPotatoTimer);

    return Plugin_Continue;
}

public Action:HotPotatoMessage1Timer(Handle timer) {
    if (ctLeader != -1) {
        new String:message[256];
        Format(message, sizeof(message), "That is one {DARK_RED}hot potato{NORMAL}!", ctLeaderName);
        Colorize(message, sizeof(message));
        CPrintToChat(ctLeader, message);
    }
}

public Action:HotPotatoMessage2Timer(Handle timer) {
    if (ctLeader != -1) {
        new String:message[256];
        Format(message, sizeof(message), "I can't hold this {DARK_RED}hot potato{NORMAL} much longer!", ctLeaderName);
        Colorize(message, sizeof(message));
        CPrintToChat(ctLeader, message);
    }
}

public Action:HotPotatoTimer(Handle timer) {
    if (!g_HotPotato) {
        return Plugin_Stop;
    }

    RemoveWeapons();
    if (ctLeader != -1) {
        ForcePlayerSuicide(ctLeader);

        new String:message[256];
        Format(message, sizeof(message), "{YELLOW}%s died with the {DARK_RED}hot potato{NORMAL}!", ctLeaderName);
        Colorize(message, sizeof(message));
        for (new i = 1; i < MaxClients; i++) {
            if (IsClientInGame(i) && !IsFakeClient(i)) {
                CPrintToChat(i, message);
            }
        }

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
            return Plugin_Stop;
        }
    }

    CreateTimer(3.0, NewHotPotatoTimer);

    return Plugin_Continue;
}

public Action:CheckC4Timer(Handle timer) {
    if (!g_Bomberman) {
        return Plugin_Stop;
    }

    for (new i = 1; i < MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            new c4Slot = GetPlayerWeaponSlot(i, 4);

            if (c4Slot < 0) {
                new c4 = GivePlayerItem(i, "weapon_c4");
                EquipPlayerWeapon(i, c4);
            }
        }
    }

    return Plugin_Continue;
}

public Action:WipeTeamTimer(Handle timer, DataPack data) {
    SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);

    data.Reset();

    int team = data.ReadCell();

    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && !IsFakeClient(client)) {
            if (GetClientTeam(client) == team) {
                KillPlayer(client, client);
            }
        }
    }
}

public Action:DontMissDamageTimer(Handle timer, DataPack data) {
    data.Reset();

    int client = data.ReadCell();
    int damage = data.ReadCell();

    DamagePlayer(client, damage);
}
