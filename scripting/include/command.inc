#if defined _command_included
    #endinput
#endif
#define _command_included

const int COMMAND_ARG_MAX_LENGTH = 256;

char COMMAND_USAGE_PREFIX[] = "[SM] Usage: ";
char COMMAND_DESCRIPTION_MOVE_PLAYER[] = "sm_tm_move_player <#userid|name> <type>";
char COMMAND_DESCRIPTION_SWAP_TEAMS[] = "sm_tm_swap_teams";
char COMMAND_DESCRIPTION_SCRAMBLE_TEAMS[] = "sm_tm_scramble_teams";
char COMMAND_DESCRIPTION_BALANCE_TEAMS[] = "sm_tm_balance_teams <type>";
