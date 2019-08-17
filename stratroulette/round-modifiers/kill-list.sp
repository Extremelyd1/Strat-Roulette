int ctTopList;
char ctTopListName[128];

int tTopList;
char tTopListName[128];

public ConfigureKillList() {
	SetTopList(CS_TEAM_CT);
	SetTopList(CS_TEAM_T);

	if (ctTopList != -1) {
		SendMessage(ctTopList, "%t", "TopKillList");
		SendKillListMessage(CS_TEAM_T);
	}
	if (tTopList != -1) {
		SendMessage(tTopList, "%t", "TopKillList");
		SendKillListMessage(CS_TEAM_CT);
	}

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, KillListPlayerOnTakeDamageHook);
		}
	}

	HookEvent("player_death", KillListPlayerDeathEvent);
}

public ResetKillList() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, KillListPlayerOnTakeDamageHook);
		}
	}

	UnhookEvent("player_death", KillListPlayerDeathEvent);
}

public Action:KillListPlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (!IsWiped()) {
		if (client == ctTopList) {
			SetTopList(CS_TEAM_CT);
			SendMessage(ctTopList, "%t", "TopKillList");
			SendKillListMessage(CS_TEAM_T);
		} else if (client == tTopList) {
			SetTopList(CS_TEAM_T);
			SendMessage(tTopList, "%t", "TopKillList");
			SendKillListMessage(CS_TEAM_CT);
		}
	}
}

public Action:KillListPlayerOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if (victim != ctTopList && victim != tTopList) {
		SendMessage(attacker, "%t", "KillListWrongTarget");

		SDKHooks_TakeDamage(attacker, attacker, attacker, GetTrueDamage(attacker, float(health)), DMG_BULLET);

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public SetTopList(team) {
	if (team == CS_TEAM_CT) {
		ctTopList = GetRandomPlayerFromTeam(team);
		GetClientName(ctTopList, ctTopListName, sizeof(ctTopListName));
	} else {
		tTopList = GetRandomPlayerFromTeam(team);
		GetClientName(tTopList, tTopListName, sizeof(tTopListName));
	}
}

public SendKillListMessage(team) {
	if (team == CS_TEAM_CT) {
		SendMessageTeam(team, "%t", "NewTarget", tTopListName);
	} else if (team == CS_TEAM_T) {
		SendMessageTeam(team, "%t", "NewTarget", ctTopListName);
	}
}
