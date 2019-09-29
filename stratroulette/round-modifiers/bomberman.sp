Handle c4Timer;

public ConfigureBomberman() {
	SetConVarInt(mp_plant_c4_anywhere, 1, true, false);
	SetConVarInt(mp_c4timer, 10, true, false);
	SetConVarInt(mp_c4_cannot_be_defused, 1, true, false);
	SetConVarInt(mp_anyone_can_pickup_c4, 1, true, false);

	c4Timer = CreateTimer(0.1, CheckC4Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamageAlive, BombermanOnTakeDamageHook);
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

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamageAlive, BombermanOnTakeDamageHook);
		}
	}

	RemoveCommandListener(DenyDropListener, "drop");
}

public Action:BombermanDropListener(int client, const char[] command, int args) {
	return Plugin_Stop;
}

public Action:BombermanOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
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
				SDKHooks_TakeDamage(client, client, client, GetTrueDamage(client, float(health)), DMG_BLAST);
			}
		}
	}
}

// This becomes problematic when the player is AFK and automatically drops the c4 on the ground
// This then results in a loop of giving and c4 and dropping, eventually causing a massive number
// of c4's to be dropped.
// TODO: fix
public Action:CheckC4Timer(Handle timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			new c4Slot = GetPlayerWeaponSlot(i, 4);

			if (c4Slot < 0) {
				new c4 = GivePlayerItem(i, "weapon_c4");
				EquipPlayerWeapon(i, c4);
			}
		}
	}

	return Plugin_Continue;
}
