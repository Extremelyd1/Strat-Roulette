public ConfigureFlashDamage() {
	HookEvent("player_blind", FlashDamagePlayerBlindEvent);
}

public ResetFlashDamage() {
	UnhookEvent("player_blind", FlashDamagePlayerBlindEvent);
}

public Action:FlashDamagePlayerBlindEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsPlayerAlive(client)) {
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		int entityId = GetEventInt(event, "entityid");
		float blindDuration = GetEventFloat(event, "blind_duration");

		int damage = RoundToNearest(blindDuration * 8.5);

		SDKHooks_TakeDamage(client, entityId, attacker, float(damage), DMG_GENERIC);
	}
}
