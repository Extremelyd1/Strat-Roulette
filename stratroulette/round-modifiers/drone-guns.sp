new StringMap:droneMap;

public ConfigureDroneGuns() {
	droneMap = CreateTrie();

	HookEvent("decoy_started", DroneGunsDecoyStartedEvent);
	HookEvent("other_death", DroneGunsOtherDeathEvent);
}

public ResetDroneGuns() {
	UnhookEvent("decoy_started", DroneGunsDecoyStartedEvent);
	UnhookEvent("other_death", DroneGunsOtherDeathEvent);

	delete droneMap;
}

public Action:DroneGunsDecoyStartedEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new entity = GetEventInt(event, "entityid");
	if (IsValidEntity(entity)) {
		RemoveEntity(entity);

		new client = GetClientOfUserId(GetEventInt(event, "userid"));

		int dronegun = CreateEntityByName("dronegun");

		SetEntData(dronegun, g_offsCollisionGroup, 5, 4, true);
		SetEntPropEnt(dronegun, Prop_Send, "m_hOwnerEntity", client);

		float pos[3];
		pos[0] = GetEventFloat(event, "x");
		pos[1] = GetEventFloat(event, "y");
		pos[2] = GetEventFloat(event, "z");

		TeleportEntity(dronegun, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(dronegun);

		new String:entityIdString[64];
		IntToString(dronegun, entityIdString, sizeof(entityIdString));
		droneMap.SetValue(entityIdString, client);
	}
}

public Action:DroneGunsOtherDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new entity = GetEventInt(event, "otherid");
	new String:entityIdString[64];
	IntToString(entity, entityIdString, sizeof(entityIdString));

	int client;
	if (droneMap.GetValue(entityIdString, client)) {
		droneMap.Remove(entityIdString);

		GivePlayerItem(client, "weapon_decoy");
	}
}
