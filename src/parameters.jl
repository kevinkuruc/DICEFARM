using ExcelReaders, DataFrames, CSV
data_directory = joinpath(dirname(pwd()), "data")

function getdice2016excelparameters(start_year, end_year, DICEFile)
    p = Dict{Symbol,Any}()

    T = length(start_year:end_year)

    #Open DICE_2016 Excel File to Read Parameters
    f = openxl(DICEFile)

	p[:a0]			= getparams(f, "B108:B108", :single, "Parameters",1)#Initial level of total factor productivity
    p[:a1]          = getparams(f, "B25:B25", :single, "Base", 1)       #Damage coefficient on temperature
    p[:a2]          = getparams(f, "B26:B26", :single, "Base", 1)       #Damage quadratic term
    p[:a3]          = getparams(f, "B27:B27", :single, "Base", 1)       #Damage exponent
    p[:cca0]        = getparams(f, "B92:B92", :single, "Base", 1)       #Initial cumulative industrial emissions
    p[:cumetree0]   = 100							         			#Initial cumulative emissions from deforestation (see GAMS code)
    p[:damadj]      = getparams(f, "B65:B65", :single, "Parameters", 1) #Adjustment exponent in damage function
	p[:dela]		= getparams(f, "B110:B110", :single, "Parameters",1)#Decline rate of TFP per 5 years
	p[:tfp]         = getparams(f, "B21:CW21", :all, "Base", T)       # Total factor productivity.
    p[:deland]		= getparams(f, "D64:D64", :single, "Parameters", 1) #Decline rate of land emissions (per period)
    p[:DoubleCountCo2] = zeros(T)                                       #Just here for calibration purposes
    p[:dk]          = getparams(f, "B6:B6", :single, "Base", 1)         #Depreciation rate on capital (per year)
	p[:dsig]		= getparams(f, "B66:B66", :single, "Parameters", 1) #Decline rate of decarbonization (per period)
	p[:eland0]		= getparams(f, "D63:D63", :single, "Parameters", 1)	#Carbon emissions from land 2015 (GtCO2 per year)
	p[:etree]       = getparams(f, "B44:CW44", :all, "Base", T)     # Exogenous Land Use emissions scenario (GtCO2).
    p[:e0]			= getparams(f, "B113:B113", :single, "Base", 1)		#Industrial emissions 2015 (GtCO2 per year)
    p[:elasmu]      = getparams(f, "B19:B19", :single, "Base", 1)       #Elasticity of MU of consumption
    p[:eqmat]       = getparams(f, "B82:B82", :single, "Parameters", 1) #Equilibirum concentration of CO2 in atmosphere (GTC)
    p[:expcost2]    = getparams(f, "B39:B39", :single, "Base", 1)       #Exponent of control cost function
    p[:fosslim]     = getparams(f, "B57:B57", :single, "Base", 1)       #Maximum carbon resources (Gtc)
	p[:ga0]			= getparams(f, "B109:B109", :single, "Parameters",1)#Initial growth rate for TFP per 5 years
    p[:gama]        = getparams(f, "B5:B5", :single, "Base", 1)         #Capital Share
	p[:gback]		= getparams(f, "B26:B26", :single, "Parameters", 1) #Initial cost decline backstop cost per period
	p[:gsigma1]		= getparams(f, "B15:B15", :single, "Parameters", 1)	#Initial growth of sigma (per year)
    p[:k0]          = getparams(f, "B12:B12", :single, "Base", 1)       #Initial capital
    #Subbing in annual population
    l               = zeros(T)
    lexp            = .02835142  #value for annual, use .134 to hit 5-year population levels
    lasymptote      = 11500
    l[1]            = 7403  #init l
        for h = 2:T
        l[h]  = l[h-1]*(lasymptote/l[h-1])^lexp
        end
    p[:l]           = l
    p[:mat0]        = getparams(f, "B61:B61", :single, "Base", 1)       #Initial Concentration in atmosphere in 2015 (GtC)
	p[:mateq]		= getparams(f, "B82, B82", :single, "Parameters", 1)#Equilibrium concentration atmosphere  (GtC)
    p[:MIU]         = getparams(f, "B135:CW135", :all, "Base", T)       #Optimized emission control rate results from DICE2016R (base case)
    ######### NEED TO SUB SOMETHING IN FOR MIU ANNUALIZED
    p[:EIndToggle]  = 1.                                                #Lets you toggle Industrial Emissions off (through sigma)
    p[:pback]	    = getparams(f, "B10:B10", :single, "Parameters", 1) #Cost of backstop 2010$ per tCO2 2015
    p[:rho]         = .015                                              #Annual social rate of time preference
    #p[:rr]          = getparams(f, "B18:CW18", :all, "Base", T)         #Made variable in this run
    p[:S]           = getparams(f, "B131:CW131", :all, "Base", T)       #Optimized savings rate (fraction of gross output) results from DICE2016 (base case)
    ########## NEED TO SUB SOMETHING IN FOR SAVINGS RATES
    p[:scale1]      = getparams(f, "B49:B49", :single, "Base", 1)       #Multiplicative scaling coefficient
    p[:scale2]      = getparams(f, "B50:B50", :single, "Base", 1)       #Additive scaling coefficient

    tempyear = zeros(T)
    tempyear[1] = 2015
    	for h = 1:T
    		if h>1
    		tempyear[h] = tempyear[h-1]+5
    		end
    	end
    tempyear = tempyear .+ 2
    tempyear[T] = tempyear[T] -2
    Yrs = DataFrame(Year = tempyear)

    p[:CO2Marg]    = zeros(T)

    ##Add Farm Sector Parameters
    #PCgrowth = convert(Array, CSV.read(joinpath(data_directory, "PC_Growth.csv")))
    PCgrowth = ones(T)
        if PCgrowth[10]>1
            println("Running With Per Capita Meat Consumption Increase")
        end
    p[:Beef]  = 1e6*1.4*p[:l].*PCgrowth[:]     #Beef (in kg of protein) produced annually (loop over this for optimization)
    p[:Dairy] = 1e6*2.6*p[:l].*PCgrowth[:]
    p[:Poultry] = 1e6*2.0*p[:l].*PCgrowth[:]
    p[:Pork]    = 1e6*2.0*p[:l].*PCgrowth[:]
    p[:Eggs]    = 1e6*1.25*p[:l].*PCgrowth[:]
    p[:SheepGoat] = 1e6*.4*p[:l].*PCgrowth[:]
    p[:AFarm] = 75.0*ones(T)             #Number of animals to produce a kilogram of meat... no idea yet

    p[:sigmaBeefMeth] = 4.98      #Methane emissions (in kg) per kg of protein 
    p[:sigmaBeefCo2]  = 63.99      #Co2 emissions (in kg) per kg of protein
    p[:sigmaBeefN2o]  = 0.229     #N2O emissions (in kg) per kg of protein

    p[:sigmaDairyMeth] = 1.69      #Methane emissions (in kg) per kg of protein 
    p[:sigmaDairyCo2]  = 16.46      #Co2 emissions (in kg) per kg of protein
    p[:sigmaDairyN2o]  = 0.078     #N2O emissions (in kg) per kg of protein

    p[:sigmaPoultryMeth] = .02      #Methane emissions (in kg) per kg of protein 
    p[:sigmaPoultryCo2]  = 25.63      #Co2 emissions (in kg) per kg of protein
    p[:sigmaPoultryN2o]  = 0.030     #N2O emissions (in kg) per kg of protein

    p[:sigmaPorkMeth] = .503      #Methane emissions (in kg) per kg of protein 
    p[:sigmaPorkCo2]  = 25.12      #Co2 emissions (in kg) per kg of protein
    p[:sigmaPorkN2o]  = 0.043     #N2O emissions (in kg) per kg of protein

    p[:sigmaEggsMeth] = .052      #Methane emissions (in kg) per kg of protein 
    p[:sigmaEggsCo2]  = 20.09      #Co2 emissions (in kg) per kg of protein
    p[:sigmaEggsN2o]  = 0.032     #N2O emissions (in kg) per kg of protein

    p[:sigmaSheepGoatMeth] = 3.72      #Methane emissions (in kg) per kg of protein 
    p[:sigmaSheepGoatCo2]  = 22.45      #Co2 emissions (in kg) per kg of protein
    p[:sigmaSheepGoatN2o]  = 0.176     #N2O emissions (in kg) per kg of protein

    #For IsoCost Curves
    p[:CEQ]           = 0.      #For Social Cost computation
    p[:MeatReduc]    = 0.       #For Isocost curves
    p[:EIndReduc]     = 0.       #For Isocost curves

    return p
