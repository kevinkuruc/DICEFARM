################################################################################
# This component uses equations from FAIR v1.3 (Smith et al, 2018)
# and defines the forcings of 13 different segments of the environmental system
################################################################################

@defcomp climatedynamics begin
	TSlo 			= Variable(index=[time]) #slow moving part of temperature
	TFast			= Variable(index=[time]) #fast moving part of temperature
	Temp 			= Variable(index=[time]) #temp change we care about

	TotForcings 	= Parameter(index=[time])
	d1				= Parameter()  			 #decay coefficient for slow moving temp
	d2				= Parameter()			 #decay coefficient for fast temp
	q1				= Parameter()			 #weird parameter I don't know how to interpret
	q2				= Parameter()
	TSlo0   		= Parameter() 			 #init conditions for temp
	TFast0  		= Parameter() 			 #	

	function run_timestep(p, v, d, t)

		if is_first(t)
			v.TSlo[t] = p.TSlo0
			v.TFast[t]= p.TFast0
		else
			v.TSlo[t] = exp(1/p.d1)*v.TSlo[t-1] + (1-exp(1/p.d1)*p.q1*p.TotForcings[t]
			v.TFast[t]= exp(1/p.d2)*v.TFast[t-1] + (1-exp(1/p.d2)*p.q2*p.TotForcings[t]
		end

		v.Temp[t] = v.TSlo[t] + v.TFast[t]
	end


end