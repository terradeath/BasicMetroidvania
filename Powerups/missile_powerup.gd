extends Powerup

func pickup():
	super()
	if PlayerStats.max_missiles == 0:
		PlayerStats.max_missiles = 6
		PlayerStats.missiles = PlayerStats.max_missiles
	else:
		PlayerStats.max_missiles += 2
		PlayerStats.missiles += 3
