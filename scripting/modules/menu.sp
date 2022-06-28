static TopMenu g_adminMenu = null;

static TopMenuObject g_teamManagerCategory = INVALID_TOPMENUOBJECT;
static TopMenuObject g_menuItemMovePlayer = INVALID_TOPMENUOBJECT;
static TopMenuObject g_menuItemSwapTeams = INVALID_TOPMENUOBJECT;
static TopMenuObject g_menuItemScrambleTeams = INVALID_TOPMENUOBJECT;
static TopMenuObject g_menuItemBalanceTeams = INVALID_TOPMENUOBJECT;

void AdminMenu_Create() {
    TopMenu topMenu = GetAdminTopMenu();

    if (LibraryExists(ADMIN_MENU) && topMenu != null) {
        OnAdminMenuReady(topMenu);
    }
}

void AdminMenu_Destroy() {
    g_adminMenu = null;
}

void AdminMenu_OnReady(Handle topMenuHandle) {
    TopMenu topMenu = TopMenu.FromHandle(topMenuHandle);

    if (topMenu == g_adminMenu) {
        return;
    }

    g_adminMenu = topMenu;

    AdminMenu_Fill();
}

void AdminMenu_Fill() {
    g_teamManagerCategory = g_adminMenu.AddCategory(TEAM_MANAGER, AdminMenuHandler_TeamManager);

    if (g_teamManagerCategory != INVALID_TOPMENUOBJECT) {
        g_menuItemMovePlayer = AdminMenu_AddItem(MOVE_PLAYER);
        g_menuItemSwapTeams = AdminMenu_AddItem(SWAP_TEAMS);
        g_menuItemScrambleTeams = AdminMenu_AddItem(SCRAMBLE_TEAMS);
        g_menuItemBalanceTeams = AdminMenu_AddItem(BALANCE_TEAMS);
    }
}

TopMenuObject AdminMenu_AddItem(const char[] name) {
    return g_adminMenu.AddItem(name, AdminMenuHandler_TeamManager, g_teamManagerCategory);
}

public void AdminMenuHandler_TeamManager(TopMenu topmenu, TopMenuAction action, TopMenuObject topobj_id, int param, char[] buffer, int maxlength) {
    if (action == TopMenuAction_DisplayOption) {
        if (topobj_id == g_teamManagerCategory) {
            Format(buffer, maxlength, "%T", TEAM_MANAGER, param);
        } else if (topobj_id == g_menuItemMovePlayer) {
            Format(buffer, maxlength, "%T", MOVE_PLAYER, param);
        } else if (topobj_id == g_menuItemSwapTeams) {
            Format(buffer, maxlength, "%T", SWAP_TEAMS, param);
        } else if (topobj_id == g_menuItemScrambleTeams) {
            Format(buffer, maxlength, "%T", SCRAMBLE_TEAMS, param);
        } else if (topobj_id == g_menuItemBalanceTeams) {
            Format(buffer, maxlength, "%T", BALANCE_TEAMS, param);
        }
    } else if (action == TopMenuAction_DisplayTitle) {
        if (topobj_id == g_teamManagerCategory) {
            Format(buffer, maxlength, "%T", TEAM_MANAGER, param);
        }
    } else if (action == TopMenuAction_SelectOption) {
        if (topobj_id == g_menuItemMovePlayer) {
            Menu_MovePlayer(param);
        } else if (topobj_id == g_menuItemSwapTeams) {
            UseCase_SwapTeams(param);
        } else if (topobj_id == g_menuItemScrambleTeams) {
            UseCase_ScrambleTeams(param);
        } else if (topobj_id == g_menuItemBalanceTeams) {
            Menu_BalanceTeams(param);
        }
    }
}

void Menu_MovePlayer(int client) {
    Menu menu = new Menu(MenuHandler_MovePlayer);

    menu.SetTitle("%T", MOVE_PLAYER, client);

    Menu_AddItem(menu, IMMEDIATELY, client);
    Menu_AddItem(menu, AFTER_DEATH, client);
    Menu_AddItem(menu, AFTER_ROUND_END, client);
    Menu_AddItem(menu, TO_SPECTATORS, client);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_MovePlayer(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        if (StrEqual(info, IMMEDIATELY)) {
            Player_SetMoveType(param1, MovePlayerType_Immediately);
        } else if (StrEqual(info, AFTER_DEATH)) {
            Player_SetMoveType(param1, MovePlayerType_AfterDeath);
        } else if (StrEqual(info, AFTER_ROUND_END)) {
            Player_SetMoveType(param1, MovePlayerType_AfterRoundEnd);
        } else {
            Player_SetMoveType(param1, MovePlayerType_ToSpectators);
        }

        Menu_Players(param1);
    } else {
        MenuHandler_Default(menu, action, param1, param2);
    }

    return 0;
}

