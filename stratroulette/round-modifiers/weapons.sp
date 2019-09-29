char primaryWeapon[128];
char secondaryWeapon[128];

public ConfigureWeapons(char weaponString[500]) {
	// For random weapon generate first whether it
	// should be primary of secondary
	new randomIntCat = -1;
	if (StrContains(weaponString, "weapon_random") != -1) {
		randomIntCat = GetRandomInt(0, 1);
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
		decl String:bit[10][80];
		new SumOfStrings = ExplodeString(weaponString, ";", bit, sizeof bit, sizeof bit[]);

		for (int string = 0; string < SumOfStrings; string++) {
			for (int j = 1; j <= MaxClients; j++) {
				if (IsClientInGame(j) && IsPlayerAlive(j)) {
					if (StrEqual(bit[string], "weapon_primary_random")
					 || (StrEqual(bit[string], "weapon_random") && randomIntCat == 0)) {
						GivePlayerItem(j, primaryWeapon);
					} else if (StrEqual(bit[string], "weapon_secondary_random")
					 || (StrEqual(bit[string], "weapon_random") && randomIntCat == 1)) {
						GivePlayerItem(j, secondaryWeapon);
					} else {
						new item = GivePlayerItem(j, bit[string]);
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
