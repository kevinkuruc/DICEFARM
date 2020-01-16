@defcomp co2emissions begin
	SIG0	= Variable()				#Carbon intensity 2010-2015 (kgCO2 per output 2010 USD)
	GSIG	= Variable(index=[time])	#Change in sigma (cumulative improvement of energy efficiency)
	SIGMA	= Variable(index=[time])	#CO2-equivalent-emissions output ratio
    EIND    = Variable(index=[time])    #Industrial emissions (GtCO2 per year)
    ETREE	= Variable(index=[time])	#Emissions from deforestation
    E       = Variable(index=[time])    #Total CO2 emissions (GtCO2 per year)
	CUMETREE= Variable(index=[time])	#Cumulative from land
    CCA     = Variable(index=[time])    #Cumulative industrial emissions
	CCATOT	= Variable(index=[time])	#Cumulative total carbon emissions
	N2oE  	= Variable(index=[time])	#N2O emissions by time
	MethE 	= Variable(index=[time]) 	#Methane emissions by time

	EIndReduc 	= Parameter()				#Allows you to toggle off emissions
	Co2EFarm	= Parameter(index=[time])   #Animal Ag Co2 Emissions (GtCO2)
	gsigma1 	= Parameter()				#Initial growth of sigma (per year)
	dsig		= Parameter()				#Decline rate of decarbonization (per period)
	e0			= Parameter()				#Industrial emissions 2015 (GtCO2 per year)
	eland0		= Parameter()				#Carbon emissions from land 2015 (GtCO2 per year)
	deland		= Parameter()				#Decline rate of land emissions (per period)
    MIU     	= Parameter(index=[time])   #Emission control rate GHGs
    YGROSS  	= Parameter(index=[time])   #Gross world product GROSS of abatement and damages (trillions 2010 USD per year)
    cca0    	= Parameter()               #Initial cumulative industrial emissions
	cumetree0	=Parameter()				#Initial emissions from deforestation (see GAMS code)
	MethERCP	= Parameter(index=[time])	#RCP methane emissions (baseline animal emissions removed in code)
	MethEFarm	= Parameter(index=[time])	#Methane missions from farmed animals
	N2oERCP		= Parameter(index=[time])	#RCP N2O emissions (baseline animal emissions removed in code)
	N2oEFarm 	= Parameter(index=[time])	#N2O missions from farmed animals
	DoubleCountCo2 = Parameter(index=[time]) #eliminate CO2 emissions from animal products here
	CO2Marg  	= Parameter(index=[time])  #Marginal CO2

    function run_timestep(p, v, d, t)
		#Define SIG0
			v.SIG0 = p.e0/(p.YGROSS[1] * (1 - p.MIU[1]))
			
		#Define function for GSIG
		if is_first(t)
			v.GSIG[t] = log(p.gsigma1)/5 - 1 ##convert to annual growth
		else
			v.GSIG[t] = v.GSIG[t-1] * ((1 + p.dsig))  
		end
		
		#Define function for SIGMA
		if is_first(t)
			v.SIGMA[t] = v.SIG0
		else
			v.SIGMA[t] = v.SIGMA[t-1] * exp(v.GSIG[t-1])   
		end
		
        #Define function for EIND
        if t.t>5 #reductions only possible starting in 2020
		v.EIND[t] = v.SIGMA[t] * p.YGROSS[t] * (1 - p.MIU[t]) *(1-p.EIndReduc)
		else
		v.EIND[t] = v.SIGMA[t] * p.YGROSS[t] * (1 - p.MIU[t])
		end

		#Define function for ETREE
		if is_first(t)
			v.ETREE[t] = p.eland0
		else
			v.ETREE[t] = v.ETREE[t - 1] * (1 - log(p.deland)/5 -1)  #convert go annual growth
		end

        #Define function for E
        v.E[t] = v.EIND[t] + v.ETREE[t] + p.Co2EFarm[t] - p.DoubleCountCo2[t] + p.CO2Marg[t]
		
		#Define function for CUMETREE
		if is_first(t)
			v.CUMETREE[t] = p.cumetree0
		else
			v.CUMETREE[t] = v.CUMETREE[t-1] + v.ETREE[t-1]
		end
		
        #Define function for CCA
        if is_first(t)
            v.CCA[t] = p.cca0
        else
            v.CCA[t] = (v.CCA[t-1] + v.EIND[t-1]) /3.666
        end
			
		#Define function for CCATOT
			v.CCATOT[t] = v.CCA[t] + v.CUMETREE[t]			

		#Methane and N2o for FAIR module
		v.MethE = p.MethEFarm[t] + p.MethERCP[t]
		v.N2oE 	= p.N2oEFarm[t]  + p.N2oERCP[t]

    end
end