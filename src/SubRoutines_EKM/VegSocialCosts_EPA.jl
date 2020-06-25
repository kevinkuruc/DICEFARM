function VegSocialCosts_EPA(Diets, Intensities, discounts)
	DICEFARM = create_dice_farm()
	set_intensities(DICEFARM, Intensities)
	run(DICEFARM)
	BaseWelfare = DICEFARM[:welfare, :UTILITY]
	BaseCons    = 1e12*DICEFARM[:neteconomy, :C][TwentyTwenty:end]

	SocialCosts = zeros(length(discounts), 8) # Vegan, Vegetarian; then each of 6 animal products

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

	BeefPulse[6] = OrigBeef[6] + 100000*(Diets[1]) 				
	DairyPulse[6] = OrigDairy[6] + 100000*(Diets[2])
	PoultryPulse[6] = OrigPoultry[6] + 100000*(Diets[3])
	PorkPulse[6] = OrigPork[6]  + 100000*(Diets[4])
	EggsPulse[6] = OrigEggs[6]  + 100000*(Diets[5])
	SheepGoatPulse[6] = OrigSheepGoat[6] + 100000*(Diets[6])

	VeganPulse = create_dice_farm()
	set_intensities(VeganPulse, Intensities)
	set_param!(VeganPulse, :farm, :Beef, BeefPulse)
	set_param!(VeganPulse, :farm, :Dairy, DairyPulse)
	set_param!(VeganPulse, :farm, :Pork, PorkPulse)
	set_param!(VeganPulse, :farm, :Poultry, PoultryPulse)
	set_param!(VeganPulse, :farm, :Eggs, EggsPulse)
	set_param!(VeganPulse, :farm, :SheepGoat, SheepGoatPulse)
	run(VeganPulse)
	VeganCons  = 1e12*VeganPulse[:neteconomy, :C][TwentyTwenty:end]

	for (i, d) in enumerate(discounts)
		SocialCosts[i,1] = 1e-5*EPADamages(VeganCons, BaseCons, d)
	end

	#------- Vegetarian Pulse -----------#
	BeefPulse = copy(OrigBeef)
	PoultryPulse = copy(OrigPoultry)	
	PorkPulse = copy(OrigPork)
	SheepGoatPulse = copy(OrigSheepGoat)

	BeefPulse[6] = OrigBeef[6] + 100000*(Diets[1]) 				#Add pulse to year 2020
	PoultryPulse[6] = OrigPoultry[6] + 100000*(Diets[3])
	PorkPulse[6] = OrigPork[6]  + 100000*(Diets[4])
	SheepGoatPulse[6] = OrigSheepGoat[6] + 100000*(Diets[6])

	VegetarianPulse = create_dice_farm()
	set_intensities(VegetarianPulse, Intensities)
	set_param!(VegetarianPulse, :farm, :Beef, BeefPulse)
	set_param!(VegetarianPulse, :farm, :Poultry, PoultryPulse)
	set_param!(VegetarianPulse, :farm, :Pork, PorkPulse)
	set_param!(VegetarianPulse, :farm, :SheepGoat, SheepGoatPulse)
	run(VegetarianPulse)
	VegetarianCons  = 1e12*VegetarianPulse[:neteconomy, :C][TwentyTwenty:end]

	for (i, d) in enumerate(discounts)
		SocialCosts[i,2] = 1e-5*EPADamages(VegetarianCons, BaseCons, d)
	end

	#-------- Now By Animal Product ---------#
	Meats = [:Beef, :Dairy, :Poultry, :Pork,  :Eggs, :SheepGoat]
	Origs = [OrigBeef, OrigDairy, OrigPoultry, OrigPork, OrigEggs, OrigSheepGoat]
	j = collect(1:1:length(Meats))
	for (meat, O, j) in zip(Meats, Origs, j)
		tempModel = create_dice_farm();
		set_intensities(tempModel, Intensities)
		Pulse = copy(O)
		Pulse[6] = Pulse[6] + 2000.0 #add 2000 kg of protein (or 2000000 grams)
		set_param!(tempModel, :farm, meat, Pulse)
		run(tempModel)
		tempCons = 1e12*tempModel[:neteconomy, :C][TwentyTwenty:end]
			for (i,d) in enumerate(discounts)
			SocialCosts[i, j+2] = 1e-5*EPADamages(tempCons, BaseCons, d)
			end  
	end


	Diets = ["Vegan", "Vegetarian", "Beef", "Dairy", "Poultry", "Pork", "Eggs", "Sheep/Goat"]

return SocialCosts
end