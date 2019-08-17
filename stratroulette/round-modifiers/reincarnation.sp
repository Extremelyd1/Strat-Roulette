bool reincarnationRoundHasEnded = false;

public ConfigureReincarnation() {
	SetConVarInt(mp_respawn_on_death_ct, 1, true, false);
	SetConVarInt(mp_respawn_on_death_t, 1, true, false);

	HookEvent("player_spawn", ReincarnationPlayerSpawnEvent);
	HookEvent("round_end", ReincarnationRoundEndEvent);

	reincarnationRoundHasEnded = false;
}

public ResetReincarnation() {
	SetConVarInt(mp_respawn_on_death_ct, 0, true, false);
	SetConVarInt(mp_respawn_on_death_t, 0, true, false);

	UnhookEvent("player_spawn", ReincarnationPlayerSpawnEvent);
	UnhookEvent("round_end", ReincarnationRoundEndEvent);
}

public Action:ReincarnationPlayerSpawnEvent(Event event, const char[] name, bool dontBroadcast) {
	if (!reincarnationRoundHasEnded) {
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
	}
}

public Action:ReincarnationRoundEndEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	reincarnationRoundHasEnded = true;
}
