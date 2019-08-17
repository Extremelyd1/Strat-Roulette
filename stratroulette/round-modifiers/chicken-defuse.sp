new c4Chicken = -1;

public ConfigureChickenDefuse() {
	HookEvent("bomb_planted", ChickenDefuseBombPlantedEvent);
}

public ResetChickenDefuse() {
	UnhookEvent("bomb_planted", ChickenDefuseBombPlantedEvent);

	if (c4Chicken != -1) {
		int chickenRef = EntIndexToEntRef(c4Chicken);
		AcceptEntityInput(chickenRef, "kill");
	}

	c4Chicken = -1;
}

public Action:ChickenDefuseBombPlantedEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new c4 = FindEntityByClassname(-1, "planted_c4");
	if (c4 != -1) {
		c4Chicken = CreateEntityByName("chicken");
		if (c4Chicken != -1) {
			new player = GetClientOfUserId(GetEventInt(event, "userid"));
			decl Float:pos[3];
			GetEntPropVector(player, Prop_Data, "m_vecOrigin", pos);
			pos[2] -= 15.0;
			DispatchSpawn(c4Chicken);
			SetEntProp(c4Chicken, Prop_Data, "m_takedamage", 0);
			SetEntProp(c4Chicken, Prop_Send, "m_fEffects", 0);
			TeleportEntity(c4Chicken, pos, NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(c4, NULL_VECTOR, Float: { 0.0, 0.0, 0.0 }, NULL_VECTOR);
			SetVariantString("!activator");
			AcceptEntityInput(c4, "SetParent", c4Chicken, c4, 0);
		}
	}
}
