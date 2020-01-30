@defcomp farm begin
    ## M a parameter since planner will solve for it in the optimization loop
    A           = Variable(index=[time])    #Number of animal life-years per year (millions)
    Beef        = Parameter(index=[time])   #Beef Produced (kgs of protein) [Annual]
    Dairy       = Parameter(index=[time])   #Dairy Produced (kgs of protein) [Annual]
    Poultry     = Parameter(index=[time])   #Poultry Produced (kgs of protein) [Annual]
    Pork        = Parameter(index=[time])   #Pork Produced (kgs of protein) [Annual]
    Eggs        = Parameter(index=[time])   #Eggs Produced (kgs of protein) [Annual]
    SheepGoat   = Parameter(index=[time])   #Sheep & Goat Produced (kgs of protein) [Annual]
    MeatReduc   = Parameter()               #For isocost curves

    AFarm           = Parameter(index=[time])   #Total factor productivity of farming
    sigmaBeefMeth   = Parameter(index=[time])   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaBeefCo2    = Parameter(index=[time])   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaBeefN2o    = Parameter(index=[time])  #Kg of Nitrous Oxide per kg of protein from Beef

    sigmaDairyMeth  = Parameter(index=[time])   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaDairyCo2   = Parameter(index=[time])   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaDairyN2o   = Parameter(index=[time])  #Kg of Nitrous Oxide per kg of protein from Beef
   
    sigmaPoultryMeth  = Parameter(index=[time])   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaPoultryCo2   = Parameter(index=[time])   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaPoultryN2o   = Parameter(index=[time])  #Kg of Nitrous Oxide per kg of protein from Beef
   
    sigmaPorkMeth  = Parameter(index=[time])   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaPorkCo2   = Parameter(index=[time])   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaPorkN2o   = Parameter(index=[time])  #Kg of Nitrous Oxide per kg of protein from Beef

    sigmaEggsMeth  = Parameter(index=[time])   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaEggsCo2   = Parameter(index=[time])   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaEggsN2o   = Parameter(index=[time])  #Kg of Nitrous Oxide per kg of protein from Beef

    sigmaSheepGoatMeth  = Parameter(index=[time])   #Kg of Methane Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaSheepGoatCo2   = Parameter(index=[time])   #Kg of CO2 per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaSheepGoatN2o   = Parameter(index=[time])  #Kg of Nitrous Oxide per kg of protein from Beef


    MethEBeef  = Variable(index=[time])    #Methane emitted Beef (kg)
    Co2EBeef   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    N2oEBeef   = Variable(index=[time])    #N2O emitted from Beef (kg)

    MethEDairy  = Variable(index=[time])    #Methane emitted Beef (kg)
    Co2EDairy   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    N2oEDairy   = Variable(index=[time])    #N2O emitted from Beef (kg)

    MethEPoultry  = Variable(index=[time])    #Methane emitted Beef (kg)
    Co2EPoultry   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    N2oEPoultry   = Variable(index=[time])    #N2O emitted from Beef (kg)

    MethEPork  = Variable(index=[time])    #Methane emitted Beef (kg)
    Co2EPork   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    N2oEPork   = Variable(index=[time])    #N2O emitted from Beef (kg)

    MethEEggs  = Variable(index=[time])    #Methane emitted Beef (kg)
    Co2EEggs   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    N2oEEggs   = Variable(index=[time])    #N2O emitted from Beef (kg)

    MethESheepGoat  = Variable(index=[time])    #Methane emitted Beef (kg)
    Co2ESheepGoat   = Variable(index=[time])    #Co2 emitted from Beef (kg)
    N2oESheepGoat   = Variable(index=[time])    #N2O emitted from Beef (kg)

    Co2EFarm       = Variable(index=[time])    #GtCO2
    MethEFarm      = Variable(index=[time])    # kg
    N2oEFarm       = Variable(index=[time])    # kg
 
    function run_timestep(p, v, d, t)
	
    v.A[t] = p.AFarm[t]*p.Beef[t]

    v.MethEBeef[t] = p.sigmaBeefMeth[t]*p.Beef[t]  # kg
    v.Co2EBeef[t]  = p.sigmaBeefCo2[t]*p.Beef[t]   # kg
    v.N2oEBeef[t]  = p.sigmaBeefN2o[t]*p.Beef[t]  # kg 

    v.MethEDairy[t] = p.sigmaDairyMeth[t]*p.Dairy[t]  # kg
    v.Co2EDairy[t]  = p.sigmaDairyCo2[t]*p.Dairy[t]   # kg
    v.N2oEDairy[t]  = p.sigmaDairyN2o[t]*p.Dairy[t]  # kg 

    v.MethEPoultry[t] = p.sigmaPoultryMeth[t]*p.Poultry[t]  # kg
    v.Co2EPoultry[t]  = p.sigmaPoultryCo2[t]*p.Poultry[t]   # kg
    v.N2oEPoultry[t]  = p.sigmaPoultryN2o[t]*p.Poultry[t]  # kg 

    v.MethEPork[t] = p.sigmaPorkMeth[t]*p.Pork[t]  # kg
    v.Co2EPork[t]  = p.sigmaPorkCo2[t]*p.Pork[t]   # kg
    v.N2oEPork[t]  = p.sigmaPorkN2o[t]*p.Pork[t]  # kg 

    v.MethEEggs[t] = p.sigmaEggsMeth[t]*p.Eggs[t]  # kg
    v.Co2EEggs[t]  = p.sigmaEggsCo2[t]*p.Eggs[t]   # kg
    v.N2oEEggs[t]  = p.sigmaEggsN2o[t]*p.Eggs[t]  # kg

    v.MethESheepGoat[t] = p.sigmaSheepGoatMeth[t]*p.SheepGoat[t]  # kg
    v.Co2ESheepGoat[t]  = p.sigmaSheepGoatCo2[t]*p.SheepGoat[t]   # kg
    v.N2oESheepGoat[t]  = p.sigmaSheepGoatN2o[t]*p.SheepGoat[t]  # kg

        if is_first(t)  #reductions starting in 2020.
        v.MethEFarm[t]  = (v.MethEBeef[t] + v.MethEDairy[t] + v.MethEPoultry[t] + v.MethEPork[t] + v.MethEEggs[t] + v.MethESheepGoat[t])       #kg
        v.Co2EFarm[t]   = ((v.Co2EBeef[t] + v.Co2EDairy[t] + v.Co2EPoultry[t] + v.Co2EPork[t] + v.Co2EEggs[t] + v.Co2ESheepGoat[t])/1e12)    #GtC02
        v.N2oEFarm[t]   = (v.N2oEBeef[t] + v.N2oEDairy[t] + v.N2oEPoultry[t] + v.N2oEPork[t] + v.N2oEEggs[t] + v.N2oESheepGoat[t])        #kg
        else
        v.MethEFarm[t]  = (v.MethEBeef[t] + v.MethEDairy[t] + v.MethEPoultry[t] + v.MethEPork[t] + v.MethEEggs[t] + v.MethESheepGoat[t])*(1-p.MeatReduc)       #kg
        v.Co2EFarm[t]   = ((v.Co2EBeef[t] + v.Co2EDairy[t] + v.Co2EPoultry[t] + v.Co2EPork[t] + v.Co2EEggs[t] + v.Co2ESheepGoat[t])/1e12)*(1-p.MeatReduc)    #GtC02
        v.N2oEFarm[t]   = (v.N2oEBeef[t] + v.N2oEDairy[t] + v.N2oEPoultry[t] + v.N2oEPork[t] + v.N2oEEggs[t] + v.N2oESheepGoat[t])*(1-p.MeatReduc)        #kg
        end
    end
end