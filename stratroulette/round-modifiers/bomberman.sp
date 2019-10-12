Handle c4Timer;
new bombermanSkip[MAXPLAYERS + 1];
float bombermanPositions[MAXPLAYERS + 1][3];

public ConfigureBomberman() {
	SetConVarInt(mp_plant_c4_anywhere, 1, true, false);
	SetConVarInt(mp_c4timer, 10, true, false);
	SetConVarInt(mp_c4_cannot_be_defused, 1, true, false);
	SetConVarInt(mp_anyone_can_pickup_c4, 1, true, false);
	SetConVarInt(mp_give_player_c4, 0, true, false);
	SetConVarInt(mp_death_drop_c4, 0, true, false);

	c4Timer = CreateTimer(0.1, CheckC4Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			bombermanSkip[client] = false;
			SDKHook(client, SDKHook_OnTakeDamageAlive, BombermanOnTakeDamageHook);
			bombermanPositions[client][2] = -1.0;
		}
	}

	AddCommandListener(DenyDropListener, "drop");
}

public ResetBomberman() {
	SafeKillTimer(c4Timer);

	SetConVarInt(mp_plant_c4_anywhere, 0, true, false);
	SetConVarInt(mp_c4timer, 40, true, false);
	SetConVarInt(mp_c4_cannot_be_defused, 0, true, false);
	SetConVarInt(mp_anyone_can_pickup_c4, 0, true, false);
	SetConVarInt(mp_give_player_c4, 1, true, false);
	SetConVarInt(mp_death_drop_c4, 1, true, false);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamageAlive, BombermanOnTakeDamageHook);
		}
	}

	RemoveCommandListener(DenyDropListener, "drop");
}

public Action:BombermanDropListener(int client, const char[] command, int args) {
	return Plugin_Stop;
}

public Action:BombermanOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (bombermanSkip[victim]) {
		bombermanSkip[victim] = false;
		return Plugin_Continue;
	}

	new victimHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
	if (victimHealth <= damage) {
		// Victim would have been killed by bomb damage

		// Check whether team is wiped
		bool ctWiped = true;
		bool tWiped = true;

		for (int client = 1; client <= MaxClients; client++) {
			if (IsClientInGame(client) && IsPlayerAlive(client) && client != victim) {
				if (GetClientTeam(client) == CS_TEAM_CT) {
					ctWiped = false;
				} else if (GetClientTeam(client) == CS_TEAM_T) {
					tWiped = false;
				}
			}
		}

		if (!ctWiped && !tWiped) {
			bombermanSkip[victim] = true;
			SDKHooks_TakeDamage(victim, victim, victim, GetTrueDamage(victim, float(health)), DMG_BLAST);
			return Plugin_Handled;
		}

		// Wait 0.1 seconds before killing player manually,
		// to allow round end by bomb to be bypassed
		if (ctWiped) {
			CreateTimer(0.1, BombermanWipeTeamTimer, CS_TEAM_CT);
		} else if (tWiped) {
			CreateTimer(0.1, BombermanWipeTeamTimer, CS_TEAM_T);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action:BombermanWipeTeamTimer(Handle timer, int team) {
	SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (GetClientTeam(client) == team) {
				bombermanSkip[client] = true;
				SDKHooks_TakeDamage(client, client, client, GetTrueDamage(client, float(health)), DMG_BLAST);
			}
		}
	}
}

public Action:CheckC4Timer(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			new c4Slot = GetPlayerWeaponSlot(i, 4);

			float playerPos[3];
			GetClientEyePosition(i, playerPos);

			if (c4Slot < 0) {
				if (bombermanPositions[i][2] != -1.0) {
					float oldPlayerPos[3];
					oldPlayerPos[0] = bombermanPositions[i][0];
					oldPlayerPos[1] = bombermanPositions[i][1];
					oldPlayerPos[2] = bombermanPositions[i][2];

					float distance = GetVectorDistance(oldPlayerPos, playerPos);

					if (distance > 10) {
						new c4 = GivePlayerItem(i, "weapon_c4");
						EquipPlayerWeapon(i, c4);
					}
				} else {
					new c4 = GivePlayerItem(i, "weapon_c4");
					EquipPlayerWeapon(i, c4);
				}
			}

			bombermanPositions[i] = playerPos;
		}
	}

	return Plugin_Continue;
}
