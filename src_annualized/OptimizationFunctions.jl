using NLopt

include("DICEFarm.jl")
T=100

MeatBAU = 1000*ones(T)  #Need to read these in
MIUBAU  = .5*ones(T)    #Need to read these in

function SocialWelfare(Mitigation=MIUBAU, Meat=MeatBAU)
	m = getDICEFARM()
	MIU = [MIUBAU[1]; Mitigation[2:T]]   #Ensure optimization problem can't change the past
	Meat = [Meat[1]; Meat[2:T]]
	set_param!(m, :co2emissions, :MIU, MIU)
	set_param!(m, :farm, :Meat, Meat)
	run(m)
	U = m[:welfare, :UTILITY]
end

function OptimizeMitigation(Meat=MeatBAU)  #Extend this so you can feed in different meat assumptions
	initguess = .75*ones(T) 
	lowbound  = 0*ones(T)
	upbound   = 1.2*ones(T) #Nordhaus allows for 20% capture

	opt = Opt(:NLSBPLX, T)
	lower_bounds!(opt, lowbound)
	upper_bounds!(opt, upbound)
	ftol_rel!(opt, 1e-10)
	maxtime!(opt, 400)
	max_objective(opt, (x,grad)-> SocialWelfare(x, Meat))

	(Welfare, minx, ret) = optimize(opt, initguess)
	OptMIU   = [MIUBAU[1]; minx[2:T]]

	OptModel = getDICEFARM()
	set_param!(OptModel, :co2emissions, :MIU, OptMIU)
	set_param!(OptModel, :farm, :Meat, Meat)
	run(OptModel)
	return(OptModel)
end

function OptimizeMeat(MIU=MIUBAU)  #Extend this so you can feed in different meat assumptions
	initguess = 10000ones(T)  #dont let it opt over 2015
	lowbound  = 0*ones(T)


	opt = Opt(:NLSBPLX, T)
	lower_bounds!(opt, lowbound)
	ftol_rel!(opt, 1e-10)
	maxtime!(opt, 400)
	max_objective(opt, (x,grad)-> SocialWelfare(MIU, x))

	(Welfare, minx, ret) = optimize(opt, initguess)
	OptMeat  = [MeatBAU[1]; minx[2:T]]

	OptModel = getDICEFARM()
	set_param!(OptModel, :co2emissions, :MIU, MIU)
	set_param!(OptModel, :farm, :Meat, OptMeat)
	run(OptModel)
	return(OptModel)
end

##COME BACK HERE... GETTING THIS THING IN LONG FORM IS UGLY
function OptimizeBoth()  #Extend this so you can feed in different meat assumptions
	#This is a little clunky because NLopt takes a 1-D vector
	initguess = [.5*ones(T); 10000*ones(T)]
	lowbound  = zeros(2*T)
	upbound   = [1.2*ones(T); Inf*ones(T)]

	opt = Opt(:NLSBPLX, 60)
	lower_bounds!(opt, lowbound)
	ftol_rel!(opt, 1e-10)
	maxtime!(opt, 400)
	max_objective(opt, (x,grad)-> SocialWelfare(MIU, x))

	(Welfare, minx, ret) = optimize(opt, initguess)

	OptModel = getDICEFARM()
	set_param!(OptModel, :co2emissions, :MIU, MIU)
	set_param!(OptModel, :farm, :Meat, x)
	run(OptModel)
	return(OptModel)
end