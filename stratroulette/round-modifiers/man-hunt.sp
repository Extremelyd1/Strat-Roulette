int ctHunted;
char ctHuntedName[128];

int tHunted;
char tHuntedName[128];

public ConfigureManHunt() {
	SetHunted(CS_TEAM_CT);
	SetHunted(CS_TEAM_T);
	SendVIPMessage(CS_TEAM_CT);
	SendVIPMessage(CS_TEAM_T);

	HookEvent("player_death", ManHuntPlayerDeathEvent);
}

public ResetManHunt() {
	UnhookEvent("player_death", ManHuntPlayerDeathEvent);
}

public Action:ManHuntPlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (client == ctHunted || client == tHunted) {
		int teamToWipe = GetClientTeam(client);

		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == teamToWipe) {
				SDKHooks_TakeDamage(i, killer, killer, GetTrueDamage(i, float(health)), DMG_GENERIC);
			}
		}
	}
}

public SetHunted(team) {
	if (team == CS_TEAM_CT) {
		ctHunted = GetRandomPlayerFromTeam(team);
		GetClientName(ctHunted, ctHuntedName, sizeof(ctHuntedName));
	} else {
		tHunted = GetRandomPlayerFromTeam(team);
		GetClientName(tHunted, tHuntedName, sizeof(tHuntedName));
	}
}

public SendVIPMessage(team) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			if (GetClientTeam(client) == team) {
				if (team == CS_TEAM_CT) {
					SendMessage(client, "%t", "VIPTarget", tHuntedName);
					SendMessage(client, "%t", "VIPProtect", ctHuntedName);
				} else {
					SendMessage(client, "%t", "VIPTarget", ctHuntedName);
					SendMessage(client, "%t", "VIPProtect", tHuntedName);
				}
			}
		}
	}
}
