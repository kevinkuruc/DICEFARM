@defcomp welfareforpolicy begin
    CEMUTOTPER      = Variable(index=[time])    #Period utility
    CUMCEMUTOTPER   = Variable(index=[time])    #Cumulative period utility
    PERIODU         = Variable(index=[time])    #One period utility function
    UTILITY         = Variable()                #Welfare Function
    rr              = Variable(index=[time])    #Pure social discount rate for that period
    MeatPC          = Variable(index=[time])    #Meat consumption per capita

    CPC             = Parameter(index=[time])   #Per capita consumption (thousands 2010 USD per year)
    Meat            = Parameter(index=[time])   #Meat Consumption
    l               = Parameter(index=[time])   #Level of population and labor (Millions)
    rho             = Parameter()               #Average utility social discount rate (annual)
    elasmu          = Parameter()               #Elasticity of marginal utility of consumption
    elasmeat        = Parameter()               #Elasticity on meat consumption
    alphameat       = Parameter()               #weight on meat utility
    scale1          = Parameter()               #Multiplicative scaling coefficient
    scale2          = Parameter()               #Additive scaling coefficient
    Cows            = Parameter(index=[time])   #Number of cow lives lived that year
    Pigs            = Parameter(index=[time])   #Number of pig lives lived that year
    Chickens        = Parameter(index=[time])   #Number of chicken lives lived that year
    thetaC          = Parameter()               #Moral weight chickens (humans =1)
    thetaP          = Parameter()               #Moral weight pigs
    thetaB          = Parameter()               #Moral weight cows
    CowEquiv        = Parameter()               #Income equivalent welfare ($ per day)
    PigEquiv        = Parameter()               #Income equivalent welfare ($ per day)
    ChickenEquiv    = Parameter()               #Income equivalent welfare ($ per day)

    function run_timestep(p, v, d, t)

        v.MeatPC[t]  = p.Meat[t]/(1e6*p.l[t])
        #Need critical level: 
        CL = ((1.9*365)^(1 - p.elasmu))/(1-p.elasmu) + p.alphameat*(0.10576)^(1-p.elasmeat)/(1-p.elasmeat)  #International Poverty Line
        
        #Per Animal Utility (assumed to be fixed for now)
        UCow = ((p.CowEquiv*365)^(1 - p.elasmu))/(1-p.elasmu) + p.alphameat*(0.10576)^(1-p.elasmeat)/(1-p.elasmeat) #1 dollar per day, absent meat utility
        UPig = ((p.PigEquiv*365)^(1 - p.elasmu))/(1-p.elasmu) + p.alphameat*(0.10576)^(1-p.elasmeat)/(1-p.elasmeat) #1 dollar per day, absent meat utility
        UChicken = ((p.ChickenEquiv*365)^(1 - p.elasmu))/(1-p.elasmu) + p.alphameat*(0.10576)^(1-p.elasmeat)/(1-p.elasmeat)  #1 dollar per day, absent meat utility

        # Define human utility
        v.PERIODU[t] = (p.CPC[t] ^ (1 - p.elasmu)) / (1 - p.elasmu) + p.alphameat*(v.MeatPC[t]^(1-p.elasmeat))/(1-p.elasmeat) - CL

        #Define function for rr
        if is_first(t) 
        v.rr[t] = 1.
        else
        v.rr[t] = v.rr[t-1]*(1-p.rho)
        end


        # Define function for CEMUTOTPER: Now Inclusive of animal welfare
        v.CEMUTOTPER[t] = v.rr[t]*((v.PERIODU[t]) * p.l[t] + p.thetaB*p.Cows[t]*1e-6*(UCow - CL) + p.thetaP*p.Pigs[t]*1e-6*(UPig - CL) + p.thetaC*p.Chickens[t]*1e-6*(UChicken - CL)) 

        # Define function for CUMCEMUTOTPER
        v.CUMCEMUTOTPER[t] = v.CEMUTOTPER[t] + (!is_first(t) ? v.CUMCEMUTOTPER[t-1] : 0)

        # Define function for UTILITY ---- what happens in last period?
        if is_last(t) 
            v.UTILITY =   v.CUMCEMUTOTPER[t] 
            utility =  v.CUMCEMUTOTPER[t] 
        end
    end
end
