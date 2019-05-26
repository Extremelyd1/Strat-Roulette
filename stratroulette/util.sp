static char _colorNames[][] = {"{NORMAL}", "{DARK_RED}",    "{PINK}",      "{GREEN}",
                               "{YELLOW}", "{LIGHT_GREEN}", "{LIGHT_RED}", "{GRAY}",
                               "{ORANGE}", "{LIGHT_BLUE}",  "{DARK_BLUE}", "{PURPLE}"};
static char _colorCodes[][] = {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06",
                               "\x07", "\x08", "\x09", "\x0B", "\x0C", "\x0E"};

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
                Colorize(message, sizeof(message));
                CPrintToChat(client, message);
                Format(message, sizeof(message), "{LIGHT_GREEN}Follow {NORMAL}the leader or you {DARK_RED}die");
                Colorize(message, sizeof(message));
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

public SendManhuntMessage(team) {
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
                Colorize(message1, sizeof(message1));
                Colorize(message2, sizeof(message2));
                CPrintToChat(client, message1);
                CPrintToChat(client, message2);
            }
        }
    }
}

public GivePlayerItemByString(client, char[] item) {
    // For random weapon generate first whether it
    // should be primary of secondary
    new randomIntCat = -1;
    if (StrEqual(item, "weapon_random")) {
        randomIntCat = GetRandomInt(0, 1);
    }

    if (StrEqual(item, "weapon_primary_random") || randomIntCat == 0) {
        new randomInt = GetRandomInt(0, PRIMARY_LENGTH - 1);
        GivePlayerItem(client, WeaponPrimary[randomInt]);
    } else if (StrEqual(item, "weapon_secondary_random") || randomIntCat == 1) {
        new randomInt = GetRandomInt(0, SECONDARY_LENGTH - 1);
        GivePlayerItem(client, WeaponSecondary[randomInt]);
    } else {
        GivePlayerItem(client, item);
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
            ReplaceString(msg, size, _colorNames[colorNameIndex], "\x01");  // replace with white
        } else {
            ReplaceString(msg, size, _colorNames[colorNameIndex], _colorCodes[colorNameIndex]);
        }
    }
}
