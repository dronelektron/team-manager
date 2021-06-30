#if defined _team_included
    #endinput
#endif
#define _team_included

enum MoveExcessPlayerType {
    MoveExcessPlayerType_ToSpectators = 0,
    MoveExcessPlayerType_Distribute
};

const int TEAM_SPECTATOR = 1;
const int TEAM_ALLIES = 2;
const int TEAM_AXIS = 3;

const int UNBALANCE_LIMIT = 1;
