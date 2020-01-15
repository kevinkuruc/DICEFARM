################################################################################
# This component uses equations from FAIR v1.3 (Smith et al, 2018)
# and defines the forcings of 13 different segments of the environmental system
################################################################################

@defcomp concentrations begin
	AtmsM  			= Parameter()
	AtmsW			= Parameter()
	Co2Acc 			= Variable(index=[time])
	Co2W 			= Parameter()
	MAT				= Parameter(index=[time])  				#Found in Nordhaus' Carbon Cycle; just converted here

	MethAcc			= Variable(index=[time])
	MethERCP		= Parameter(index=[time])
	MethEFarm		= Parameter(index=[time])
	MethW			= Parameter()
	MethSink		= Parameter()
	MethInit		= Parameter()

	N2oAcc			= Variable(index=[time])
	N2oERCP			= Parameter(index=[time])
	N2oEFarm 		= Parameter(index=[time])
	N2oW			= Parameter()
	N2oSink			= Parameter()
	N2oInit			= Parameter()



	function run_timestep(p, v, d, t)
		v.Co2Acc[t] 	= p.MAT[t]/2.13  #Convert from GtC to ppm

		if is_first(t)
			v.MethAcc[t] = p.MethInit
		else
			v.MethAcc[t] =  exp(-5/p.MethSink)*v.MethAcc[t-1] + 1e9*5*((p.MethERCP[t]+ p.MethEFarm[t])*p.AtmsW)/(p.AtmsM*p.MethW) 	#in parts per billion
		end

		if is_first(t)
			v.N2oAcc[t] = p.N2oInit 
		else
			v.N2oAcc[t] =  exp(-5/p.N2oSink)*v.N2oAcc[t-1] + 1e9*5*((p.N2oERCP[t]+p.N2oEFarm[t])*p.AtmsW)/(p.AtmsM*p.N2oW) 	
		end

	end

end