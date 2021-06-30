#if defined _menu_included
    #endinput
#endif
#define _menu_included

typedef MenuBuilder = function void (int client, Menu menu);

const int TEXT_BUFFER_MAX_SIZE = 1024;
const int MENU_ITEM_INFO_MAX_SIZE = 64;

char TEAM_MANAGER[] = "Team manager";
char MOVE_PLAYER[] = "Move player";
char IMMEDIATELY[] = "Immediately";
char AFTER_DEATH[] = "After death";
char TO_SPECTATORS[] = "To spectators";
char SWAP_TEAMS[] = "Swap teams";
char SCRAMBLE_TEAMS[] = "Scramble teams";
char BALANCE_TEAMS[] = "Balance teams";
char MOVE_EXCESS_PLAYERS_TO_SPECTATORS[] = "Move excess players to spectators";
char DISTRIBUTE_EXCESS_PLAYERS[] = "Distribute excess players";
char SELECT_PLAYER[] = "Select a player";
