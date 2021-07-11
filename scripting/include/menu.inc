#if defined _menu_included
    #endinput
#endif
#define _menu_included

const int TEXT_BUFFER_MAX_SIZE = 1024;
const int MENU_ITEM_INFO_MAX_SIZE = 64;

char TEAM_MANAGER[] = "Team manager";
char MOVE_PLAYER[] = "Move player";
char IMMEDIATELY[] = "Immediately";
char AFTER_DEATH[] = "After death";
char AFTER_ROUND_END[] = "After round end";
char TO_SPECTATORS[] = "To spectators";
char SWAP_TEAMS[] = "Swap teams";
char SCRAMBLE_TEAMS[] = "Scramble teams";
char BALANCE_TEAMS[] = "Balance teams";
char MOVE_EXCESS_PLAYERS_TO_SPECTATORS[] = "Move excess players to spectators";
char DISTRIBUTE_EXCESS_PLAYERS[] = "Distribute excess players";
char SELECT_PLAYER[] = "Select a player";

char MENU_PLAYER_ITEM[] = "%N";
char MENU_PLAYER_ITEM_ENABLED[] = "[x] %N";
char MENU_PLAYER_ITEM_DISABLED[] = "[_] %N";
