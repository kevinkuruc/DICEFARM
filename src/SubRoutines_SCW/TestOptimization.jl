Outcomes = zeros(7,4)

function veg_outcome(Veg, SufferingEquiv=1.0, alphaM = alpha)
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

function optveg(x, grad)
	if length(grad)>0
	grad[1] = 1000
	end
    result = veg_outcome(x[1])
	return result
end
opt = Opt(:LN_SBPLX, 1)
opt.lower_bounds=[-1.0]
opt.upper_bounds=[.9999999999]
init = [.5]
opt.xtol_rel = 1e-3
opt.max_objective = optveg
sol = optimize(opt, init)[2]
Outcomes[1, 1] = sol[1]

function optanimals(x, grad)
	if length(grad)>0
	grad[1] = 1
	end
	result = ByAnimals_outcome(x)
	return result
end
opt = Opt(:LN_SBPLX, 3)
opt.lower_bounds=-1*ones(3)
opt.upper_bounds=ones(3)
init = .75*ones(3)
opt.xtol_rel = 1e-3
opt.max_objective = optanimals
sol2 = optimize(opt, init)[2]
Outcomes[1,2] = sol2[1]
Outcomes[1,3] = sol2[2]  
Outcomes[1,4] = sol2[3]

#--- No Externalities ----#
function veg_outcome(Veg, SufferingEquiv=1.0, alphaM = alpha)
	m = create_AnimalWelfareOpt()
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :ChickenEquiv, SufferingEquiv)
	set_param!(m, :welfare, :alphameat, alphaM)
	set_param!(m, :farm, :MeatReduc, Veg)
	set_param!(m, :farm, :sigmaBeefCo2, 0)
	set_param!(m, :farm, :sigmaBeefMeth, 0)
	set_param!(m, :farm, :sigmaBeefN2o, 0)
	set_param!(m, :farm, :sigmaPoultryCo2, 0)
	set_param!(m, :farm, :sigmaPoultryMeth, 0)
	set_param!(m, :farm, :sigmaPoultryN2o, 0)
	set_param!(m, :farm, :sigmaPorkCo2, 0)
	set_param!(m, :farm, :sigmaPorkMeth, 0)
	set_param!(m, :farm, :sigmaPorkN2o, 0)
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
	set_param!(m, :farm, :sigmaBeefCo2, 0)
	set_param!(m, :farm, :sigmaBeefMeth, 0)
	set_param!(m, :farm, :sigmaBeefN2o, 0)
	set_param!(m, :farm, :sigmaPoultryCo2, 0)
	set_param!(m, :farm, :sigmaPoultryMeth, 0)
	set_param!(m, :farm, :sigmaPoultryN2o, 0)
	set_param!(m, :farm, :sigmaPorkCo2, 0)
	set_param!(m, :farm, :sigmaPorkMeth, 0)
	set_param!(m, :farm, :sigmaPorkN2o, 0)
	run(m)
	return m[:welfare, :UTILITY]
end

function optveg(x, grad)
	if length(grad)>0
	grad[1] = 1000
	end
    result = veg_outcome(x[1], 1.9, 0.025)
	return result
end
opt = Opt(:LN_SBPLX, 1)
opt.lower_bounds=[-1.0]
opt.upper_bounds=[.9999999999]
init = [.5]
opt.xtol_rel = 1e-3
opt.max_objective = optveg
sol = optimize(opt, init)[2]
Outcomes[2, 1] = sol[1]

function optanimals(x, grad)
	if length(grad)>0
	grad[1] = 1
	end
	result = ByAnimals_outcome(x, 1.9)
	return result
end
opt = Opt(:LN_SBPLX, 3)
opt.lower_bounds=-1*ones(3)
opt.upper_bounds=ones(3)
init = .75*ones(3)
opt.xtol_rel = 1e-3
opt.max_objective = optanimals
sol2 = optimize(opt, init)[2]
Outcomes[2,2] = sol2[1]
Outcomes[2,3] = sol2[2]  
Outcomes[2,4] = sol2[3]

