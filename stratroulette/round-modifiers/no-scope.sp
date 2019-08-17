public ConfigureNoScope() {
    HookEvent("weapon_zoom", NoScopeWeaponZoomEvent);
}

public ResetNoScope() {
    UnhookEvent("weapon_zoom", NoScopeWeaponZoomEvent);
}

public Action:NoScopeWeaponZoomEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
		int primaryWeaponSlot = GetPlayerWeaponSlot(client, 0);
		CS_DropWeapon(client, primaryWeaponSlot, true, true);
		SendMessage(client, "%t", "DontScope");
	}
}
