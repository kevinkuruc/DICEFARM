##########################################################################################
# This Function takes the DICEFARM model and substitutes in new components and parameters
# for the animal welfare analysis in Social Choice and Welfare
##########################################################################################
main_directory = joinpath(dirname(pwd()), "src")
include(joinpath(main_directory, "DICEFARM.jl"))

function create_AnimalWelfare()
m = create_dice_farm()
include(joinpath(main_directory, "components", "AnimalWelfare", "farm_component.jl"))
include(joinpath(main_directory, "components", "AnimalWelfare", "welfare_component.jl"))
replace_comp!(m, factoryfarm, :farm, reconnect=true)
set_param!(m, :farm, :ABeef, .0888) 			#Number of animal-years to produce a kilogram of protein
set_param!(m, :farm, :APork, .0518227)      	#Number of animal-years to produce a kilogram of protein                 
set_param!(m, :farm, :APoultry, 0.5146)			#Number of animal-years to produce a kilogram of protein

replace_comp!(m, animalwelfare, :welfare, reconnect=true)
set_param!(m, :welfare, :thetaB, 1.0)			#Moral Weight on Cows
set_param!(m, :welfare, :thetaC, 1.0)			#Moral Weight on Chickens
set_param!(m, :welfare, :thetaP, 1.0)			#Moral Weight on Pigs
set_param!(m, :welfare, :CowEquiv, 1.0)			#Human-Income-Equivalent Utility ($ per day)
set_param!(m, :welfare, :PigEquiv, 1.0)			#Human-Income-Equivalent Utility ($ per day)
set_param!(m, :welfare, :ChickenEquiv, 1.0)		#Human-Income-Equivalent Utility ($ per day)

connect_param!(m, :welfare, :Cows, :farm, :Cows)
connect_param!(m, :welfare, :Pigs, :farm, :Pigs)
connect_param!(m, :welfare, :Chickens, :farm, :Chickens)
set_param!(m, :grosseconomy, :dk, :.0819)
return m
end