#--- Only Climate ----#
function veg_outcome(Veg, SufferingEquiv=1.0, alphaM = alpha)
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

function optveg(x, grad)
	if length(grad)>0
	grad[1] = 1000
	end
    result = veg_outcome(x[1], 1.9, 0.025)
	return result
end
opt = Opt(:LN_SBPLX, 1)
opt.lower_bounds=[-1.0]
opt.upper_bounds=[.9999999999]
init = [.5]
opt.xtol_rel = 1e-3
opt.max_objective = optveg
sol = optimize(opt, init)[2]
Outcomes[3, 1] = sol[1]

function optanimals(x, grad)
	if length(grad)>0
	grad[1] = 1
	end
	result = ByAnimals_outcome(x, 1.9)
	return result
end
opt = Opt(:LN_SBPLX, 3)
opt.lower_bounds=-1*ones(3)
opt.upper_bounds=ones(3)
init = .75*ones(3)
opt.xtol_rel = 1e-3
opt.max_objective = optanimals
sol2 = optimize(opt, init)[2]
Outcomes[3,2] = sol2[1]
Outcomes[3,3] = sol2[2]  
Outcomes[3,4] = sol2[3]

#--- 15*climate ----#
function veg_outcome(Veg, SufferingEquiv=1.0, alphaM = alpha)
	m = create_AnimalWelfareOpt()
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :ChickenEquiv, SufferingEquiv)
	set_param!(m, :welfare, :alphameat, alphaM)
	set_param!(m, :farm, :MeatReduc, Veg)
	set_param!(m, :farm, :sigmaBeefCo2, 3*65.1)
	set_param!(m, :farm, :sigmaBeefMeth, 3*6.5)
	set_param!(m, :farm, :sigmaBeefN2o, 3*0.22)
	set_param!(m, :farm, :sigmaPoultryCo2, 3*25.6)
	set_param!(m, :farm, :sigmaPoultryMeth, 3*0.02)
	set_param!(m, :farm, :sigmaPoultryN2o, 3*0.03)
	set_param!(m, :farm, :sigmaPorkCo2, 3*25.1)
	set_param!(m, :farm, :sigmaPorkMeth, 3*.7)
	set_param!(m, :farm, :sigmaPorkN2o, 3*.04)
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
	set_param!(m, :farm, :sigmaBeefCo2, 3*65.1)
	set_param!(m, :farm, :sigmaBeefMeth, 3*6.5)
	set_param!(m, :farm, :sigmaBeefN2o, 3*0.22)
	set_param!(m, :farm, :sigmaPoultryCo2, 3*25.6)
	set_param!(m, :farm, :sigmaPoultryMeth, 3*0.02)
	set_param!(m, :farm, :sigmaPoultryN2o, 3*0.03)
	set_param!(m, :farm, :sigmaPorkCo2, 3*25.1)
	set_param!(m, :farm, :sigmaPorkMeth, 3*.7)
	set_param!(m, :farm, :sigmaPorkN2o, 3*.04)	
	run(m)
	return m[:welfare, :UTILITY]
end

function optveg(x, grad)
	if length(grad)>0
	grad[1] = 1000
	end
    result = veg_outcome(x[1], 1.9, 0.025)
	return result
end
opt = Opt(:LN_SBPLX, 1)
opt.lower_bounds=[-1.0]
opt.upper_bounds=[.9999999999]
init = [.5]
opt.xtol_rel = 1e-3
opt.max_objective = optveg
sol = optimize(opt, init)[2]
Outcomes[4, 1] = sol[1]

function optanimals(x, grad)
	if length(grad)>0
	grad[1] = 1
	end
	result = ByAnimals_outcome(x, 1.9)
	return result
end
opt = Opt(:LN_SBPLX, 3)
opt.lower_bounds=-1*ones(3)
opt.upper_bounds=ones(3)
init = .75*ones(3)
opt.xtol_rel = 1e-3
opt.max_objective = optanimals
sol2 = optimize(opt, init)[2]
Outcomes[4,2] = sol2[1]
Outcomes[4,3] = sol2[2]  
Outcomes[4,4] = sol2[3]


