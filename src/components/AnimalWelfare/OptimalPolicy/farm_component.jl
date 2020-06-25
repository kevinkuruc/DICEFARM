@defcomp farmforpolicy begin

    # ------ Output of Farm (Animals and Emissions) ---------- #

    MeatPC         = Variable(index=[time])    #CES Aggregator 
    MeatCost       = Variable(index=[time])    #Costs of producing that bundle

    Cows           = Variable(index=[time])    #Number of animal life-years per year (millions)
    Pigs           = Variable(index=[time])    #Number of animal life-years per year (millions)
    Chickens       = Variable(index=[time])    #Number of animal life-years per year (millions)

    Co2EFarm       = Variable(index=[time])    #GtCO2
    MethEFarm      = Variable(index=[time])    # kg
    N2oEFarm       = Variable(index=[time])    # kg

    MethEBeef  = Variable(index=[time])    #Methane emitted Beef (kg)
    Co2EBeef   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    N2oEBeef   = Variable(index=[time])    #N2O emitted from Beef (kg)

    #MethEDairy  = Variable(index=[time])    #Methane emitted Beef (kg)
    #Co2EDairy   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    #N2oEDairy   = Variable(index=[time])    #N2O emitted from Beef (kg)

    MethEPoultry  = Variable(index=[time])    #Methane emitted Beef (kg)
    Co2EPoultry   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    N2oEPoultry   = Variable(index=[time])    #N2O emitted from Beef (kg)

    MethEPork  = Variable(index=[time])    #Methane emitted Beef (kg)
    Co2EPork   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    N2oEPork   = Variable(index=[time])    #N2O emitted from Beef (kg)

    #MethEEggs  = Variable(index=[time])    #Methane emitted Beef (kg)
    #Co2EEggs   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    #N2oEEggs   = Variable(index=[time])    #N2O emitted from Beef (kg)

    #MethESheepGoat  = Variable(index=[time])    #Methane emitted Beef (kg)
    #Co2ESheepGoat   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    #N2oESheepGoat   = Variable(index=[time])    #N2O emitted from Beef (kg)

    # --------- Inputs (TFP; Number of Kg of each Animal consumed; Emissions Intensities --------- #

    ABeef           = Parameter()               #How effectively do we turn animals into meat
    APork           = Parameter()               
    APoultry        = Parameter()
    epsilon         = Parameter()               #Elasticity parameter
    theta_b         = Parameter()               #Preference Shifter
    theta_c         = Parameter()
    theta_p         = Parameter()               
    PBeef           = Parameter()               #Cost of beef production
    PPoultry        = Parameter()
    PPork           = Parameter()
    Beef            = Parameter(index=[time])   #Beef Produced (kgs of protein) [Annual]
    Dairy           = Parameter(index=[time])   #Dairy Produced (kgs of protein) [Annual]
    Poultry         = Parameter(index=[time])   #Poultry Produced (kgs of protein) [Annual]
    Pork            = Parameter(index=[time])   #Pork Produced (kgs of protein) [Annual]
    Eggs            = Parameter(index=[time])   #Eggs Produced (kgs of protein) [Annual]
    SheepGoat       = Parameter(index=[time])   #Sheep & Goat Produced (kgs of protein) [Annual]
    MeatReduc       = Parameter()                #New Vegetarian Fraction from 2020 onward
    BeefReduc       = Parameter()
    PorkReduc       = Parameter()
    PoultryReduc    = Parameter()
    l               = Parameter(index=[time])

    # ------ Emissions Intensities for each gas-animal -------- #

    sigmaBeefMeth   = Parameter()   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaBeefCo2    = Parameter()   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaBeefN2o    = Parameter()  #Kg of Nitrous Oxide per kg of protein from Beef

    sigmaDairyMeth  = Parameter()   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaDairyCo2   = Parameter()   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaDairyN2o   = Parameter()  #Kg of Nitrous Oxide per kg of protein from Beef
   
    sigmaPoultryMeth  = Parameter()   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaPoultryCo2   = Parameter()   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaPoultryN2o   = Parameter()  #Kg of Nitrous Oxide per kg of protein from Beef
   
    sigmaPorkMeth  = Parameter()   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaPorkCo2   = Parameter()   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaPorkN2o   = Parameter()  #Kg of Nitrous Oxide per kg of protein from Beef

    sigmaEggsMeth  = Parameter()   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaEggsCo2   = Parameter()   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaEggsN2o   = Parameter()  #Kg of Nitrous Oxide per kg of protein from Beef

    sigmaSheepGoatMeth  = Parameter()   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaSheepGoatCo2   = Parameter()   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaSheepGoatN2o   = Parameter()  #Kg of Nitrous Oxide per kg of protein from Beef

    # ----- Start component --------- #
 
    function run_timestep(p, v, d, t)
	
    if gettime(t) == 2020 #Allows planner to solve for optimal veg frac
        Beef = (1-p.MeatReduc)*(1-p.BeefReduc)*p.Beef[t]
        Pork = (1-p.MeatReduc)*(1-p.PorkReduc)*p.Pork[t]
        Poultry = (1-p.MeatReduc)*(1-p.PoultryReduc)*p.Poultry[t]
    else
        Beef = p.Beef[t]
        Pork = p.Pork[t]
        Poultry = p.Poultry[t]
    end

    v.MeatPC[t]     = (p.theta_b*(Beef/(1e6*p.l[t]))^p.epsilon + p.theta_c*(Poultry/(1e6*p.l[t]))^p.epsilon + p.theta_p*(Pork/(1e6*p.l[t]))^p.epsilon)^(1/p.epsilon)
    v.MeatCost[t]   = p.PBeef*Beef + p.PPoultry*Poultry + p.PPork*Pork

    v.Cows[t]       = p.ABeef*Beef
    v.Pigs[t]       = p.APork*Pork
    v.Chickens[t]   = p.APoultry*Poultry

    v.MethEBeef[t] = p.sigmaBeefMeth*Beef  # kg
    v.Co2EBeef[t]  = p.sigmaBeefCo2*Beef   # kg
    v.N2oEBeef[t]  = p.sigmaBeefN2o*Beef  # kg 

    #v.MethEDairy[t] = p.sigmaDairyMeth*Dairy  # kg
    #v.Co2EDairy[t]  = p.sigmaDairyCo2*Dairy   # kg
    #v.N2oEDairy[t]  = p.sigmaDairyN2o*Dairy  # kg 

    v.MethEPoultry[t] = p.sigmaPoultryMeth*Poultry  # kg
    v.Co2EPoultry[t]  = p.sigmaPoultryCo2*Poultry   # kg
    v.N2oEPoultry[t]  = p.sigmaPoultryN2o*Poultry  # kg 

    v.MethEPork[t] = p.sigmaPorkMeth*Pork  # kg
    v.Co2EPork[t]  = p.sigmaPorkCo2*Pork   # kg
    v.N2oEPork[t]  = p.sigmaPorkN2o*Pork  # kg 

    #v.MethEEggs[t] = p.sigmaEggsMeth*Eggs  # kg
    #v.Co2EEggs[t]  = p.sigmaEggsCo2*Eggs   # kg
    #v.N2oEEggs[t]  = p.sigmaEggsN2o*Eggs  # kg

    #v.MethESheepGoat[t] = p.sigmaSheepGoatMeth*SheepGoat  # kg
    #v.Co2ESheepGoat[t]  = p.sigmaSheepGoatCo2*SheepGoat   # kg
    #v.N2oESheepGoat[t]  = p.sigmaSheepGoatN2o*SheepGoat  # kg

    v.MethEFarm[t]  = (v.MethEBeef[t] + v.MethEPoultry[t] + v.MethEPork[t])       #kg
    v.Co2EFarm[t]   = ((v.Co2EBeef[t] + v.Co2EPoultry[t] + v.Co2EPork[t])/1e12)    #GtC02
    v.N2oEFarm[t]   = (v.N2oEBeef[t] + v.N2oEPoultry[t] + v.N2oEPork[t])        #kg
    end
end