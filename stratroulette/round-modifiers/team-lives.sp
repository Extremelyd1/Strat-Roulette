int ctLives = 0;
int tLives = 0;

bool teamLivesRoundHasEnded = false;

public ConfigureTeamLives(char numberOfLives[500]) {
	int teamLives = StringToInt(numberOfLives);
	ctLives = teamLives;
	tLives = teamLives;

	SetConVarInt(mp_respawn_on_death_ct, 1, true, false);
	SetConVarInt(mp_respawn_on_death_t, 1, true, false);

	SendMessageAll("%t", "LivesRemaining", teamLives);

	HookEvent("player_spawn", TeamLivesPlayerSpawnEvent);
	HookEvent("round_end", TeamLivesRoundEndEvent);

	teamLivesRoundHasEnded = false;
}

public ResetTeamLives() {
	UnhookEvent("player_spawn", TeamLivesPlayerSpawnEvent);
	UnhookEvent("round_end", TeamLivesRoundEndEvent);

	SetConVarInt(mp_respawn_on_death_ct, 0, true, false);
	SetConVarInt(mp_respawn_on_death_t, 0, true, false);
}

public Action:TeamLivesPlayerSpawnEvent(Event event, const char[] name, bool dontBroadcast) {
	if (teamLivesRoundHasEnded) {
		return Plugin_Continue;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	// Give player weapons again
	GivePlayerItem(client, primaryWeapon);
	GivePlayerItem(client, secondaryWeapon);

	// Give defuser if enabled
	if (defuserEnabled) {
		SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
	}

	// Give armor if enabled
	if (armorInt != 0) {
		Client_SetArmor(client, armorInt);
	}

	// Give helmet if enabled
	if (helmetEnabled) {
		SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), 1);
	}

	// Set health
	SetEntityHealth(client, health);

	// Remove knife if enabled
	if (noKnife) {
		SetKnife(false);
	}

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

	return Plugin_Continue;
}

public Action:TeamLivesRoundEndEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	teamLivesRoundHasEnded = true;
}
