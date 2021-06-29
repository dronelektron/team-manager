#if defined _player_included
    #endinput
#endif
#define _player_included


enum MovePlayerType {
    MovePlayerType_Immediately = 0,
    MovePlayerType_AfterDeath,
    MovePlayerType_ToSpectators
};

typedef PlayerPredicate = function bool (int client);
