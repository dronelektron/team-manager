#if defined _team_included
 #endinput
#endif
#define _team_included

#define TEAM_SPECTATOR 1
#define TEAM_ALLIES 2
#define TEAM_AXIS 3

#define UNBALANCE_LIMIT 1

enum MoveExcessPlayerType {
    MoveExcessPlayerType_ToSpectators = 0,
    MoveExcessPlayerType_Distribute
};
