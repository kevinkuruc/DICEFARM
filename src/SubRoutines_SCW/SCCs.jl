
##Base SCC
DICEFARM = create_AnimalWelfare()
run(DICEFARM)
BaseWelfare = DICEFARM[:welfare, :UTILITY]
MargCons 	= create_AnimalWelfare()
update_param!(MargCons, :CEQ, 1e-9)  #dropping C by 1000 globally
run(MargCons)
MargConsWelfare = MargCons[:welfare, :UTILITY]
SCNumeraire 	= BaseWelfare - MargConsWelfare

MargCO2 		= create_AnimalWelfare()
update_param!(MargCO2, :Co2Pulse, 1.)
run(MargCO2)
Base_SCC 		= 1e-6*(BaseWelfare - MargCO2[:welfare, :UTILITY])/SCNumeraire #Numerator in Billions, Denom in thousands... so 1e-6 gets you to dollars per ton
println("Baseline SCC is $Base_SCC")

## SCC with Stern discount
discount = .000001
DICEFARM = create_AnimalWelfare()
update_param!(DICEFARM, :rho, discount)
run(DICEFARM)
println("Ran once")
BaseWelfare = DICEFARM[:welfare, :UTILITY]
MargCons 	= create_AnimalWelfare()
update_param!(MargCons, :rho, discount)
update_param!(MargCons, :CEQ, 1e-9)  #dropping C by 1000 globally
run(MargCons)
MargConsWelfare = MargCons[:welfare, :UTILITY]
SCNumeraire 	= BaseWelfare - MargConsWelfare

MargCO2 		= create_AnimalWelfare()
update_param!(MargCO2, :rho, discount)
update_param!(MargCO2, :Co2Pulse, 1.)
run(MargCO2)
SCC_Stern 		= 1e-6*(BaseWelfare - MargCO2[:welfare, :UTILITY])/SCNumeraire #Numerator in Billions, Denom in thousands... so 1e-6 gets you to dollars per ton
println("Stern SCC is $SCC_Stern")

##Damage Function on Growth
dam_gama = .000011 #.0014
DICEFARM = create_AnimalWelfare()
update_param!(DICEFARM, :dam_gama, dam_gama)
run(DICEFARM)
println("Ran once")
BaseWelfare = DICEFARM[:welfare, :UTILITY]
MargCons 	= create_AnimalWelfare()
update_param!(MargCons, :dam_gama, dam_gama)
update_param!(MargCons, :CEQ, 1e-9)  #dropping C by 1000 globally
run(MargCons)
MargConsWelfare = MargCons[:welfare, :UTILITY]
SCNumeraire 	= BaseWelfare - MargConsWelfare

MargCO2 		= create_AnimalWelfare()
update_param!(MargCO2, :dam_gama, dam_gama)
update_param!(MargCO2, :Co2Pulse, 1.)
run(MargCO2)
SCC_GrowthDam 		= 1e-6*(BaseWelfare - MargCO2[:welfare, :UTILITY])/SCNumeraire #Numerator in Billions, Denom in thousands... so 1e-6 gets you to dollars per ton
println("Growth Damage is $SCC_GrowthDam")


##Both discount and damages
DICEFARM = create_AnimalWelfare()
update_param!(DICEFARM, :dam_gama, dam_gama)
update_param!(DICEFARM, :rho, discount)
run(DICEFARM)
println("Ran once")
BaseWelfare = DICEFARM[:welfare, :UTILITY]
MargCons 	= create_AnimalWelfare()
update_param!(MargCons, :dam_gama, dam_gama)
update_param!(MargCons, :rho, discount)
update_param!(MargCons, :CEQ, 1e-9)  #dropping C by 1000 globally
run(MargCons)
MargConsWelfare = MargCons[:welfare, :UTILITY]
SCNumeraire 	= BaseWelfare - MargConsWelfare

MargCO2 		= create_AnimalWelfare()
update_param!(MargCO2, :dam_gama, dam_gama)
update_param!(MargCO2, :rho, discount)
update_param!(MargCO2, :Co2Pulse, 1.)
run(MargCO2)
SCC_GrowthDam 		= 1e-6*(BaseWelfare - MargCO2[:welfare, :UTILITY])/SCNumeraire #Numerator in Billions, Denom in thousands... so 1e-6 gets you to dollars per ton
println("Growth Damage + Stern $SCC_GrowthDam")