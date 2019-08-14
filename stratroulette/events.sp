public Action SrEventMatchOver(Handle:event, const String:name[], bool:dontBroadcast) {
    ServerCommand("mp_match_restart_delay 600");
}

public Action:SrEventRoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
	if (voteTimer != INVALID_HANDLE) {
		CloseHandle(voteTimer);
		voteTimer = INVALID_HANDLE;
	}

	roundHasEnded = true;
}

public Action:SrEventRoundStart(Handle:event, const String:name[], bool:dontBroadcast) {
	if (IsPugSetupMatchLive() || inGame) {
		ReadNewRound();
		// Don't create new timer if another already exists
		if (voteTimer == INVALID_HANDLE && !nextRoundVoted) {
			voteTimer = CreateTimer(GetConVarInt(mp_freezetime) + 15.0, VoteTimer);
		}
	}

	roundHasEnded = false;
}

public Action:SrEventDecoyStarted(Handle:event, const String:name[], bool:dontBroadcast) {
    if (g_DecoySound) {
    	new entity = GetEventInt(event, "entityid");
    	if (IsValidEntity(entity)) {
    		RemoveEdict(entity);
    	}
    }

    if (g_Drones) {
        new entity = GetEventInt(event, "entityid");
        if (IsValidEntity(entity)) {
            RemoveEntity(entity);

            new client = GetClientOfUserId(GetEventInt(event, "userid"));

            int dronegun = CreateEntityByName("dronegun");

            SetEntData(dronegun, g_offsCollisionGroup, 5, 4, true);
            SetEntPropEnt(dronegun, Prop_Send, "m_hOwnerEntity", client);

            float pos[3];
            pos[0] = GetEventFloat(event, "x");
            pos[1] = GetEventFloat(event, "y");
            pos[2] = GetEventFloat(event, "z");

            TeleportEntity(dronegun, pos, NULL_VECTOR, NULL_VECTOR);
            DispatchSpawn(dronegun);

            new String:entityIdString[64];
            IntToString(dronegun, entityIdString, sizeof(entityIdString));
            droneMap.SetValue(entityIdString, client);
        }
    }
}

