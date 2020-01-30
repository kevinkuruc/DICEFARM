@defcomp welfare begin
    CEMUTOTPER      = Variable(index=[time])    #Period utility
    CUMCEMUTOTPER   = Variable(index=[time])    #Cumulative period utility
    PERIODU         = Variable(index=[time])    #One period utility function
    UTILITY         = Variable()                #Welfare Function
    Meat            = Variable(index=[time])   #Some Meat aggregator (Millions of kg)
    rr              = Variable(index=[time])    #Pure social discount rate for that period

    CPC             = Parameter(index=[time])   #Per capita consumption (thousands 2010 USD per year)
    Beef            = Parameter(index=[time])   #Kg of protein from beef
    AlphaMeat       = Parameter()               #scalar on meat parameter
    l               = Parameter(index=[time])   #Level of population and labor (Millions)
    rho             = Parameter()               #Average utility social discount rate (annual)
    elasmu          = Parameter()               #Elasticity of marginal utility of consumption
    elasmeat        = Parameter()               #Elasticity of marginal utility of meat consumption
    scale1          = Parameter()               #Multiplicative scaling coefficient
    scale2          = Parameter()               #Additive scaling coefficient

    function run_timestep(p, v, d, t)

        v.Meat[t]   = p.Beef[t] + 1


        # Define function for PERIODU  SOMETHING IS WEIRD HERE, WHY -1?
        if p.elasmu!=1 && p.elasmeat!=1
        v.PERIODU[t] = (p.CPC[t] ^ (1 - p.elasmu) - 1) / (1 - p.elasmu) + p.AlphaMeat*((v.Meat[t]/p.l[t])^(1-p.elasmeat) - 1)/(1-p.elasmeat)

        elseif p.elasmu==1 && p.elasmeat!=1
        v.PERIODU[t] = log(p.CPC[t]) + p.AlphaMeat*((v.Meat[t]/p.l[t])^(1-p.elasmeat) - 1)/(1-p.elasmeat)

        elseif p.elasmu!=1 && p.elasmeat==1
        v.PERIODU[t] = (p.CPC[t] ^ (1 - p.elasmu) - 1) / (1 - p.elasmu) + p.AlphaMeat*log((v.Meat[t]/p.l[t])) 

        elseif p.elasmu==1 && p.elasmeat==1
        v.PERIODU[t] = log(p.CPC[t]) + p.AlphaMeat*log((v.Meat[t]/p.l[t]))
        end  

        #Define function for rr
        if is_first(t) 
        v.rr[t] = 1.
        else
        v.rr[t] = v.rr[t-1]*(1-p.rho)
        end


        # Define function for CEMUTOTPER
        v.CEMUTOTPER[t] = v.PERIODU[t] * p.l[t] * v.rr[t]

        # Define function for CUMCEMUTOTPER
        v.CUMCEMUTOTPER[t] = v.CEMUTOTPER[t] + (!is_first(t) ? v.CUMCEMUTOTPER[t-1] : 0)

        # Define function for UTILITY
        #Kevin: Need to do some steady-state analysis if savings is endogenized
        if is_last(t) 
            v.UTILITY =  p.scale1 * v.CUMCEMUTOTPER[t] + p.scale2
            utility = p.scale1 * v.CUMCEMUTOTPER[t] + p.scale2
        end
    end
end
