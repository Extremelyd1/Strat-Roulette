char primaryWeapon[128];
char secondaryWeapon[128];

public ConfigureWeapons(char weaponString[500]) {
	// For random weapon generate first whether it
	// should be primary of secondary
	new randomIntCat = -1;
	if (StrContains(weaponString, "weapon_random") != -1) {
		randomIntCat = GetRandomInt(0, 1);
	}

	int randomAutoWeapon;

	if (StrContains(weaponString, "weapon_auto_random") != -1) {
		randomAutoWeapon = GetRandomInt(0, AUTO_WEAPONS_LENGTH - 1);
		if (randomAutoWeapon == 0) {
			Format(secondaryWeapon, sizeof(secondaryWeapon), AutoWeapons[randomAutoWeapon]);
		} else {
			Format(primaryWeapon, sizeof(primaryWeapon), AutoWeapons[randomAutoWeapon]);
		}
	}

	if (StrContains(weaponString, "weapon_primary_random") != -1 || randomIntCat == 0) {
		new randomInt = GetRandomInt(0, PRIMARY_LENGTH - 1);
		Format(primaryWeapon, sizeof(primaryWeapon), WeaponPrimary[randomInt]);
	}
	if (StrContains(weaponString, "weapon_secondary_random") != -1 || randomIntCat == 1) {
		new randomInt = GetRandomInt(0, SECONDARY_LENGTH - 1);
		Format(secondaryWeapon, sizeof(secondaryWeapon), WeaponSecondary[randomInt]);
	}

	// If we need to give a weapon
	if (!StrEqual(weaponString, "none")) {
		char colonSplit[10][80];
		new colonSplitNumber = ExplodeString(weaponString, ";", colonSplit, sizeof(colonSplit), sizeof(colonSplit[]));

		for (int colonIndex = 0; colonIndex < colonSplitNumber; colonIndex++) {
			for (int j = 1; j <= MaxClients; j++) {
				if (IsClientInGame(j) && IsPlayerAlive(j)) {
					if (StrEqual(colonSplit[colonIndex], "weapon_primary_random")
					 || (StrEqual(colonSplit[colonIndex], "weapon_random") && randomIntCat == 0)
					 || (StrEqual(colonSplit[colonIndex], "weapon_auto_random") && randomAutoWeapon != 0)) {
						GivePlayerItem(j, primaryWeapon);
					} else if (StrEqual(colonSplit[colonIndex], "weapon_secondary_random")
					 || (StrEqual(colonSplit[colonIndex], "weapon_random") && randomIntCat == 1)
					 || (StrEqual(colonSplit[colonIndex], "weapon_auto_random") && randomAutoWeapon == 0)) {
						GivePlayerItem(j, secondaryWeapon);
					} else {
						new item = GivePlayerItem(j, colonSplit[colonIndex]);
						char className[128];
						GetEdictClassname(item, className, sizeof(className));

						if (StrEqual(className, "weapon_bumpmine")) {
							EquipPlayerWeapon(j, item);
						}
					}
				}
			}
		}
	}
}

public ResetWeapons() {
	primaryWeapon = "";
	secondaryWeapon = "";

	RemoveWeapons();
	RemoveNades();
}