public Action:SrEventWeaponZoom(Handle:event, const String:name[], bool:dontBroadcast) {
	if (g_NoScope) {
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			new ent = GetPlayerWeaponSlot(client, 0);
			CS_DropWeapon(client, ent, true, true);
			SendMessage(client, "%t", "DontScope");
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

    if (g_Dropshot) {
        new client = GetClientOfUserId(GetEventInt(event, "userid"));

        new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
        if (weapon > 0) {
            DataPack data = new DataPack();
            data.WriteCell(client);
            data.WriteCell(weapon);
            CreateTimer(0.1, DropShotWeapon, data);
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
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	char weapon[128];
	GetEventString(event, "weapon", weapon, sizeof(weapon));

	if (IsClientInGame(client)) {

		if (g_Leader && !IsWiped()) {
			if (client == ctLeader) {
				SetLeader(CS_TEAM_CT);
			} else if (client == tLeader) {
				SetLeader(CS_TEAM_T);
			}
		}

		if (g_KillList && !IsWiped()) {
			if (client == ctLeader) {
				SetLeader(CS_TEAM_CT);
				SendMessage(ctLeader, "%t", "TopKillList");
				SendKillListMessage(CS_TEAM_T);
			} else if (client == tLeader) {
				SetLeader(CS_TEAM_T);
				SendMessage(tLeader, "%t", "TopKillList");
				SendKillListMessage(CS_TEAM_CT);
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
					if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i) && GetClientTeam(i) == killTeam) {
						SDKHooks_TakeDamage(i, killer, killer, float(g_Health), DMG_GENERIC);
					}
				}
			}
		}

		if (g_ZeusRound) {
			if (IsClientInGame(killer) && !IsFakeClient(killer) && IsPlayerAlive(killer)) {
				CreateTimer(1.2, AwardZeusTimer, killer);
			}
		}

		if (g_OneInTheChamber) {
			if (IsClientInGame(killer) && !IsFakeClient(killer) && IsPlayerAlive(killer)) {
				if (!StrEqual(weapon, "weapon_knife")) {
					// Not killed with knife
					SetActiveWeaponClipAmmo(killer, GetActiveWeaponClipAmmo(client) + 1);
				} else {
					// Killed with knife, find weapon to award ammo
					int weaponInSlot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
					if (weaponInSlot <= 0) {
						// Primary does not exist, pick secondary
						weaponInSlot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
						if (weaponInSlot <= 0) {
							// No primary, nor secondary, can't award ammo
							return Plugin_Continue;
						}
					}
					SetClipAmmo(weaponInSlot, GetClipAmmo(weaponInSlot) + 1);
				}
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

	return Plugin_Continue;
}

public Action:SrEventPlayerDeathPre(Handle:event, const String:name[], bool:dontBroadcast) {
    if (g_KillRound && !g_Bomberman) {
        if (IsWiped()) {
            SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);
        }
    }
}

public Action:SrEventEntityDeath(Handle:event, const String:name[], bool:dontBroadcast) {
	new entity = GetEventInt(event, "otherid");

	if (g_BuddySystem) {
		new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
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
					SDKHooks_TakeDamage(i, attacker, attacker, float(g_Health), DMG_GENERIC);
					chickenMap.Remove(playerIdString);

					break;
				}
			}
		}
	}

	if (g_Drones) {
		new String:entityIdString[64];
		IntToString(entity, entityIdString, sizeof(entityIdString));

		int client;
		if (droneMap.GetValue(entityIdString, client)) {
			droneMap.Remove(entityIdString);

			GivePlayerItem(client, "weapon_decoy");
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

public Action:SrEventPlayerBlind(Handle:event, const String:name[], bool:dontBroadcast) {
	if (g_FlashDmg) {
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (IsPlayerAlive(client)) {
			int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
			int entityId = GetEventInt(event, "entityid");
			float blindDuration = GetEventFloat(event, "blind_duration");

			int damage = RoundToNearest(blindDuration * 8.5);

			SDKHooks_TakeDamage(client, entityId, attacker, float(damage), DMG_GENERIC);
		}
	}
}

public Action:SrEventSwitchTeam(Event event, const char[] name, bool dontBroadcast) {

    if (!pugSetupLoaded && !inGame && g_AutoStart.IntValue == 1) {
        int numPlayers = GetEventInt(event, "numPlayers");

        if (numPlayers >= g_AutoStartMinPlayers.IntValue) {
            ServerCommand("mp_warmup_end 5");
            inGame = true;
        }
    }
}

public Action:SrEventPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	if ((g_Reincarnation || g_TeamLives) && !roundHasEnded) {
		int client = GetClientOfUserId(GetEventInt(event, "userid"));

		// Give player weapons again
		GivePlayerItem(client, primaryWeapon);
		GivePlayerItem(client, secondaryWeapon);

		// Give defuser if enabled
		if (StrEqual(Defuser, "1")) {
			SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
		}

		// Give armor if enabled
		if (!StrEqual(Armor, "0")) {
			new armorInt = StringToInt(Armor);
			Client_SetArmor(client, armorInt);
		}

		// Give helmet if enabled
		if (StrEqual(Helmet, "1")) {
			SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), 1);
		}

		// Set health
		SetEntityHealth(client, g_Health);

		// Remove knife if enabled
		if (StrEqual(NoKnife, "1")) {
			SetKnife(false);
		}

		if (g_TeamLives) {
			int team = GetClientTeam(client);

			if (team == CS_TEAM_T) {
				tLives -= 1;

				if (tLives < 1) {
					SetConVarInt(mp_respawn_on_death_t, 0, true, false);
					SendMessageTeam(team, "%t", "NoLivesRemaining");
				} else {
					if (tLives == 1) {
						SendMessageTeam(team, "%t", "OneLifeRemaining");
					} else {
						SendMessageTeam(team, "%t", "LivesRemaining", tLives);
					}
				}
			} else if (team == CS_TEAM_CT) {
				ctLives -= 1;

				if (ctLives < 1) {
					SetConVarInt(mp_respawn_on_death_ct, 0, true, false);
					SendMessageTeam(team, "%t", "NoLivesRemaining");
				} else {
					if (ctLives == 1) {
						SendMessageTeam(team, "%t", "OneLifeRemaining");
					} else {
						SendMessageTeam(team, "%t", "LivesRemaining", ctLives);
					}
				}
			}
		}
	}
}
