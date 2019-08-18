new dontMissHealthBuffer[MAXPLAYERS + 1];

public ConfigureDontMiss() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, DontMissOnTakeDamageHook);
		}
	}

	HookEvent("weapon_fire", DontMissWeaponFireEvent);
}

public ResetDontMiss() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, DontMissOnTakeDamageHook);
			dontMissHealthBuffer[client] = 0;
		}
	}

	UnhookEvent("weapon_fire", DontMissWeaponFireEvent);
}

public Action:DontMissOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	char weaponname[128];
	Client_GetActiveWeaponName(attacker, weaponname, sizeof(weaponname));

	for (int i = 0; i < PRIMARY_LENGTH; i++) {
		if (StrEqual(weaponname, WeaponPrimary[i])) {
			dontMissHealthBuffer[attacker] += PrimaryDamage[i];
			/* HealPlayer(attacker, PrimaryDamage[i], true); */
			return Plugin_Continue;
		}
	}
	for (int i = 0; i < SECONDARY_LENGTH; i++) {
		if (StrEqual(weaponname, WeaponSecondary[i])) {
			dontMissHealthBuffer[attacker] += SecondaryDamage[i];
			/* HealPlayer(attacker, SecondaryDamage[i], true); */
			return Plugin_Continue;
		}
	}

	return Plugin_Continue;
}

public Action:DontMissWeaponFireEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	char weaponname[128];
	Client_GetActiveWeaponName(client, weaponname, sizeof(weaponname));

	for (int i = 0; i < PRIMARY_LENGTH; i++) {
		if (StrEqual(weaponname, WeaponPrimary[i])) {
			DataPack data = new DataPack();
			data.WriteCell(client);
			data.WriteCell(PrimaryDamage[i]);

			CreateTimer(0.1, DontMissDamageTimer, data);
			return Plugin_Continue;
		}
	}
	for (int i = 0; i < SECONDARY_LENGTH; i++) {
		if (StrEqual(weaponname, WeaponSecondary[i])) {
			DataPack data = new DataPack();
			data.WriteCell(client);
			data.WriteCell(SecondaryDamage[i]);

			CreateTimer(0.1, DontMissDamageTimer, data);
			return Plugin_Continue;
		}
	}

	return Plugin_Continue;
}

public Action:DontMissDamageTimer(Handle timer, DataPack data) {
	data.Reset();

	int client = data.ReadCell();
	int damage = data.ReadCell();

	int damageBuffer = dontMissHealthBuffer[client];

	if (damage > damageBuffer) {
		dontMissHealthBuffer[client] = 0;

		SDKHooks_TakeDamage(client, client, client, GetTrueDamage(client, float(damage - damageBuffer)), DMG_GENERIC);
	} else {
		dontMissHealthBuffer[client] -= damage;
	}
}
