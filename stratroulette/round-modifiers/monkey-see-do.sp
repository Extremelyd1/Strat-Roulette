int monkeyOneTeam = -1;
int ctMonkeyLeader;
int tMonkeyLeader;

Handle monkeyTimer;

public ConfigureMonkeySeeDo() {
	int ctPlayers = 0;
	int tPlayers = 0;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (GetClientTeam(client) == CS_TEAM_CT) {
				ctPlayers++;
			} else if (GetClientTeam(client) == CS_TEAM_T) {
				tPlayers++;
			}

			SDKHook(client, SDKHook_OnTakeDamage, MonkeySeeDoPlayerOnTakeDamageHook);
		}
	}

	if (ctPlayers + tPlayers < 2) {
		return;
	}

	if (ctPlayers + tPlayers < 4) {
		int randomTeam = -1;
		if (tPlayers == ctPlayers) {
			randomTeam = GetRandomInt(0, 1);
		}

		if (tPlayers > ctPlayers || randomTeam == 0) {
			monkeyOneTeam = CS_TEAM_CT;
			SetConVarInt(mp_default_team_winner_no_objective, 2, true, false);
		} else if (ctPlayers > tPlayers || randomTeam == 1) {
			monkeyOneTeam = CS_TEAM_T;
		}
	} else {
		ConfigureKillRound();

		resetFunctions[resetFunctionsLength++] = ResetKillRound;
	}

	if (monkeyOneTeam != CS_TEAM_T) {
		ctMonkeyLeader = GetRandomPlayerFromTeam(CS_TEAM_CT);
	}
	if (monkeyOneTeam != CS_TEAM_CT) {
		tMonkeyLeader = GetRandomPlayerFromTeam(CS_TEAM_T);
	}

	monkeyTimer = CreateTimer(1.5, StartMonkeyTimer);
}

public ResetMonkeySeeDo() {
	SafeKillTimer(monkeyTimer);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, MonkeySeeDoPlayerOnTakeDamageHook);
		}
	}

	SetConVarInt(mp_default_team_winner_no_objective, -1, true, false);

	ctMonkeyLeader = -1;
	tMonkeyLeader = -1;
	monkeyOneTeam = -1;
}

public Action:MonkeySeeDoPlayerOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	return Plugin_Handled;
}

public Action:StartMonkeyTimer(Handle timer) {
	float ctPos[3];
	float tPos[3];

	if (monkeyOneTeam != CS_TEAM_T) {
		GetEntPropVector(ctMonkeyLeader, Prop_Send, "m_vecOrigin", ctPos);
	}
	if (monkeyOneTeam != CS_TEAM_CT) {
		GetEntPropVector(tMonkeyLeader, Prop_Send, "m_vecOrigin", tPos);
	}

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			if (GetClientTeam(client) == CS_TEAM_CT) {
				if (client == ctMonkeyLeader) {
					SendMessage(client, "%t", "LoseTerrorists");
				} else {
					SendMessage(client, "%t", "KeepUpWithTerrorist");
					TeleportEntity(client, tPos, NULL_VECTOR, NULL_VECTOR);
				}
			} else if (GetClientTeam(client) == CS_TEAM_T) {
				if (client == tMonkeyLeader) {
					SendMessage(client, "%t", "LoseCounterTerrorists");
				} else {
					SendMessage(client, "%t", "KeepUpWithCounterTerrorist");
					TeleportEntity(client, ctPos, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
	}

	monkeyTimer = CreateTimer(0.5, CheckMonkeyTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Stop;
}

public Action:CheckMonkeyTimer(Handle timer) {
	float ctPos[3];
	float tPos[3];

	if (monkeyOneTeam != CS_TEAM_T) {
		GetClientEyePosition(ctMonkeyLeader, ctPos);
	}
	if (monkeyOneTeam != CS_TEAM_CT) {
		GetClientEyePosition(tMonkeyLeader, tPos);
	}

	int ctAlive = 0;
	int tAlive = 0;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			if (client != ctMonkeyLeader && client != tMonkeyLeader) {
				float pos[3];
				GetClientEyePosition(client, pos);
				float distance = -1.0;

				if (GetClientTeam(client) == CS_TEAM_CT) {
					ctAlive++;
					distance = GetVectorDistance(pos, tPos);
				} else if (GetClientTeam(client) == CS_TEAM_T) {
					tAlive++;
					distance = GetVectorDistance(pos, ctPos);
				}

				if (distance > 400) {
					SDKHooks_TakeDamage(client, client, client, GetTrueDamage(client, 5.0), DMG_GENERIC);
					SendMessage(client, "%t", "TooFarFromLeader");
				}
			}
		}
	}

	if (monkeyOneTeam == -1) {
		if (ctAlive == 0) {
			SDKHooks_TakeDamage(ctMonkeyLeader, tMonkeyLeader, tMonkeyLeader, float(health), DMG_GENERIC);
			return Plugin_Stop;
		} else if (tAlive == 0) {
			SDKHooks_TakeDamage(tMonkeyLeader, ctMonkeyLeader, ctMonkeyLeader, float(health), DMG_GENERIC);
			return Plugin_Stop;
		}
	}

	return Plugin_Continue;
}
