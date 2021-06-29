#include <menu>
#include <player>

void CreateTeamManagerMenu(int client, MenuHandler handler) {
    CreateCommonMenu(client, TEAM_MANAGER, MenuBuilder_TeamManager, handler);
}

void CreateMovePlayerMenu(int client, MenuHandler handler) {
    CreateCommonMenu(client, MOVE_PLAYER, MenuBuilder_MovePlayer, handler);
}

void CreateBalanceTeamsMenu(int client, MenuHandler handler) {
    CreateCommonMenu(client, BALANCE_TEAMS, MenuBuilder_BalanceTeams, handler);
}

void CreatePlayersMenu(int client, MenuHandler handler) {
    CreateCommonMenu(client, SELECT_PLAYER, MenuBuilder_Players, handler);
}

void CreateCommonMenu(int client, const char[] titlePhrase, MenuBuilder builder, MenuHandler handler) {
    Menu menu = new Menu(handler);

    menu.SetTitle("%T", titlePhrase, client);

    Call_StartFunction(INVALID_HANDLE, builder);
    Call_PushCell(client);
    Call_PushCell(menu);
    Call_Finish();

    menu.Display(client, MENU_TIME_FOREVER);
}

void MenuBuilder_TeamManager(int client, Menu menu) {
    AddFormattedItem(menu, MOVE_PLAYER, client);
    AddFormattedItem(menu, SWAP_TEAMS, client);
    AddFormattedItem(menu, SCRAMBLE_TEAMS, client);
    AddFormattedItem(menu, BALANCE_TEAMS, client);
}

void MenuBuilder_MovePlayer(int client, Menu menu) {
    AddFormattedItem(menu, IMMEDIATELY, client);
    AddFormattedItem(menu, AFTER_DEATH, client);
    AddFormattedItem(menu, TO_SPECTATORS, client);
}

void MenuBuilder_BalanceTeams(int client, Menu menu) {
    AddFormattedItem(menu, MOVE_EXCESS_PLAYERS_TO_SPECTATORS, client);
    AddFormattedItem(menu, DISTRIBUTE_EXCESS_PLAYERS, client);
}

void MenuBuilder_Players(int client, Menu menu) {
    AddPlayersToMenu(menu, client);
}

bool IsMenuItemSelected(Menu menu, MenuAction action) {
    if (action == MenuAction_End) {
        delete menu;

        return false;
    }

    return action == MenuAction_Select;
}

void AddFormattedItem(Menu menu, const char[] phrase, int client) {
    char buffer[TEXT_BUFFER_MAX_SIZE];

    Format(buffer, sizeof(buffer), "%T", phrase, client);

    menu.AddItem(phrase, buffer);
}

void AddPlayersToMenu(Menu menu, int client) {
    ArrayList players = GetPlayers(PlayerPredicate_ActivePlayers);

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);
        int userId = GetClientUserId(player);
        char userIdStr[TEXT_BUFFER_MAX_SIZE];
        char playerName[TEXT_BUFFER_MAX_SIZE];

        IntToString(userId, userIdStr, sizeof(userIdStr));

        if (IsMovePlayerAfterDeath(player)) {
            Format(playerName, sizeof(playerName), "%t", "Player item marked", player, AFTER_DEATH, client);
        } else {
            Format(playerName, sizeof(playerName), "%t", "Player item not marked", player);
        }

        menu.AddItem(userIdStr, playerName);
    }

    delete players;
}
