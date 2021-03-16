function VegSocialCosts(Diets, Intensities, discount=.015)
	DICEFARM = create_dice_farm()
	update_intensities(DICEFARM, Intensities)
	update_param!(DICEFARM, :rho, discount)
	run(DICEFARM)
	BaseWelfare = DICEFARM[:welfare, :UTILITY]
	MargCons 	= create_dice_farm()
	update_intensities(MargCons, Intensities)
	update_param!(MargCons, :rho, discount)
	update_param!(MargCons, :CEQ, 1e-9)  #dropping C by 1000 total
	run(MargCons)
	MargConsWelfare = MargCons[:welfare, :UTILITY]
	SCNumeraire 	= BaseWelfare - MargConsWelfare

	SocialCosts = zeros(8) # Vegan, Vegetarian; then each of 6 animal products

	# ----- Need original amount consumed -------- #
	OrigBeef = DICEFARM[:farm, :Beef]
	OrigDairy = DICEFARM[:farm, :Dairy]
	OrigPoultry = DICEFARM[:farm, :Poultry]
	OrigPork = DICEFARM[:farm, :Pork]
	OrigEggs = DICEFARM[:farm, :Eggs]
	OrigSheepGoat = DICEFARM[:farm, :SheepGoat]

	# ------ Vegan Pulse ------------------- #
	BeefPulse = copy(OrigBeef)
	DairyPulse = copy(OrigDairy)
	PorkPulse = copy(OrigPork)
	PoultryPulse = copy(OrigPoultry)
	EggsPulse = copy(OrigEggs)
	SheepGoatPulse = copy(OrigSheepGoat)

	BeefPulse[6] = OrigBeef[6] + 1000*(Diets[1]) 				
	DairyPulse[6] = OrigDairy[6] + 1000*(Diets[2])
	PoultryPulse[6] = OrigPoultry[6] + 1000*(Diets[3])
	PorkPulse[6] = OrigPork[6]  + 1000*(Diets[4])
	EggsPulse[6] = OrigEggs[6]  + 1000*(Diets[5])
	SheepGoatPulse[6] = OrigSheepGoat[6] + 1000*(Diets[6])

	VeganPulse = create_dice_farm()
	update_intensities(VeganPulse, Intensities)
	update_param!(VeganPulse, :rho, discount)
	update_param!(VeganPulse, :Beef, BeefPulse)
	update_param!(VeganPulse, :Dairy, DairyPulse)
	update_param!(VeganPulse, :Poultry, PoultryPulse)
	update_param!(VeganPulse, :Pork, PorkPulse)
	update_param!(VeganPulse, :Eggs, EggsPulse)
	update_param!(VeganPulse, :SheepGoat, SheepGoatPulse)
	run(VeganPulse)

	VegWelfare = VeganPulse[:welfare, :UTILITY]
	SocialCosts[1] = (BaseWelfare - VegWelfare)/SCNumeraire

	#------- Vegetarian Pulse -----------#
	BeefPulse = copy(OrigBeef)
	PorkPulse = copy(OrigPork)
	PoultryPulse = copy(OrigPoultry)
	SheepGoatPulse = copy(OrigSheepGoat)

	BeefPulse[6] = OrigBeef[6] + 1000*(Diets[1]) 
	PoultryPulse[6] = OrigPoultry[6] + 1000*(Diets[3])			
	PorkPulse[6] = OrigPork[6]  + 1000*(Diets[4])
	SheepGoatPulse[6] = OrigSheepGoat[6] + 1000*(Diets[6])

	VegetarianPulse = create_dice_farm()
	update_intensities(VegetarianPulse, Intensities)
	update_param!(VegetarianPulse, :rho, discount)
	update_param!(VegetarianPulse, :Beef, BeefPulse)
	update_param!(VegetarianPulse, :Poultry, PoultryPulse)
	update_param!(VegetarianPulse, :Pork, PorkPulse)
	update_param!(VegetarianPulse, :SheepGoat, SheepGoatPulse)
	run(VegetarianPulse)

	Veg2Welfare = VegetarianPulse[:welfare, :UTILITY]
	SocialCosts[2] = (BaseWelfare - Veg2Welfare)/SCNumeraire

	#-------- Now By Animal Product ---------#
	Meats = [:Beef, :Dairy, :Poultry, :Pork, :Eggs, :SheepGoat]
	Origs = [OrigBeef, OrigDairy, OrigPoultry, OrigPork, OrigEggs, OrigSheepGoat]
	SCs   = zeros(length(Meats))
	i = collect(1:1:length(Meats))
	for (meat, O, i) in zip(Meats, Origs, i)
		tempModel = create_dice_farm();
		update_intensities(tempModel, Intensities)
		update_param!(tempModel, :rho, discount)
		Pulse = copy(O)
		Pulse[6] = Pulse[6] + 20000.0 #add 20,000 kg of protein (or 20,000,000 g---then 1000 deflated for C; 1000 more deflated 4 lines down) 
		update_param!(tempModel, meat, Pulse)
		run(tempModel)
		W = tempModel[:welfare, :UTILITY]
		SocialCosts[i+2] = 1e-3*(BaseWelfare - W)/SCNumeraire 
	end


	Diets = ["Vegan", "Vegetarian", "Beef", "Dairy", "Poultry", "Pork", "Eggs", "Sheep/Goat"]

return [Diets SocialCosts]
end
