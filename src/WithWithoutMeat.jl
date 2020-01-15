#########
## This code runs the model and then adds 1 Hamburger in the year 2020. Asks what the social cost is.
#########
using Plots

T = 100

include("DICEFARM.jl")

Baseline = getDICEFARM()

run(Baseline)
Pop = Baseline[:welfare, :l]


PlusBurgers = getDICEFARM()
Pork = 1e6*4*Pop
set_param!(PlusBurgers, :farm, :Pork, Pork)

run(PlusBurgers)

BaseTemp = Baseline[:climatedynamics, :TATM]
MargTemp = PlusBurgers[:climatedynamics, :TATM]

TempDiff = MargTemp - BaseTemp
t = collect(2015:5:2105)
tempT = length(t)
plot(t, [BaseTemp[1:tempT] MargTemp[1:tempT]])

#CDiff = 1e6*Baseline[:welfare, :l].*(Baseline[:welfare, :CPC] - PlusBurgers[:welfare, :CPC])

#DiscountRate = 1-.03   #2.5% per year
#d = ones(T)
#for h = 1:T
#	d[h] = DiscountRate^(5*(h-2))
#end

#DiscountedCDiff = d.*CDiff
#TotalDiscountedDiff = sum(DiscountedCDiff)
