# Team manager

Allows you to perform various operations on teams:

* Move player
	* Immediately
	* After death
	* After round end
	* To spectators
* Swap teams
* Scramble teams
* Balance teams
	* Move excess players to spectators
	* Distribute excess players

### Supported Games

* Day of Defeat: Source

### Installation

* Download latest [release](https://github.com/dronelektron/team-manager/releases) (compiled for SourceMod 1.10)
* Extract "plugins" and "translations" folders to "addons/sourcemod" folder of your server

### Console Commands

* sm_tm_move_player &lt;#userid|name&gt; &lt;type&gt; - Move player:
	* type 0: to opposing team
	* type 1: after death
	* type 2: after round end
	* type 3: to spectators
* sm_tm_swap_teams - Swap teams
* sm_tm_scramble_teams - Scramble teams
* sm_tm_balance_teams  &lt;type&gt; - Balance teams:
	* type 0: move excess players to spectators
	* type 1: distribute excess players

### Compiling

Make sure, that you installed "spcomp" and you have it in your "PATH" variable.

* Clone this repository
* Open terminal with path pointing to "scripting" folder of this plugin
* Type the following: `spcomp team-manager.sp modules/*.sp -i include -o ../plugins/team-manager.smx`