end

function getdice2016gamsparameters(filename)
    p = Dict{Symbol,Any}()

    T = 100

    #Open DICE_2016 Excel File to Read Parameters
    f = openxl(filename)
    sheet = "DICE2016_Base"

	p[:a0]			= 5.115											   #Initial level of total factor productivity
    p[:a1]          = getparams(f, "B41:B41", :single, sheet, 1)       #Damage coefficient on temperature
    p[:a2]          = getparams(f, "B42:B42", :single, sheet, 1)       #Damage quadratic term
    p[:a3]          = getparams(f, "B43:B43", :single, sheet, 1)       #Damage exponent
    p[:al]          = getparams(f, "B5:CWI5", :all, sheet, T)          #Level of total factor productivity
    p[:b12]         = getparams(f, "B20:B20", :single, sheet, 1)       #Carbon cycle transition matrix atmosphere to shallow ocean
    p[:b23]         = getparams(f, "B21:B21", :single, sheet, 1)       #Carbon cycle transition matrix shallow to deep ocean
    p[:c1]          = getparams(f, "B36:B36", :single, sheet, 1)       #Speed of adjustment parameter for atmospheric temperature (per 5 years)
    p[:c3]          = getparams(f, "B37:B37", :single, sheet, 1)       #Coefficient of heat loss from atmosphere to oceans
    p[:c4]          = getparams(f, "B38:B38", :single, sheet, 1)       #Coefficient of heat gain by deep oceans
    p[:cca0]        = getparams(f, "B14:B14", :single, sheet, 1)       #Initial cumulative industrial emissions
    p[:cost1]       = getparams(f, "B46:CW46", :all, sheet, T)         #Abatement cost function coefficient
    p[:cumetree0]   = 100											   #Initial cumulative emissions from deforestation (see GAMS code)
    p[:damadj]      = getparams(f, 10.)                                #Adjustment exponent in damage function
	p[:dela]		= 0.0050										   #Decline rate of TFP per 5 years
	p[:deland]		= 0.115											   #Decline rate of land emissions (per period)
    p[:dk]          = getparams(f, "B8:B8", :single, sheet, 1)         #Depreciation rate on capital (per year)
	p[:dsig]		= -0.001										   #Decline rate of decarbonization (per period)
	p[:eland0]		= 2.6										   	   #Carbon emissions from land 2015 (GtCO2 per year)
	p[:e0]			= 35.74471365402390								   #Industrial emissions 2015 (GtCO2 per year)
    p[:elasmu]      = getparams(f, "B54:B54", :single, sheet, 1)       #Elasticity of MU of consumption
    p[:eqmat]       = getparams(f, 588.)                               #Equilibirum concentration of CO2 in atmosphere (GTC)
    p[:expcost2]    = getparams(f, "B48:B48", :single, sheet, 1)       #Exponent of control cost function
    p[:fco22x]      = getparams(f, "B30:B30", :single, sheet, 1)       #Forcings of equilibrium CO2 doubling (Wm-2)
	p[:fex0]		= 0.5											   #2015 forcings of non-CO2 GHG (Wm-2)
	p[:fex1]		= 1.0											   #2100 forcings of non-CO2 GHG (Wm-2)
	p[:ga0]			= 0.0760										   #Initial growth rate for TFP per 5 years
    p[:gama]        = getparams(f, "B7:B7", :single, sheet, 1)         #Capital Share
	p[:gback]		= 0.025										 	   #Initial cost decline backstop cost per period
	p[:gsigma1]		= -0.0152										   #Initial growth of sigma (per year)
    p[:k0]          = getparams(f, "B9:B9", :single, sheet, 1)         #Initial capital
    p[:l]           = getparams(f, "B6:CW6", :all, sheet, T)           #Level of population and labor (millions)
    p[:mat0]        = getparams(f, "B17:B17", :single, sheet, 1)       #Initial Concentration in atmosphere in 2015 (GtC)
	p[:mateq]		= getparams(f, "B82, B82", :single, "Parameters",1)#Equilibrium concentration atmosphere  (GtC)
    p[:MIU]         = getparams(f, "B47:CW47", :all, sheet, T)         #Optimized emission control rate results from DICE2016R (base case)
    p[:ml0]         = getparams(f, "B19:B19", :single, sheet, 1)       #Initial Concentration in deep oceans 2015 (GtC)
	p[:mleq]		= getparams(f, "B84, B84", :single, "Parameters",1)#Equilibrium concentration in lower strata (GtC)
    p[:mu0]         = getparams(f, "B18:B18", :single, sheet, 1)       #Initial Concentration in biosphere/shallow oceans 2015 (GtC)
	p[:mueq]		= getparams(f, "B83:B83", :single, "Parameters", 1)#Equilibrium concentration in upper strata (GtC)
    p[:partfract]   = getparams(f, "B49:CW49", :all, sheet, T)         #Fraction of emissions in control regime
    p[:pback]	    = 550											   #Cost of backstop 2010$ per tCO2 2015
    p[:rr]          = getparams(f, "B55:CW55", :all, sheet, T)         #Social Time Preference Factor
    p[:S]           = getparams(f, "B51:CW51", :all, sheet, T)         #Optimized savings rate (fraction of gross output) results from DICE2016R (base case)
    p[:scale1]      = getparams(f, "B56:B56", :single, sheet, 1)       #Multiplicative scaling coefficient
    p[:scale2]      = getparams(f, "B57:B57", :single, sheet, 1)       #Additive scaling coefficient
    p[:t2xco2]      = getparams(f, "B33:B33", :single, sheet, 1)       #Equilibrium temp impact (oC per doubling CO2)
    p[:tatm0]       = getparams(f, "B34:B34", :single, sheet, 1)       #Initial atmospheric temp change (C from 1900)
    p[:tocean0]     = getparams(f, "B35:B35", :single, sheet, 1)       #Initial temperature of deep oceans (deg C above 1900)

    return p
end