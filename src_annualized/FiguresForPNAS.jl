using Plots
include("ConsEquiv.jl")
include("CalibratingDICEFARM.jl")
DICEFARM = getcalibratedDICEFARM()
run(DICEFARM)
BaseTemp = DICEFARM[:climatedynamics, :TATM]

VeganDICE = getcalibratedDICEFARM()
T = length(BaseTemp)
set_param!(VeganDICE, :farm, :Beef, zeros(T))
set_param!(VeganDICE, :farm, :Dairy, zeros(T))
set_param!(VeganDICE, :farm, :Poultry, zeros(T))
set_param!(VeganDICE, :farm, :Pork, zeros(T))
set_param!(VeganDICE, :farm, :Eggs, zeros(T))
set_param!(VeganDICE, :farm, :SheepGoat, zeros(T))
run(VeganDICE)
VeganTemp = VeganDICE[:climatedynamics, :TATM]
plotT = 2120
t = collect(2020:5:2120)
plot(t, [BaseTemp[2:length(t)+1] VeganTemp[2:length(t)+1]], linewidth=2, linecolor=[:black :green], label=["BAU" "Vegan"], legend=:topleft, linestyle=[:solid :dash])
savefig("VeganTemp.pdf")

OrigBeef = DICEFARM[:farm, :Beef]
OrigDairy = DICEFARM[:farm, :Dairy]
OrigPork = DICEFARM[:farm, :Pork]
OrigPoultry = DICEFARM[:farm, :Poultry]
OrigEggs = DICEFARM[:farm, :Eggs]
OrigSheepGoat = DICEFARM[:farm, :SheepGoat]

BeefPulse = copy(OrigBeef)
DairyPulse = copy(OrigDairy)
PorkPulse = copy(OrigPork)
PoultryPulse = copy(OrigPoultry)
EggsPulse = copy(OrigEggs)
SheepGoatPulse = copy(OrigSheepGoat)

BeefPulse[2] = OrigBeef[2] + 4.8 
DairyPulse[2] = OrigDairy[2] + 8
PorkPulse[2] = OrigPork[2]  + 2.7
PoultryPulse[2] = OrigPoultry[2] + 6.7
EggsPulse[2] = OrigEggs[2]  + 1.5
SheepGoatPulse[2] = OrigSheepGoat[2] + .06

#Model With Vegan Pulse
VeganPulse = getcalibratedDICEFARM()
set_param!(VeganPulse, :farm, :Beef, BeefPulse)
set_param!(VeganPulse, :farm, :Dairy, DairyPulse)
set_param!(VeganPulse, :farm, :Poultry, PoultryPulse)
set_param!(VeganPulse, :farm, :Pork, PorkPulse)
set_param!(VeganPulse, :farm, :Eggs, EggsPulse)
set_param!(VeganPulse, :farm, :SheepGoat, SheepGoatPulse)
run(VeganPulse)
VeganIRF = VeganPulse[:climatedynamics, :TATM] - BaseTemp

##Model with Gasoline Pulse
GasPulse = getcalibratedDICEFARM()
T = 100
pulse = zeros(T)
pulse[2] = 4.6*1e-9
set_param!(GasPulse, :co2emissions, :CO2Marg, pulse)
run(GasPulse)
GasIRF = GasPulse[:climatedynamics, :TATM] - BaseTemp
plot(t, [VeganIRF[2:length(t)+1] GasIRF[2:length(t)+1]], legend=:bottomright, label=["Diet IRF" "Driving IRF"], linewidth=2, linestyle=[:solid :dash], color=[:green :black])
savefig("VeganIRF.pdf")

###Social cost computation
W0 = VeganPulse[:welfare, :UTILITY]
Baseline = getcalibratedDICEFARM()
SCVeg = ConsEquiv(Baseline, W0)
println("Starting SCs")
#Now do 1 Social Cost for each of Beef, Dairy, Pork, Poultry, Eggs, SheepGoat
Meats = [:Beef, :Dairy, :Pork, :Poultry, :Eggs, :SheepGoat]
Origs = [OrigBeef, OrigDairy, OrigPork, OrigPoultry, OrigEggs, OrigSheepGoat]
SCs   = zeros(length(Meats))
i = collect(1:1:length(Meats))
for (meat, O, i) in zip(Meats, Origs, i)
	tempModel = getcalibratedDICEFARM();
	Pulse = copy(O)
	Pulse[2] = Pulse[2] + 1.0 #add 1 kg of protein
	set_param!(tempModel, :farm, meat, Pulse)
	run(tempModel)
	W = tempModel[:welfare, :UTILITY]
	Baseline = getcalibratedDICEFARM();
	SCs[i] = .02*ConsEquiv(Baseline, W)
end
println("Done with SCs")


##Isocost curves
include("CalibratingDICEFARM.jl")
DICEFARM = getcalibratedDICEFARM()

isotemps = [2 2.5 3]
MReduc = collect(0:.01:1)
EIndReduc = zeros(length(MReduc), length(isotemps))
for MAXTEMP = 1:length(isotemps)
	for j = 1:length(MReduc)
		global CO2step = .005
		global Co2Reduc = 1 + CO2step
		maxtemp = 1.
			while maxtemp<isotemps[MAXTEMP]
			Co2Reduc = Co2Reduc - CO2step
			m = getcalibratedDICEFARM();
			set_param!(m, :farm, :MeatReduc, MReduc[j])
			set_param!(m, :co2emissions, :EIndReduc, Co2Reduc)
			run(m) 
			temp = m[:climatedynamics, :TATM]
			maxtemp = temp[22]  #temp in 2120 years
			end
	EIndReduc[j, MAXTEMP] = Co2Reduc
	end
end


plot(MReduc, EIndReduc, color=[:black], lw=2, label=["2 Degrees" "2.5 Degrees" "3 Degrees"], xlabel="Percent Animal Reduction", ylabel="Percent Industrial Reduction", linestyle=[:solid :dash :dot])


