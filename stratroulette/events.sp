public Action SrEventMatchOver(Handle:event, const String:name[], bool:dontBroadcast) {
    ServerCommand("mp_match_restart_delay 600");
}

public Action:SrEventRoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
    if (voteTimer != INVALID_HANDLE) {
        CloseHandle(voteTimer);
        voteTimer = INVALID_HANDLE;
    }
}

public Action:SrEventRoundStart(Handle:event, const String:name[], bool:dontBroadcast) {
    if (IsPugSetupMatchLive() || inGame) {
       ReadNewRound();
       voteTimer = CreateTimer(GetConVarInt(mp_freezetime) + 15.0, VoteTimer);
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

    if (g_PocketTP) {
        new client = GetClientOfUserId(GetEventInt(event, "userid"));
        char weapon[128];
        GetEventString(event, "weapon", weapon, sizeof(weapon));

        if (!StrEqual(weapon, "weapon_usp_silencer")) {
            return Plugin_Continue;
        }

        float origin[3];
        float angles[3];

        GetClientEyePosition(client, origin);
        GetClientEyeAngles(client, angles);

        new Handle:lookTrace = TR_TraceRayFilterEx(origin, angles, MASK_PLAYERSOLID, RayType_Infinite, RayFilter, client);
        if (TR_DidHit(lookTrace)) {
            float hitLocation[3];

            TR_GetEndPosition(hitLocation, lookTrace);

            int tries = 300;
            bool success = false;

            hitLocation[2] = hitLocation[2] - 5.0;

            float mins[3];
            mins[0] = -CLIENTWIDTH / 2;
            mins[1] = -CLIENTWIDTH / 2;
            mins[2] = 0.0;

            float maxs[3];
            maxs[0] = CLIENTWIDTH / 2;
            maxs[1] = CLIENTWIDTH / 2;
            maxs[2] = CLIENTHEIGHT;

            while (!success && tries > 0) {
                hitLocation[2] = hitLocation[2] + 5.0;

                new Handle:hitboxTrace = TR_TraceHullEx(hitLocation, hitLocation, mins, maxs, MASK_PLAYERSOLID);

                if (!TR_DidHit(hitboxTrace)) {
                    TeleportEntity(client, hitLocation, NULL_VECTOR, NULL_VECTOR);
                    success = true;
                } else {
                    tries--;
                }

                CloseHandle(hitboxTrace);
            }
        }

        CloseHandle(lookTrace);
    }

    if (g_OneInTheChamber) {
        new client = GetClientOfUserId(GetEventInt(event, "userid"));

        char weaponname[128];
        Client_GetActiveWeaponName(client, weaponname, sizeof(weaponname));

        if (!StrEqual(weaponname, "weapon_knife")) {
            new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
            if (weapon > 0 && GetClipAmmo(client) > 0) {
                DataPack data = new DataPack();
                data.WriteCell(client);
                data.WriteCell(weapon);
                CreateTimer(0.1, RemoveOITCWeapon, data);
            }
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

        if (g_OneInTheChamber) {
            int killer = GetClientOfUserId(killerUserid);
            if (IsClientInGame(killer) && !IsFakeClient(killer) && IsPlayerAlive(killer)) {
                CreateTimer(0.2, AwardOITCWeapon, killer);
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

    new userid = GetEventInt(event, "userid");
    new attackerUserid = GetEventInt(event, "attacker");

    if (attackerUserid == 13371337) {
        SetEventInt(event, "attacker", userid);
        return Plugin_Continue;
    }

    if (userid == attackerUserid && skipNextKill) {
        skipNextKill = false;
        return Plugin_Stop;
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
