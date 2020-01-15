###
using Plots

code_directory = joinpath(@__DIR__, "../")

function getcalibratedDICEFARM()

T = 100

include(joinpath(code_directory, "src\\DICEFARM.jl"))

DoubleCount = getDICEFARM()

run(DoubleCount)

Co2FARM = DoubleCount[:farm, :Co2EFarm]
N2oFARM = DoubleCount[:farm, :N2oEFarm]
MethFARM = DoubleCount[:farm, :MethEFarm]
LandUse = DoubleCount[:co2emissions, :ETREE]
N2oRCP = DoubleCount[:concentrations, :N2oERCP]
MethRCP = DoubleCount[:concentrations, :MethERCP]

NewLand = LandUse - Co2FARM
NewMeth = MethRCP - MethFARM
NewN2o  = N2oRCP - N2oFARM
for h = 1:100
	if NewN2o[h] <0
		NewN2o[h] = 0
	end
end

DICEFARM = getDICEFARM()
set_param!(DICEFARM, :co2emissions, :ETREE, NewLand)
set_param!(DICEFARM, :concentrations, :N2oERCP, NewN2o)
set_param!(DICEFARM, :concentrations, :MethERCP, NewMeth)

return DICEFARM
end