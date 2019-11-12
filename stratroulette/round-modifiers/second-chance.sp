new secondChanceAlive[MAXPLAYERS + 1]

int secondChanceCTAlive;
int secondChanceTAlive;

public ConfigureSecondChance() {
	SetConVarInt(mp_respawn_on_death_ct, 1, true, false);
	SetConVarInt(mp_respawn_on_death_t, 1, true, false);
	SetConVarInt(mp_ignore_round_win_conditions, 1, true, false);

	secondChanceCTAlive = 0;
	secondChanceTAlive = 0;

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			secondChanceAlive[client] = true;

			if (GetClientTeam(client) == CS_TEAM_CT) {
				secondChanceCTAlive += 1;
			} else if (GetClientTeam(client) == CS_TEAM_T) {
				secondChanceTAlive += 1;
			}
		}
	}

	HookEvent("player_death", SecondChancePlayerDeathEvent, EventHookMode_Pre);
}

public ResetSecondChance() {
	SetConVarInt(mp_respawn_on_death_ct, 0, true, false);
	SetConVarInt(mp_respawn_on_death_t, 0, true, false);

	UnhookEvent("player_death", SecondChancePlayerDeathEvent, EventHookMode_Pre);
}

public Action:SecondChancePlayerDeathEvent(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (secondChanceAlive[client]) {
		secondChanceAlive[client] = false;

		if (GetClientTeam(client) == CS_TEAM_CT) {
			secondChanceCTAlive -= 1;
		} else if (GetClientTeam(client) == CS_TEAM_T) {
			secondChanceTAlive -= 1;
		}

		if (secondChanceCTAlive == 0) {
			SetConVarInt(mp_respawn_on_death_ct, 0, true, false);
			SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);
			SecondChanceWipe(CS_TEAM_CT);
			return Plugin_Continue;
		}
		if (secondChanceTAlive == 0) {
			SetConVarInt(mp_respawn_on_death_t, 0, true, false);
			SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);
			SecondChanceWipe(CS_TEAM_T);
			return Plugin_Continue;
		}

		if (killer > 0) {
			if (!secondChanceAlive[killer]) {
				secondChanceAlive[killer] = true;

				// Give player weapons again
				GivePlayerItem(killer, primaryWeapon);
				GivePlayerItem(killer, secondaryWeapon);

				// Give armor if enabled
				if (armorInt != 0) {
					Client_SetArmor(killer, armorInt);
				}

				// Set health
				SetEntityHealth(killer, health);

				if (GetClientTeam(killer) == CS_TEAM_CT) {
					secondChanceCTAlive += 1;
				} else if (GetClientTeam(killer) == CS_TEAM_T) {
					secondChanceTAlive += 1;
				}
			}
		}
	}

	return Plugin_Continue;
}

public SecondChanceWipe(int team) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (GetClientTeam(client) == team) {
				SDKHooks_TakeDamage(client, client, client, GetTrueDamage(client, float(health)), DMG_GENERIC);
			}
		}
	}
}