void Menu_BalanceTeams(int client) {
    Menu menu = new Menu(MenuHandler_BalanceTeams);

    menu.SetTitle("%T", BALANCE_TEAMS, client);

    Menu_AddItem(menu, MOVE_EXCESS_PLAYERS_TO_SPECTATORS, client);
    Menu_AddItem(menu, DISTRIBUTE_EXCESS_PLAYERS, client);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_BalanceTeams(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        MoveExcessPlayerType moveType = MoveExcessPlayerType_ToSpectators;

        if (StrEqual(info, DISTRIBUTE_EXCESS_PLAYERS)) {
            moveType = MoveExcessPlayerType_Distribute;
        }

        UseCase_BalanceTeams(param1, moveType);
    } else {
        MenuHandler_Default(menu, action, param1, param2);
    }

    return 0;
}

void Menu_Players(int client) {
    Menu menu = new Menu(MenuHandler_Players);

    menu.SetTitle("%T", SELECT_PLAYER, client);

    Menu_AddPlayers(client, menu);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Players(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        int userId = StringToInt(info);
        int target = GetClientOfUserId(userId);

        if (target == 0) {
            Menu_Players(param1);
            MessagePrint_PlayerIsNoLongerAvailable(param1);

            return 0;
        }

        MovePlayerType moveType = Player_GetMoveType(param1);

        UseCase_MovePlayer(param1, target, moveType);
        Menu_Players(param1);
    } else if (action == MenuAction_Cancel) {
        if (param2 == MenuCancel_ExitBack) {
            Menu_MovePlayer(param1);
        }
    } else {
        MenuHandler_Default(menu, action, param1, param2);
    }

    return 0;
}

void MenuHandler_Default(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_End) {
        delete menu;
    } else if (action == MenuAction_Cancel) {
        if (param2 == MenuCancel_ExitBack && g_adminMenu != null) {
            g_adminMenu.Display(param1, TopMenuPosition_LastCategory);
        }
    }
}

void Menu_AddItem(Menu menu, const char[] phrase, int client) {
    char buffer[TEXT_BUFFER_MAX_SIZE];

    Format(buffer, sizeof(buffer), "%T", phrase, client);

    menu.AddItem(phrase, buffer);
}

void Menu_AddPlayers(int client, Menu menu) {
    ArrayList players = Player_GetAll(PlayerPredicate_ActivePlayer);

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);
        int userId = GetClientUserId(player);
        char userIdStr[TEXT_BUFFER_MAX_SIZE];
        char item[TEXT_BUFFER_MAX_SIZE];

        IntToString(userId, userIdStr, sizeof(userIdStr));

        switch (Player_GetMoveType(client)) {
            case MovePlayerType_AfterDeath: {
                bool isMovePlayerAfterDeath = Player_IsMoveFlagEnabled(player, MOVE_PLAYER_FLAG_AFTER_DEATH);

                Menu_FormatPlayerItem(item, sizeof(item), player, isMovePlayerAfterDeath);
            }

            case MovePlayerType_AfterRoundEnd: {
                bool isMovePlayerAfterRoundEnd = Player_IsMoveFlagEnabled(player, MOVE_PLAYER_FLAG_ROUND_END);

                Menu_FormatPlayerItem(item, sizeof(item), player, isMovePlayerAfterRoundEnd);
            }

            default: {
                Format(item, sizeof(item), MENU_PLAYER_ITEM, player);
            }
        }

        menu.AddItem(userIdStr, item);
    }

    delete players;
}

void Menu_FormatPlayerItem(char[] item, int itemMaxLen, int player, bool condition) {
    if (condition) {
        Format(item, itemMaxLen, MENU_PLAYER_ITEM_ENABLED, player);
    } else {
        Format(item, itemMaxLen, MENU_PLAYER_ITEM_DISABLED, player);
    }
}