#--- 15* Beef ----#
function veg_outcome(Veg, SufferingEquiv=1.0, alphaM = alpha)
	m = create_AnimalWelfareOpt()
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :ChickenEquiv, SufferingEquiv)
	set_param!(m, :welfare, :alphameat, alphaM)
	set_param!(m, :farm, :MeatReduc, Veg)
	set_param!(m, :farm, :sigmaBeefCo2, 3*65.1)
	set_param!(m, :farm, :sigmaBeefMeth, 3*6.5)
	set_param!(m, :farm, :sigmaBeefN2o, 3*0.22)
	set_param!(m, :farm, :sigmaPoultryCo2, 25.6)
	set_param!(m, :farm, :sigmaPoultryMeth, 0.02)
	set_param!(m, :farm, :sigmaPoultryN2o, 0.03)
	set_param!(m, :farm, :sigmaPorkCo2, 25.1)
	set_param!(m, :farm, :sigmaPorkMeth, .7)
	set_param!(m, :farm, :sigmaPorkN2o, .04)	
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
	set_param!(m, :farm, :sigmaBeefCo2, 3*65.1)
	set_param!(m, :farm, :sigmaBeefMeth, 3*6.5)
	set_param!(m, :farm, :sigmaBeefN2o, 3*0.22)
	set_param!(m, :farm, :sigmaPoultryCo2, 25.6)
	set_param!(m, :farm, :sigmaPoultryMeth, 0.02)
	set_param!(m, :farm, :sigmaPoultryN2o, 0.03)
	set_param!(m, :farm, :sigmaPorkCo2, 25.1)
	set_param!(m, :farm, :sigmaPorkMeth, .7)
	set_param!(m, :farm, :sigmaPorkN2o, .04)	
	run(m)
	return m[:welfare, :UTILITY]
end

function optveg(x, grad)
	if length(grad)>0
	grad[1] = 1000
	end
    result = veg_outcome(x[1], 1.9, 0.025)
	return result
end
opt = Opt(:LN_SBPLX, 1)
opt.lower_bounds=[-1.0]
opt.upper_bounds=[.9999999999]
init = [.5]
opt.xtol_rel = 1e-3
opt.max_objective = optveg
sol = optimize(opt, init)[2]
Outcomes[5, 1] = sol[1]

function optanimals(x, grad)
	if length(grad)>0
	grad[1] = 1
	end
	result = ByAnimals_outcome(x, 1.9)
	return result
end
opt = Opt(:LN_SBPLX, 3)
opt.lower_bounds=-1*ones(3)
opt.upper_bounds=ones(3)
init = .75*ones(3)
opt.xtol_rel = 1e-3
opt.max_objective = optanimals
sol2 = optimize(opt, init)[2]
Outcomes[5,2] = sol2[1]
Outcomes[5,3] = sol2[2]  
Outcomes[5,4] = sol2[3]


#--- rho = .001 & climate = 20* ----#
function veg_outcome(Veg, SufferingEquiv=1.0, alphaM = alpha)
	m = create_AnimalWelfareOpt()
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :ChickenEquiv, SufferingEquiv)
	set_param!(m, :welfare, :alphameat, alphaM)
	set_param!(m, :farm, :MeatReduc, Veg)
	set_param!(m, :welfare, :rho, 0.001)
	set_param!(m, :farm, :sigmaBeefCo2, 3*65.1)
	set_param!(m, :farm, :sigmaBeefMeth, 3*6.5)
	set_param!(m, :farm, :sigmaBeefN2o, 3*0.22)
	set_param!(m, :farm, :sigmaPoultryCo2, 3*25.6)
	set_param!(m, :farm, :sigmaPoultryMeth, 3*0.02)
	set_param!(m, :farm, :sigmaPoultryN2o, 3*0.03)
	set_param!(m, :farm, :sigmaPorkCo2, 3*25.1)
	set_param!(m, :farm, :sigmaPorkMeth, 3*.7)
	set_param!(m, :farm, :sigmaPorkN2o, 3*.04)	
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
	set_param!(m, :welfare, :rho, 0.001)
	set_param!(m, :farm, :sigmaBeefCo2, 3*65.1)
	set_param!(m, :farm, :sigmaBeefMeth, 3*6.5)
	set_param!(m, :farm, :sigmaBeefN2o, 3*0.22)
	set_param!(m, :farm, :sigmaPoultryCo2, 3*25.6)
	set_param!(m, :farm, :sigmaPoultryMeth, 3*0.02)
	set_param!(m, :farm, :sigmaPoultryN2o, 3*0.03)
	set_param!(m, :farm, :sigmaPorkCo2, 3*25.1)
	set_param!(m, :farm, :sigmaPorkMeth, 3*.7)
	set_param!(m, :farm, :sigmaPorkN2o, 3*.04)	
	run(m)
	return m[:welfare, :UTILITY]
