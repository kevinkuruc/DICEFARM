function VegSocialCosts(Intensities, Diets)
	include("DICEFARM_Annual.jl")
	DICEFARM = create_dice_farm()
	set_intensities(DICEFARM, Intensities)
	#set_param!(DICEFARM, :welfare, :rho, .001)
	run(DICEFARM)
	BaseWelfare = DICEFARM[:welfare, :UTILITY]
	MargCons 	= create_dice_farm()
	set_intensities(MargCons, Intensities)
	#set_param!(MargCons, :welfare, :rho, .001)
	set_param!(MargCons, :neteconomy, :CEQ, 1e-9)  #dropping C by 1000 total
	run(MargCons)
	MargConsWelfare = MargCons[:welfare, :UTILITY]
	SCNumeraire 	= BaseWelfare - MargConsWelfare

	SocialCosts = zeros(8) # Vegan, Vegetarian; then each of 6 animal products

	# ----- Need original amount consumed -------- #
	OrigBeef = DICEFARM[:farm, :Beef]
	OrigDairy = DICEFARM[:farm, :Dairy]
	OrigPork = DICEFARM[:farm, :Pork]
	OrigPoultry = DICEFARM[:farm, :Poultry]
	OrigEggs = DICEFARM[:farm, :Eggs]
	OrigSheepGoat = DICEFARM[:farm, :SheepGoat]

	# ------ Vegan Pulse ------------------- #
	BeefPulse = copy(OrigBeef)
	DairyPulse = copy(OrigDairy)
	PorkPulse = copy(OrigPork)
	PoultryPulse = copy(OrigPoultry)
	EggsPulse = copy(OrigEggs)
	SheepGoatPulse = copy(OrigSheepGoat)

	BeefPulse[6] = OrigBeef[6] + 1000*(Diets[1]) 				#Add pulse to year 2020
	DairyPulse[6] = OrigDairy[6] + 1000*(Diets[2])
	PorkPulse[6] = OrigPork[6]  + 1000*(Diets[3])
	PoultryPulse[6] = OrigPoultry[6] + 1000*(Diets[4])
	EggsPulse[6] = OrigEggs[6]  + 1000*(Diets[5])
	SheepGoatPulse[6] = OrigSheepGoat[6] + 1000*(Diets[6])

	VeganPulse = create_dice_farm()
	set_intensities(VeganPulse, Intensities)
	#set_param!(VeganPulse, :welfare, :rho, .001)
	set_param!(VeganPulse, :farm, :Beef, BeefPulse)
	set_param!(VeganPulse, :farm, :Dairy, DairyPulse)
	set_param!(VeganPulse, :farm, :Poultry, PoultryPulse)
	set_param!(VeganPulse, :farm, :Pork, PorkPulse)
	set_param!(VeganPulse, :farm, :Eggs, EggsPulse)
	set_param!(VeganPulse, :farm, :SheepGoat, SheepGoatPulse)
	run(VeganPulse)

	VegWelfare = VeganPulse[:welfare, :UTILITY]
	SocialCosts[1] = (BaseWelfare - VegWelfare)/SCNumeraire

	#------- Vegetarian Pulse -----------#
	BeefPulse = copy(OrigBeef)
	PorkPulse = copy(OrigPork)
	PoultryPulse = copy(OrigPoultry)
	SheepGoatPulse = copy(OrigSheepGoat)

	BeefPulse[6] = OrigBeef[6] + 1000*(Diets[1]) 				#Add pulse to year 2020
	PorkPulse[6] = OrigPork[6]  + 1000*(Diets[3])
	PoultryPulse[6] = OrigPoultry[6] + 1000*(Diets[4])
	SheepGoatPulse[6] = OrigSheepGoat[6] + 1000*(Diets[6])

	VegetarianPulse = create_dice_farm()
	set_intensities(VegetarianPulse, Intensities)
	#set_param!(VegetarianPulse, :welfare, :rho, .001)
	set_param!(VegetarianPulse, :farm, :Beef, BeefPulse)
	set_param!(VegetarianPulse, :farm, :Poultry, PoultryPulse)
	set_param!(VegetarianPulse, :farm, :Pork, PorkPulse)
	set_param!(VegetarianPulse, :farm, :SheepGoat, SheepGoatPulse)
	run(VegetarianPulse)

	Veg2Welfare = VegetarianPulse[:welfare, :UTILITY]
	SocialCosts[2] = (BaseWelfare - Veg2Welfare)/SCNumeraire

	#-------- Now By Animal Product ---------#
	Meats = [:Beef, :Dairy, :Pork, :Poultry, :Eggs, :SheepGoat]
	Origs = [OrigBeef, OrigDairy, OrigPork, OrigPoultry, OrigEggs, OrigSheepGoat]
	SCs   = zeros(length(Meats))
	i = collect(1:1:length(Meats))
	for (meat, O, i) in zip(Meats, Origs, i)
		tempModel = create_dice_farm();
		set_intensities(tempModel, Intensities)
		#set_param!(tempModel, :welfare, :rho, .001)
		Pulse = copy(O)
		Pulse[6] = Pulse[6] + 20.0 #add 20 kg of protein (or 20000 grams)
		set_param!(tempModel, :farm, meat, Pulse)
		run(tempModel)
		W = tempModel[:welfare, :UTILITY]
		SocialCosts[i+2] = (BaseWelfare - W)/SCNumeraire 
	end


	Diets = ["Vegan", "Vegetarian", "Beef", "Dairy", "Poultry", "Pork", "Eggs", "Sheep/Goat"]

return [Diets SocialCosts]
end