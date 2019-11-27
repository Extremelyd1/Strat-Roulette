public SpawnFence(float position[3]) {
	float angles[3];
	for (int i = 0; i < 3; i++) {
		angles[i] = 0.0;
	}

	SpawnFenceWithAngles(position, angles);
}

public SpawnFenceWithAngles(float position[3], float angles[3]) {
	SpawnProp("models/props/de_dust/hr_dust/dust_fences/dust_chainlink_fence_001_256_links.mdl", position, angles);
	SpawnProp("models/props/de_dust/hr_dust/dust_fences/dust_chainlink_fence_001_256.mdl", position, angles);
}

public SpawnScaffolding(float position[3]) {
	float angles[3];
	for (int i = 0; i < 3; i++) {
		angles[i] = 0.0;
	}

	SpawnScaffoldingWithAngles(position, angles);
}

public SpawnScaffoldingWithAngles(float position[3], float angles[3]) {
	SpawnProp("models/props/de_vertigo/scaffolding_walkway_03.mdl", position, angles);
}

public SpawnProp(char model[128], float position[3], float angles[3]) {
	int prop = CreateEntityByName("prop_dynamic");

	SetEntityModel(prop, model);
	DispatchKeyValue(prop, "Solid", "6");

	TeleportEntity(prop, position, angles, NULL_VECTOR);

	DispatchSpawn(prop);

	AcceptEntityInput(prop, "EnableCollision");
}
