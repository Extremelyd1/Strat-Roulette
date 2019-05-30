public ReadNewRound() {
    KeyValues kv = new KeyValues("Strats");

    if (!kv.ImportFromFile(STRAT_FILE)) {
        PrintToServer("Strat file could not be found!");

        delete kv;
        return 0;
    }

    if (!kv.GotoFirstSubKey(false)) {
        PrintToServer("No strats in strat file!");

        delete kv;
        return 0;
    }

    int numberOfStrats = 0;

    do {
        if (kv.GetDataType(NULL_STRING) == KvData_None) {
            numberOfStrats++;
        }
    } while (kv.GotoNextKey(false));

    /* PrintToServer("Number of strats: %d", numberOfStrats); */

    kv = new KeyValues("Strats");
    kv.ImportFromFile(STRAT_FILE);

	int roundNumber = GetRandomInt(1, numberOfStrats);

    char roundNumberString[16];

    if (setNextRound) {
        Format(roundNumberString, sizeof(roundNumberString), "%s", forceRoundNumber);
        setNextRound = false;
    } else {
        IntToString(roundNumber, roundNumberString, sizeof(roundNumberString));
    }

    if (!kv.JumpToKey(roundNumberString)) {
        PrintToServer("Strat number %s could not be found!", roundNumberString);

        delete kv;
        return 0;
    }

    PrintToServer("Picked strat %s", roundNumberString);

    kv.GetString("name", RoundName, sizeof(RoundName), "No name round!");
    kv.GetString("thirdperson", ThirdPerson, sizeof(ThirdPerson), "0");
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
    kv.GetString("oitc", OneInTheChamber, sizeof(OneInTheChamber), "0");
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
    kv.GetString("winner", Winner, sizeof(Winner), "t");
    kv.GetString("hotpotato", HotPotato, sizeof(HotPotato), "0");
    kv.GetString("killround", KillRound, sizeof(KillRound), "0");
    kv.GetString("bomberman", Bomberman, sizeof(Bomberman), "0");
    kv.GetString("dontmiss", DontMiss, sizeof(DontMiss), "0");
    kv.GetString("crabwalk", CrabWalk, sizeof(CrabWalk), "0");
    kv.GetString("randomguns", RandomGuns, sizeof(RandomGuns), "0");
    kv.GetString("poison", Poison, sizeof(Poison), "0");
    kv.GetString("bodyguard", Bodyguard, sizeof(Bodyguard), "0");
    kv.GetString("zeusround", ZeusRound, sizeof(ZeusRound), "0");

    new String:divider[] = "{DARK_BLUE}----------------------------------------";
    Colorize(divider, sizeof(divider));

    Colorize(RoundName, sizeof(RoundName));

	PrintCenterTextAll(RoundName);
	CPrintToChatAll(divider);
	CPrintToChatAll(RoundName);
	CPrintToChatAll(divider);

    ResetConfiguration();

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
    ConfigureOneInTheChamber();
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

    return 1;
}
