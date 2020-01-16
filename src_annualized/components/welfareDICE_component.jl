@defcomp welfare begin
    CEMUTOTPER      = Variable(index=[time])    #Period utility
    CUMCEMUTOTPER   = Variable(index=[time])    #Cumulative period utility
    PERIODU         = Variable(index=[time])    #One period utility function
    UTILITY         = Variable()                #Welfare Function

    CPC             = Parameter(index=[time])   #Per capita consumption (thousands 2010 USD per year)
    l               = Parameter(index=[time])   #Level of population and labor (Millions)
    rr              = Parameter(index=[time])   #Average utility social discount rate
    elasmu          = Parameter()               #Elasticity of marginal utility of consumption
    scale1          = Parameter()               #Multiplicative scaling coefficient
    scale2          = Parameter()               #Additive scaling coefficient

    function run_timestep(p, v, d, t)
        # Define function for PERIODU  SOMETHING IS WEIRD HERE, WHY -1?
        if p.elasmu!=1 
        v.PERIODU[t] = (p.CPC[t] ^ (1 - p.elasmu) - 1) / (1 - p.elasmu) 

        elseif p.elasmu==1 
        v.PERIODU[t] = log(p.CPC[t]) 

        end    
        # Define function for CEMUTOTPER
        v.CEMUTOTPER[t] = v.PERIODU[t] * p.l[t] * p.rr[t]

        # Define function for CUMCEMUTOTPER
        v.CUMCEMUTOTPER[t] = v.CEMUTOTPER[t] + (!is_first(t) ? v.CUMCEMUTOTPER[t-1] : 0)

        # Define function for UTILITY
        #Kevin: Need to do some steady-state analysis if savings is endogenized
        if t.t == 100
            v.UTILITY = 5 * p.scale1 * v.CUMCEMUTOTPER[t] + p.scale2

            utility = 5 * p.scale1 * v.CUMCEMUTOTPER[t] + p.scale2
        end
    end
end
