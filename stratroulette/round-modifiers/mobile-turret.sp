public ConfigureMobileTurret() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_WeaponSwitch, MobileTurretWeaponSwitchHook);
		}
	}

	AddCommandListener(DenyDropListener, "drop");
}

public ResetMobileTurret() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_WeaponSwitch, MobileTurretWeaponSwitchHook);
		}
	}

	RemoveCommandListener(DenyDropListener, "drop");
}

public Action:MobileTurretWeaponSwitchHook(int client, int weapon) {
	int primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);

	if (weapon == primary) {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
	} else {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}
}
