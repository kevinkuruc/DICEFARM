################################################################################
# This component uses equations from FAIR v1.3 (Smith et al, 2018)
# and defines the forcings of 13 different segments of the environmental system
################################################################################

@defcomp forcing begin
	TotForcing  = Variable(index=[time])	#Total forcings
	FCo2 		= Variable(index=[time])   	#Co2 forcings
	FN2o 		= Variable(index=[time])	#Nitrus Oxide forcings
	FMeth		= Variable(index=[time])	#Methane forcings
	FMixed 		= Variable(index=[time])	#Well-mixed gases
	FTrop		= Parameter(index=[time])	#Tropical Ozone forcings
	FStrat 		= Parameter(index=[time])	#Stratospheric Ozone Forcings
	FWater		= Parameter(index=[time]) 	#Water vapor from Methane
	#FCont		= Parameter(index=[time])	#Contrails forcings
	FAero		= Parameter(index=[time])	#Aerosal forcings
	FBC			= Parameter(index=[time])  	#Black carbon on snow forcing
	#FLandUse	= Parameter(index=[time])	#Land Use change forcing
	FSolar		= Parameter(index=[time])	#Solar forcings
	#FVolcanic	= Parameter(index=[time])	#volcanic forcings (dont need, only historical)

	Co2Acc		= Parameter(index=[time]) 	#Co2 accumulated (ppm)
	N2oAcc 		= Parameter(index=[time])	#Nitrus Oxide Accumulated (ppb)
	MethAcc		= Parameter(index=[time])	#Methane Accumulated (ppb)
	Co2PI 		= Parameter()				#Pre-industrial CO2 (ppm)
	N2oPI 		= Parameter()				#Pre-industrial Nitrus Oxide (ppb)
	MethPI 		= Parameter()				#Pre-industrial Methane (ppb)

	#Other well-mixed gases, their accumulation and radiative forcing coefficient, eta
	CF4Force		= Parameter(index=[time])
	C2F6Force		= Parameter(index=[time])
	C6F14Force		= Parameter(index=[time])
	HFC23Force		= Parameter(index=[time])
	HFC32Force		= Parameter(index=[time])
	HFC43Force		= Parameter(index=[time])
	HFC125Force		= Parameter(index=[time])
	HFC134Force		= Parameter(index=[time])
	HFC143Force		= Parameter(index=[time])
	HFC227Force		= Parameter(index=[time])
	HFC245Force		= Parameter(index=[time])
	SF6Force		= Parameter(index=[time])
	CFC11Force		= Parameter(index=[time])
	CFC12Force		= Parameter(index=[time])
	CFC113Force		= Parameter(index=[time])
	CFC114Force		= Parameter(index=[time])
	CFC115Force		= Parameter(index=[time])
	CCl4Force		= Parameter(index=[time])
	MethylForce		= Parameter(index=[time])
	HCFC22Force		= Parameter(index=[time])
	HCFC141Force	= Parameter(index=[time])
	HCFC142Force	= Parameter(index=[time])
	Halon1211Force	= Parameter(index=[time])
	Halon1202Force	= Parameter(index=[time])
	Halon1301Force	= Parameter(index=[time])
	Halon2402Force	= Parameter(index=[time])
	CH3BrForce		= Parameter(index=[time])
	CH3ClForce		= Parameter(index=[time])



	function run_timestep(p, v, d, t)

	#Major Gases Forcings
	v.FCo2[t] = log(p.Co2Acc[t]/p.Co2PI)*((-2.4e-7)*(p.Co2Acc[t] - p.Co2PI)^2  + 7.2e-4*(abs(p.Co2Acc[t] - p.Co2PI)) - (1.05e-4)*(p.N2oAcc[t] + p.N2oPI) + 5.36)
	v.FN2o[t] = (sqrt(p.N2oAcc[t]) - sqrt(p.N2oPI))*(-4e-6*(p.Co2Acc[t] + p.Co2PI) + 2.1e-6*(p.N2oAcc[t] + p.N2oPI) - 2.45e-6*(p.MethAcc[t] + p.MethPI) + 0.117)
	v.FMeth[t]= (sqrt(p.MethAcc[t]) - sqrt(p.MethPI))*(-6.5e-7*(p.MethAcc[t] + p.MethPI) - 4.1e-6*(p.N2oAcc[t] + p.N2oPI) + 0.043)

	#Well-Mixed Gas Forcings
	OtherForcings 		= zeros(28)
	OtherForcings[1] 	= p.CF4Force[t]
	OtherForcings[2] 	= p.C2F6Force[t]
	OtherForcings[3] 	= p.C6F14Force[t]
	OtherForcings[4] 	= p.HFC23Force[t]
	OtherForcings[5] 	= p.HFC32Force[t]
	OtherForcings[6] 	= p.HFC43Force[t]
	OtherForcings[7] 	= p.HFC125Force[t]
	OtherForcings[8] 	= p.HFC134Force[t]
	OtherForcings[9] 	= p.HFC143Force[t]
	OtherForcings[10] 	= p.HFC227Force[t]
	OtherForcings[11] 	= p.HFC245Force[t]
	OtherForcings[12] 	= p.SF6Force[t]
	OtherForcings[13] 	= p.CFC11Force[t]
	OtherForcings[14] 	= p.CFC12Force[t]
	OtherForcings[15] 	= p.CFC113Force[t]
	OtherForcings[16]	= p.CFC114Force[t]
	OtherForcings[17] 	= p.CFC115Force[t]
	OtherForcings[18] 	= p.CCl4Force[t]
	OtherForcings[19] 	= p.MethylForce[t]
	OtherForcings[20]	= p.HCFC22Force[t]
	OtherForcings[21] 	= p.HCFC141Force[t]
	OtherForcings[22] 	= p.HCFC142Force[t]
	OtherForcings[23] 	= p.Halon1211Force[t]
	OtherForcings[24] 	= p.Halon1202Force[t]
	OtherForcings[25] 	= p.Halon1301Force[t]
	OtherForcings[26] 	= p.Halon2402Force[t]
	OtherForcings[27] 	= p.CH3BrForce[t]
	OtherForcings[28]	= p.CH3ClForce[t]

	v.FMixed[t] = sum(OtherForcings)

	v.TotForcing[t] = v.FCo2[t] + v.FN2o[t] + v.FMeth[t] + v.FMixed[t] + p.FTrop[t] + p.FStrat[t] + p.FSolar[t] + 3*p.FBC[t] + p.FAero[t] + p.FWater[t]  #All enter with coeff 1 except black carbon

	end

end