@defcomp neteconomyforpolicy begin

	PBACKTIME	= Variable(index=[time])	#Backstop price
	COST1		= Variable(index=[time])	#Adjusted cost for backstop
    ABATECOST   = Variable(index=[time])    #Cost of emissions reductions (trillions 2010 USD per year)
    C           = Variable(index=[time])    #Consumption (trillions 2010 US dollars per year)
    CPC         = Variable(index=[time])    #Per capita consumption (thousands 2010 USD per year)
    CPRICE      = Variable(index=[time])    #Carbon price (2010$ per ton of CO2)
    I           = Variable(index=[time])    #Investment (trillions 2010 USD per year)
    MCABATE     = Variable(index=[time])    #Marginal cost of abatement (2010$ per ton CO2)
    Y           = Variable(index=[time])    #Gross world product net of abatement and damages (trillions 2010 USD per year)
    YNET        = Variable(index=[time])    #Output net of damages equation (trillions 2010 USD per year)
    

	SIGMA		= Parameter(index=[time])	#CO2-equivalent-emissions output ratio
    DAMAGES     = Parameter(index=[time])   #Damages (Trillion $)
    l           = Parameter(index=[time])   #Level of population and labor
    MIU         = Parameter(index=[time])   #Emission control rate GHGs
    S           = Parameter(index=[time])   #Gross savings rate as fraction of gross world product
    YGROSS      = Parameter(index=[time])   #Gross world product GROSS of abatement and damages (trillions 2010 USD per year)
    expcost2    = Parameter()               #Exponent of control cost function
	pback		= Parameter()				#Cost of backstop 2010$ per tCO2 2015
	gback		= Parameter()				#Initial cost decline backstop cost per period
    CEQ         = Parameter()
    MeatExp     = Parameter(index=[time])   #Amount spent on meat
    #Need meat utility params

    function run_timestep(p, v, d, t)
		#Define function for PBACKTIME
        if gettime(t) >=2015
        if gettime(t) ==2015
            v.PBACKTIME[t] = p.pback
        else
            newgback = (1+p.gback)^.2 - 1			#convert to annualized growth
            v.PBACKTIME[t] = v.PBACKTIME[t - 1] * (1 - newgback)
        end
		
		#Define function for COSTL
		v.COST1[t] = v.PBACKTIME[t] * p.SIGMA[t] / p.expcost2 / 1000
		
        #Define function for YNET
        v.YNET[t] = p.YGROSS[t] - p.DAMAGES[t]
    
        #Define function for ABATECOST
        v.ABATECOST[t] = p.YGROSS[t] * v.COST1[t] * (p.MIU[t]^p.expcost2)
    
        #Define function for MCABATE (equation from GAMS version)
        v.MCABATE[t] = v.PBACKTIME[t] * p.MIU[t]^(p.expcost2 - 1)
    
        #Define function for Y
        v.Y[t] = v.YNET[t] - v.ABATECOST[t]
    
        #Define function for I
        v.I[t] = p.S[t] * v.Y[t]


        #Define function for C
        if gettime(t)==2020
        v.C[t] = v.Y[t] - v.I[t] - 1e-12*p.MeatExp[t] - p.CEQ  #Convert meat costs to trillions from dollars
        else
        v.C[t] = v.Y[t] - v.I[t] - 1e-12*p.MeatExp[t]
        end
    
        #Define function for CPC
        v.CPC[t] = 1000 * (1000 * v.C[t] / p.l[t]) #Want to put in dollar terms for this version of run
    
        #Define function for CPRICE (equation from GAMS version of DICE2016)
        v.CPRICE[t] = v.PBACKTIME[t] * (p.MIU[t]^(p.expcost2 - 1))
        end
    end
end
