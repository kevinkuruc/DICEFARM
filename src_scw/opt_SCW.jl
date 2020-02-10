function veg_outcome(Veg, SufferingEquiv=1.0)
	m = create_dice_fund()
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :BeefEquiv, SufferingEquiv)
	set_param!(m, :farm, :MeatReduc, Veg)
	run(m)
	return m[:welfare, :UTILITY]
end

function ByAnimal_Outcome(B, C, P, Suffering=1.0)
	Orig = create_dice_farm()
	run(Orig)
	OBeef 	= copy(Orig[:farm, :Beef])
	OPoultry= copy(Orig[:farm, :Poultry])
	OPork 	= copy(Orig[:farm, :Pork])
	OBeef[6] = B
	OPoultry[6] = C
	OPork[6]	= P
	New 	= create_dice_farm()
	set_param!(New, :farm, Beef, OBeef)
	set_param!(New, :farm, Poultry, OPoultry)
	set_param!(New, :farm, Pork, OPork)
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :BeefEquiv, SufferingEquiv)
	run(New)
	return m[:welfare, :UTILITY]
end