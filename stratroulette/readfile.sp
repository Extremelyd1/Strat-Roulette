public ReadNewRound() {
	int numberOfStrats = GetNumberOfStrats();

	/* PrintToServer("Number of strats: %d", numberOfStrats); */

	KeyValues kv = new KeyValues("Strats");
	kv.ImportFromFile(STRAT_FILE);

	ArrayList possibleRoundNumbers = new ArrayList();

	for (int i = 1; i <= numberOfStrats; i++) {
		if (i != lastRound) {
			possibleRoundNumbers.Push(i);
		}
	}

	int roundNumber = possibleRoundNumbers.Get(GetRandomInt(0, possibleRoundNumbers.Length - 1));

	char roundNumberString[16];

	if (forceNextRound) {
		Format(roundNumberString, sizeof(roundNumberString), forceRoundNumber);
		forceNextRound = false;
		lastRound = StringToInt(voteRoundNumber);
	} else if (nextRoundVoted) {
		Format(roundNumberString, sizeof(roundNumberString), voteRoundNumber);
		nextRoundVoted = false;
		lastRound = StringToInt(voteRoundNumber);
	} else {
		IntToString(roundNumber, roundNumberString, sizeof(roundNumberString));
		lastRound = roundNumber;
	}

	if (!kv.JumpToKey(roundNumberString)) {
		PrintToServer("Strat number %s could not be found!", roundNumberString);

		delete kv;
		return 0;
	}

	PrintToServer("Picked strat %s", roundNumberString);

	kv.GetString("name", RoundName, sizeof(RoundName), "No name round!");
	kv.GetString("thirdperson", ThirdPerson, sizeof(ThirdPerson), "0");
	kv.GetString("collision", Collision, sizeof(Collision), "default");
	kv.GetString("weapon", Weapon, sizeof(Weapon), "weapon_none");
	kv.GetString("health", Health, sizeof(Health), "100");
	kv.GetString("decoysound", DecoySound, sizeof(DecoySound), "1");
	kv.GetString("noknife", NoKnife, sizeof(NoKnife), "0");
	kv.GetString("infiniteammo", InfiniteAmmo, sizeof(InfiniteAmmo), "0");
	kv.GetString("infinitenade", InfiniteNade, sizeof(InfiniteNade), "0");
	kv.GetString("speed", PlayerSpeed, sizeof(PlayerSpeed), "1.0");
	kv.GetString("gravity", PlayerGravity, sizeof(PlayerGravity), "800");
	kv.GetString("norecoil", NoRecoil, sizeof(NoRecoil), "0");
	kv.GetString("vampire", Vampire, sizeof(Vampire), "0");
	kv.GetString("pcolor", PColor, sizeof(PColor), "null");
	kv.GetString("backwards", Backwards, sizeof(Backwards), "0");
	kv.GetString("fov", Fov, sizeof(Fov), "90");
	kv.GetString("chickendef", ChickenDefuse, sizeof(ChickenDefuse), "0");
	kv.GetString("headshot", HeadShot, sizeof(HeadShot), "0");
	kv.GetString("slowmotion", SlowMotion, sizeof(SlowMotion), "0");
	kv.GetString("noscope", NoScope, sizeof(NoScope), "0");
	kv.GetString("recoilview", RecoilView, sizeof(RecoilView), "0.0555");
	kv.GetString("alwaysmove", AlwaysMove, sizeof(AlwaysMove), "0");
	kv.GetString("dropweapons", DropWeapons, sizeof(DropWeapons), "0");
	kv.GetString("tinymags", TinyMags, sizeof(TinyMags), "0");
	kv.GetString("followleader", Leader, sizeof(Leader), "0");
	kv.GetString("showallmap", AllOnMap, sizeof(AllOnMap), "0");
	kv.GetString("invisible", Invisible, sizeof(Invisible), "0");
	kv.GetString("defuser", Defuser, sizeof(Defuser), "0");
	kv.GetString("armor", Armor, sizeof(Armor), "0");
	kv.GetString("helmet", Helmet, sizeof(Helmet), "0");
	kv.GetString("noc4", NoC4, sizeof(NoC4), "0");
	kv.GetString("zombies", Zombies, sizeof(Zombies), "0");
	kv.GetString("axe", Axe, sizeof(Axe), "0");
	kv.GetString("fists", Fists, sizeof(Fists), "0");
	kv.GetString("hitswap", HitSwap, sizeof(HitSwap), "0");
	kv.GetString("buddysystem", BuddySystem, sizeof(BuddySystem), "0");
	kv.GetString("randomnade", RandomNade, sizeof(RandomNade), "0");
	kv.GetString("redgreen", RedGreen, sizeof(RedGreen), "0");
	kv.GetString("manhunt", Manhunt, sizeof(Manhunt), "0");
	kv.GetString("winner", Winner, sizeof(Winner), "0");
	kv.GetString("hotpotato", HotPotato, sizeof(HotPotato), "0");
	kv.GetString("killround", KillRound, sizeof(KillRound), "0");
	kv.GetString("bomberman", Bomberman, sizeof(Bomberman), "0");
	kv.GetString("dontmiss", DontMiss, sizeof(DontMiss), "0");
	kv.GetString("crabwalk", CrabWalk, sizeof(CrabWalk), "0");
	kv.GetString("randomguns", RandomGuns, sizeof(RandomGuns), "0");
	kv.GetString("poison", Poison, sizeof(Poison), "0");
	kv.GetString("bodyguard", Bodyguard, sizeof(Bodyguard), "0");
	kv.GetString("zeusround", ZeusRound, sizeof(ZeusRound), "0");
	kv.GetString("pockettp", PocketTP, sizeof(PocketTP), "0");
	kv.GetString("oitc", OneInTheChamber, sizeof(OneInTheChamber), "0");
	kv.GetString("captcha", Captcha, sizeof(Captcha), "0");
	kv.GetString("monkeysee", MonkeySee, sizeof(MonkeySee), "0");
	kv.GetString("stealth", Stealth, sizeof(Stealth), "0");
	kv.GetString("flashdmg", FlashDmg, sizeof(FlashDmg), "0");
	kv.GetString("killlist", KillList, sizeof(KillList), "0");
	kv.GetString("breach", Breach, sizeof(Breach), "0");
	kv.GetString("drones", Drones, sizeof(Drones), "0");
	kv.GetString("bumpmine", Bumpmine, sizeof(Bumpmine), "0");
	kv.GetString("panic", Panic, sizeof(Panic), "0");
	kv.GetString("dropshot", Dropshot, sizeof(Dropshot), "0");
	kv.GetString("hardcore", Hardcore, sizeof(Hardcore), "0");
	kv.GetString("tunnelvision", TunnelVision, sizeof(TunnelVision), "0");
	kv.GetString("downunder", DownUnder, sizeof(DownUnder), "0");
	kv.GetString("reincarnation", Reincarnation, sizeof(Reincarnation), "0");
	kv.GetString("teamlives", TeamLives, sizeof(TeamLives), "0");
	kv.GetString("jumpshot", Jumpshot, sizeof(Jumpshot), "0");
	kv.GetString("nofall", NoFallDamage, sizeof(NoFallDamage), "0");
	kv.GetString("forwardonly", ForwardOnly, sizeof(ForwardOnly), "0");

	char descriptionOverride[3];
	kv.GetString("descoverride", descriptionOverride, sizeof(descriptionOverride), "0");

	char description[2048];
	kv.GetString("description", description, sizeof(description), "");

	SendMessageAll(" ");
	SendMessageAll("{LIGHT_BLUE}-----------------------------------------------------------------------------------------");
	SendMessageAll("%t", RoundName);
	SendMessageAll(" ");
	SendMessageAll("%t", description);
	SendMessageAll("{LIGHT_BLUE}-----------------------------------------------------------------------------------------");
	SendMessageAll(" ");

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && !IsFakeClient(client)) {
			PrintToConsole(client, "%t", "ConsoleRoundName");
			PrintToConsole(client, "	%t", RoundName);

			PrintToConsole(client, "%t", "ConsoleDescription");
			PrintToConsole(client, "	%t", description);
			if (StrEqual(descriptionOverride, "0")) {
				if (StrEqual(KillRound, "1")) {
					PrintToConsole(client, "%t", "ConsoleRoundInfoElimination");
				} else if (StrEqual(Winner, "t")) {
					PrintToConsole(client, "%t", "ConsoleRoundInfoEliminationTerroristWinTimeUp");
				} else if (StrEqual(Winner, "draw")) {
					PrintToConsole(client, "%t", "ConsoleRoundInfoEliminationDrawTimeUp");
				} else {
					PrintToConsole(client, "%t", "ConsoleRoundInfoDefault");
				}
			}
		}
	}

	PrintCenterTextAll("%t", RoundName);

	ResetConfiguration();

	//** Collision **//
	ConfigureCollision();
	//** Zombies **//
	ConfigureZombies();
	//** Third person **//
	ConfigureThirdPerson();
	//** Weapons **//
	ConfigureWeapons();
	//** Armor and kits **//
	ConfigureArmorDefuser();
	//** Health **//
	ConfigureHealth();
	//** Decoy sound **//
	ConfigureDecoySound();
	//** No knife **//
	ConfigureNoKnife();
	//** Infinite ammo **//
	ConfigureInfiniteAmmo();
	//** Infinite  nade **//
	ConfigureInfiniteNades();
	//** Speed **//
	ConfigureSpeed();
	//** Gravity **//
	ConfigureGravity();
	//** No recoil **//
	ConfigureNoRecoil();
	//** Noscope **//
	ConfigureNoScope();
	//** Vampire **//
	ConfigureVampire();
	//** Player color **//
	ConfigurePlayerColors();
	//** Backwards **//
	ConfigureBackwards();
	//** Fov **//
	ConfigureFov();
	//** Chicken defuse **//
	ConfigureChickenDefuse();
	//** Headshot only **//
	ConfigureHeadshotOnly();
	//** Speedchange **//
	ConfigureSlowMotion();
	//** Weird recoil view **//
	ConfigureWeirdRecoilView();
	//** Friction **//
	ConfigureFriction();
	//** Drop weapons **//
	ConfigureDropWeapons();
	//** One in the chamber **//
	ConfigureTinyMags();
	//** Follow the leader **//
	ConfigureLeader();
	//** Show all on map **//
	ConfigureAllOnMap();
	//** Invisible **//
	ConfigureInvisible();
	//** Axe or fists **//
	ConfigureAxeFists();
	//** Buddy System **//
	ConfigureBuddySystem();
	//** Random nades **//
	ConfigureRandomNade();
	//** HitSwap **//
	ConfigureHitSwap();
	//** Red light, green light **//
	ConfigureRedGreen();
	//** Manhunt **//
	ConfigureManhunt();
	//** Default winner **//
	ConfigureWinner();
	//** Hot potato **//
	ConfigureHotPotato();
	//** Kill round **//
	ConfigureKillRound();
	//** Bomberman **//
	ConfigureBomberman();
	//** Dont miss **//
	ConfigureDontMiss();
	//** Crab Walk **//
	ConfigureCrabWalk();
	//** Random Guns **//
	ConfigureRandomGuns();
	//** Poison **//
	ConfigurePoison();
	//** Bodyguard **//
	ConfigureBodyguard();
	//** Auto zeus **//
	ConfigureZeusRound();
	//** PocketTP **//
	ConfigurePocketTP();
	//** One in the Chamber **//
	ConfigureOneInTheChamber();
	//** Captcha **//
	ConfigureCaptcha();
	//** Monkey see, Monkey do **//
	ConfigureMonkeySee();
	//** Stealth **//
	ConfigureStealth();
	//** Flash damage **//
	ConfigureFlashDmg();
	//** Kill List **//
	ConfigureKillList();
	//** Breach **//
	ConfigureBreach();
	//** Drones **//
	ConfigureDrones();
	//** Bumpmine **//
	ConfigureBumpmine();
	//** Panic **//
	ConfigurePanic();
	//** Dropshot **//
	ConfigureDropshot();
	//** Hardcore **//
	ConfigureHardcore();
	//** Tunnel Vision **//
	ConfigureTunnelVision();
	//** Down Under **//
	ConfigureDownUnder();
	//** Reincarnation **//
	ConfigureReincarnation();
	//** Team Lives **//
	ConfigureTeamLives();
	//** Jumpshot **//
	ConfigureJumpshot();
	//** No fall damage **//
	ConfigureNoFallDamage();
	//** Forward only **//
	ConfigureForwardOnly();

	delete kv;

	return 1;
}
