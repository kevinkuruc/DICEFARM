###
using Plots

code_directory = joinpath(@__DIR__, "../")

function getcalibratedDICEFARM()

T = 500

include(joinpath(code_directory, "src\\DICEFARM.jl"))

DoubleCount = getDICEFARM()

run(DoubleCount)

Co2FARM = DoubleCount[:farm, :Co2EFarm]
N2oFARM = DoubleCount[:farm, :N2oEFarm]
MethFARM = DoubleCount[:farm, :MethEFarm]
N2oRCP = DoubleCount[:concentrations, :N2oERCP]
MethRCP = DoubleCount[:concentrations, :MethERCP]

NewLand = LandUse - Co2FARM
NewMeth = MethRCP - MethFARM
NewN2o  = N2oRCP - N2oFARM
for h = 1:T
	if NewN2o[h] <0
		NewN2o[h] = 0
	end
end

DICEFARM = getDICEFARM()
set_param!(DICEFARM, :co2emissions, :DoubleCountCo2, -1*Co2FARM)  #carbon emissions unique in this model (should be negative vector)
set_param!(DICEFARM, :concentrations, :N2oERCP, NewN2o)
set_param!(DICEFARM, :concentrations, :MethERCP, NewMeth)

return DICEFARM
end