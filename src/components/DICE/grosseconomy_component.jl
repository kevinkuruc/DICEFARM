@defcomp grosseconomy begin
    K       = Variable(index=[time])    #Capital stock (trillions 2010 US dollars)
    YGROSS  = Variable(index=[time])    #Gross world product GROSS of abatement and damages (trillions 2010 USD per year)
    AL      = Variable(index=[time])    #Level of total factor productivity
    gA      = Variable(index=[time])    #Growth Rate of TFP
    growthD = Variable(index=[time])    #Damage from growth


    I       = Parameter(index=[time])   #Investment (trillions 2010 USD per year)
    l       = Parameter(index=[time])   #Level of population and labor
    dk      = Parameter()               #Depreciation rate on capital (per year)
    gama    = Parameter()               #Capital elasticity in production function
    k0      = Parameter()               #Initial capital value (trill 2010 USD)
    a0      = Parameter()               #Initial TFP
    ga0     = Parameter()               #Initial growth rate of TFP
    dela    = Parameter()               #decline of TFP growth rate per year
    T       = Parameter(index=[time])   #temperature (for growth rate damages)
    dam_gama= Parameter()               #how much growth rate impact damages

    function run_timestep(p, v, d, t)
		
        #Define function for K
        if gettime(t)==2015
            v.K[t] = p.k0
            v.AL[t] = p.a0
            v.gA[t] = p.ga0
        elseif gettime(t)>2015
            v.K[t] = (1 - p.dk) * v.K[t-1] + p.I[t-1]		#dropped 5th power on depreciation & dropped 5*I
            v.gA[t] = exp(p.dela*(gettime(t)-2015))*p.ga0
            v.AL[t] = v.AL[t-1]/(1-v.gA[t-1] + p.dam_gama*p.T[t-1])
        end

        #Define function for YGROSS
        if gettime(t) >=2015
        v.YGROSS[t] = (v.AL[t] * (p.l[t]/1000)^(1-p.gama)) * (v.K[t]^p.gama)
        end
    end
end
