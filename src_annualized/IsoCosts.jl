using Plots
include("CalibratingDICEFARM.jl")
DICEFARM = getcalibratedDICEFARM()

MReduc = collect(0:.1:1)
TwoDegrees = zeros(length(MReduc),2)
for j = 1:length(MReduc)
	global Co2Reduc = 1.01
	maxtemp = 1.
		while maxtemp<2
		Co2Reduc = Co2Reduc - .01
		m = getcalibratedDICEFARM()
		set_param!(m, :farm, :MeatReduc, MReduc[j])
		set_param!(m, :co2emissions, :EIndReduc, Co2Reduc)
		run(m) 
		temp = m[:climatedynamics, :TATM]
		maxtemp = temp[38]  #temp in 2200 years
		end
TwoDegrees[j, 1] = MReduc[j]
TwoDegrees[j, 2] = Co2Reduc
end

plot(TwoDegrees[:,1], TwoDegrees[:,2])