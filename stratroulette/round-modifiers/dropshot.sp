bool dropshotActive = false;

public ConfigureDropshot() {
	HookEvent("weapon_fire", DropshotWeaponFireEvent);

	dropshotActive = true;
}

public ResetDropshot() {
	dropshotActive = false;

	UnhookEvent("weapon_fire", DropshotWeaponFireEvent);
}

public Action:DropshotWeaponFireEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (weapon > 0) {
		DataPack data = new DataPack();
		data.WriteCell(client);
		data.WriteCell(weapon);
		CreateTimer(0.1, DropShotWeapon, data);
	}

	return Plugin_Continue;
}

public Action:DropShotWeapon(Handle timer, DataPack data) {
	if (!dropshotActive) {
		return Plugin_Stop;
	}
	
	data.Reset();
	int client = data.ReadCell();
	new weapon = data.ReadCell();

	int weaponOwner = EntRefToEntIndex(Weapon_GetOwner(weapon));

	if (weaponOwner == client) {
		CS_DropWeapon(client, weapon, true, true);
	}

	return Plugin_Continue;
}
