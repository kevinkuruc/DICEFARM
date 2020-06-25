using Roots, NLsolve
include("AnimalWelfareModel.jl")

## First need to calibrate prices (via relative and total consumption of meat in our 2020 period)
#Parameters nested within CES aggregator of meats
#epsilon = -1.22   #elasticity of substitution parameter
epsilon  = 1-(1/1.22)
theta_c = .43  #coefficient within CES on chicken
theta_b = .50
theta_p = .07

# Total utility parameters
eta = 1.45     	  # As in Nordhaus
xi  = 3.17 	  # From aggregate meat consumption growth vs normal consumption growth
alpha = .025 	  # linear coefficient on meat part of utility function

#### Now using aggregate data, estimate P (aggregate price)
temp = create_AnimalWelfare()
run(temp)
TwentyTwenty = 2020-1764
TotC 	 	= temp[:neteconomy, :C][TwentyTwenty]
Beef     	= temp[:farm, :Beef][6]
Pork		= temp[:farm, :Pork][6]
Poultry 	= temp[:farm, :Poultry][6]
Pop 		= 1e6*temp[:welfare, :l][6]
#All per cap from now on
Ytilde		= 1e12*TotC/Pop 	#Per capita total consumption to split between meat and other
PerCapChicken 	= Poultry/Pop
PerCapBeef    	= Beef/Pop
PerCapPork 		= Pork/Pop
#rho 			= -1.22 #(epsilon-1)/epsilon
m 				= ((theta_c*PerCapChicken^epsilon + theta_b*PerCapBeef^epsilon + theta_p*PerCapPork^epsilon)^(1/epsilon)) #Per cap CES of Meat

### Non Linear Solver C
f(x) = alpha*m^(-xi+1)*x^eta + x - Ytilde
c = find_zero(f, (0, 11200), Bisection())

## Write my own solver for individual Ps
MeatExpenditure = Ytilde - c
expen = 0
global PBeef = 50

while expen < MeatExpenditure
    global PBeef = PBeef + .5
    global PPoultry= PBeef*(theta_c/theta_b)*((PerCapChicken/PerCapBeef)^(epsilon-1))
    global PPork = PBeef*(theta_p/theta_b)*((PerCapPork/PerCapBeef)^(epsilon-1))
    global expen   = PerCapBeef*PBeef + PerCapChicken*PPoultry + PerCapPork*PPork
end

function create_AnimalWelfareOpt()
m = create_AnimalWelfare()
include(joinpath("components", "AnimalWelfare", "OptimalPolicy", "neteconomy_component.jl"))
include(joinpath("components", "AnimalWelfare", "OptimalPolicy", "farm_component.jl"))
include(joinpath("components", "AnimalWelfare", "OptimalPolicy", "welfare_component.jl"))
replace_comp!(m, farmforpolicy, :farm, reconnect=true)
set_param!(m, :farm, :theta_b, theta_b)
set_param!(m, :farm, :theta_c, theta_c)
set_param!(m, :farm, :theta_p, theta_p)
set_param!(m, :farm, :epsilon, epsilon)
set_param!(m, :farm, :PBeef, PBeef)
set_param!(m, :farm, :PPoultry, PPoultry)
set_param!(m, :farm, :PPork, PPork)
set_param!(m, :farm, :l, temp[:welfare, :l])
set_param!(m, :farm, :BeefReduc, 0.)
set_param!(m, :farm, :PorkReduc, 0.)
set_param!(m, :farm, :PoultryReduc, 0.)

replace_comp!(m, neteconomyforpolicy, :neteconomy, reconnect=true)
connect_param!(m, :neteconomy, :MeatExp, :farm, :MeatCost)

replace_comp!(m, welfareforpolicy, :welfare, reconnect=true)
set_param!(m, :welfare, :elasmeat, xi)
set_param!(m, :welfare, :alphameat, alpha)

connect_param!(m, :welfare, :MeatPC, :farm, :MeatPC)
return m
end

function veg_outcome(Veg, SufferingEquiv=1.0, alphaM=alpha)
	m = create_AnimalWelfareOpt()
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :ChickenEquiv, SufferingEquiv)
	set_param!(m, :welfare, :alphameat, alphaM)
	set_param!(m, :farm, :MeatReduc, Veg)	
	run(m)
	return m[:welfare, :UTILITY]
end

function ByAnimals_outcome(x::Array{Float64, 1}, SufferingEquiv=1.0)
	m 	= create_AnimalWelfareOpt()
	set_param!(m, :farm, :BeefReduc, x[1])
	set_param!(m, :farm, :PoultryReduc, x[2])
	set_param!(m, :farm, :PorkReduc, x[3])
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :ChickenEquiv, SufferingEquiv)
	run(m)
	return m[:welfare, :UTILITY]
end