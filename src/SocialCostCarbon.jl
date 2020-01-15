include("ConsEquiv.jl")
include("CalibratingDICEFARM.jl")
Marg2020Emiss = getcalibratedDICEFARM()
T = 100
pulse = zeros(T)
pulse[2] = 1e-9
set_param!(Marg2020Emiss, :co2emissions, :CO2Marg, pulse)
run(Marg2020Emiss)
W = Marg2020Emiss[:welfare, :UTILITY]
println("Getting There")
EquivModel = getcalibratedDICEFARM()
DICEFARMSCC = ConsEquiv(EquivModel, W)

##DICE SCC
include("MimiDICE2016.jl")
MimiDICE = getdiceexcel()
T = 100
pulse = zeros(T)
pulse[2] = 1e-9
set_param!(MimiDICE, :emissions, :CO2Marg, pulse)
set_param!(MimiDICE, :radiativeforcing, :fex0, 1.5)
set_param!(MimiDICE, :radiativeforcing, :fex1, 0.95)
run(MimiDICE)
W2 = MimiDICE[:welfare, :UTILITY]
EquivModel2 = getdiceexcel()
set_param!(EquivModel2, :radiativeforcing, :fex0, 1.5)
set_param!(EquivModel2, :radiativeforcing, :fex1, 0.95)
ConsEquiv(EquivModel2, W2)