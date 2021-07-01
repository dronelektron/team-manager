#if defined _player_included
    #endinput
#endif
#define _player_included

enum MovePlayerType {
    MovePlayerType_Immediately = 0,
    MovePlayerType_AfterDeath,
    MovePlayerType_RoundEnd,
    MovePlayerType_ToSpectators
};

const int MOVE_PLAYER_FLAG_AFTER_DEATH = (1 << 0);
const int MOVE_PLAYER_FLAG_ROUND_END = (1 << 1);

typedef PlayerPredicate = function bool (int client);