end

function optveg(x, grad)
	if length(grad)>0
	grad[1] = 1000
	end
    result = veg_outcome(x[1], 1.9, 0.025)
	return result
end
opt = Opt(:LN_SBPLX, 1)
opt.lower_bounds=[-1.0]
opt.upper_bounds=[.9999999999]
init = [.5]
opt.xtol_rel = 1e-3
opt.max_objective = optveg
sol = optimize(opt, init)[2]
Outcomes[6, 1] = sol[1]

function optanimals(x, grad)
	if length(grad)>0
	grad[1] = 1
	end
	result = ByAnimals_outcome(x, 1.9)
	return result
end
opt = Opt(:LN_SBPLX, 3)
opt.lower_bounds=-1*ones(3)
opt.upper_bounds=ones(3)
init = .75*ones(3)
opt.xtol_rel = 1e-3
opt.max_objective = optanimals
sol2 = optimize(opt, init)[2]
Outcomes[6,2] = sol2[1]
Outcomes[6,3] = sol2[2]  
Outcomes[6,4] = sol2[3]

#--- Theta A up 10% ----#
function veg_outcome(Veg, SufferingEquiv=1.0, alphaM = alpha)
	m = create_AnimalWelfareOpt()
	set_param!(m, :welfare, :CowEquiv, SufferingEquiv)
	set_param!(m, :welfare, :PigEquiv, SufferingEquiv)
	set_param!(m, :welfare, :ChickenEquiv, SufferingEquiv)
	set_param!(m, :welfare, :thetaChicken, 1.5)
	set_param!(m, :welfare, :alphameat, alphaM)
	set_param!(m, :farm, :MeatReduc, Veg)
	set_param!(m, :welfare, :thetaC, 1.5)
	set_param!(m, :welfare, :thetaB, 1.5)
	set_param!(m, :welfare, :thetaP, 1.5)
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
	set_param!(m, :welfare, :thetaC, 1.5)
	set_param!(m, :welfare, :thetaB, 1.5)
	set_param!(m, :welfare, :thetaP, 1.5)	
	run(m)
	return m[:welfare, :UTILITY]
end

function optveg(x, grad)
	if length(grad)>0
	grad[1] = 1000
	end
    result = veg_outcome(x[1])
	return result
end
opt = Opt(:LN_SBPLX, 1)
opt.lower_bounds=[-1.0]
opt.upper_bounds=[.9999999999]
init = [.5]
opt.xtol_rel = 1e-3
opt.max_objective = optveg
#sol = optimize(opt, init)[2]
Outcomes[7, 1] = sol[1]

function optanimals(x, grad)
	if length(grad)>0
	grad[1] = 1
	end
	result = ByAnimals_outcome(x)
	return result
end
opt = Opt(:LN_SBPLX, 3)
opt.lower_bounds=-1*ones(3)
opt.upper_bounds=ones(3)
init = .75*ones(3)
opt.xtol_rel = 1e-3
opt.max_objective = optanimals
#sol2 = optimize(opt, init)[2]
Outcomes[7,2] = sol2[1]
Outcomes[7,3] = sol2[2]  
Outcomes[7,4] = sol2[3]