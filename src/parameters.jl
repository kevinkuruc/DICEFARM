using ExcelReaders
using DataFrames
using CSV 

data_directory = joinpath(@__DIR__, "../", "data")

function getdice2016excelparameters(DICEFile)
    p = Dict{Symbol,Any}()

    T = 100

    #Open DICE_2016 Excel File to Read Parameters
    f = openxl(DICEFile)

	p[:a0]			= getparams(f, "B108:B108", :single, "Parameters",1)#Initial level of total factor productivity
    p[:a1]          = getparams(f, "B25:B25", :single, "Base", 1)       #Damage coefficient on temperature
    p[:a2]          = getparams(f, "B26:B26", :single, "Base", 1)       #Damage quadratic term
    p[:a3]          = getparams(f, "B27:B27", :single, "Base", 1)       #Damage exponent
    p[:al]          = getparams(f, "B21:CW21", :all, "Base", T)         #Level of total factor productivity
    p[:b12]         = getparams(f, "B67:B67", :single, "Base", 1)       #Carbon cycle transition matrix atmosphere to shallow ocean
    p[:b23]         = getparams(f, "B70:B70", :single, "Base", 1)       #Carbon cycle transition matrix shallow to deep ocean
    p[:c1]          = getparams(f, "B82:B82", :single, "Base", 1)       #Speed of adjustment parameter for atmospheric temperature (per 5 years)
    p[:c3]          = getparams(f, "B83:B83", :single, "Base", 1)       #Coefficient of heat loss from atmosphere to oceans
    p[:c4]          = getparams(f, "B84:B84", :single, "Base", 1)       #Coefficient of heat gain by deep oceans
    p[:cca0]        = getparams(f, "B92:B92", :single, "Base", T)       #Initial cumulative industrial emissions
    p[:cost1]       = getparams(f, "B32:CW32", :all, "Base", T)         #Abatement cost function coefficient
    p[:cumetree0]   = 100							         			#Initial cumulative emissions from deforestation (see GAMS code)
    p[:damadj]      = getparams(f, "B65:B65", :single, "Parameters", 1) #Adjustment exponent in damage function
	p[:dela]		= getparams(f, "B110:B110", :single, "Parameters",1)#Decline rate of TFP per 5 years
	p[:deland]		= getparams(f, "D64:D64", :single, "Parameters", 1) #Decline rate of land emissions (per period)
    p[:ETREE]       = getparams(f, "B44:CW44", :all, "Base", T)         #ETREE
    p[:dk]          = getparams(f, "B6:B6", :single, "Base", 1)         #Depreciation rate on capital (per year)
	p[:dsig]		= getparams(f, "B66:B66", :single, "Parameters", 1) #Decline rate of decarbonization (per period)
	p[:eland0]		= getparams(f, "D63:D63", :single, "Parameters", 1)	#Carbon emissions from land 2015 (GtCO2 per year)
	p[:e0]			= getparams(f, "B113:B113", :single, "Base", 1)		#Industrial emissions 2015 (GtCO2 per year)
    p[:elasmu]      = getparams(f, "B19:B19", :single, "Base", 1)       #Elasticity of MU of consumption
    p[:eqmat]       = getparams(f, "B82:B82", :single, "Parameters", 1) #Equilibirum concentration of CO2 in atmosphere (GTC)
    p[:expcost2]    = getparams(f, "B39:B39", :single, "Base", 1)       #Exponent of control cost function
    p[:fco22x]      = getparams(f, "B80:B80", :single, "Base", 1)       #Forcings of equilibrium CO2 doubling (Wm-2)
	p[:fex0]		= getparams(f, "B87:B87", :single, "Parameters", 1) #2015 forcings of non-CO2 GHG (Wm-2)
	p[:fex1]		= getparams(f, "B88:B88", :single, "Parameters", 1) #2100 forcings of non-CO2 GHG (Wm-2)
    p[:fosslim]     = getparams(f, "B57:B57", :single, "Base", 1)       #Maximum carbon resources (Gtc)
	p[:ga0]			= getparams(f, "B109:B109", :single, "Parameters",1)#Initial growth rate for TFP per 5 years
    p[:gama]        = getparams(f, "B5:B5", :single, "Base", 1)         #Capital Share
	p[:gback]		= getparams(f, "B26:B26", :single, "Parameters", 1) #Initial cost decline backstop cost per period
	p[:gsigma1]		= getparams(f, "B15:B15", :single, "Parameters", 1)	#Initial growth of sigma (per year)
    p[:k0]          = getparams(f, "B12:B12", :single, "Base", 1)       #Initial capital
    p[:l]           = getparams(f, "B53:CW53", :all, "Base", T)         #Level of population and labor (millions)
    p[:mat0]        = getparams(f, "B61:B61", :single, "Base", 1)       #Initial Concentration in atmosphere in 2015 (GtC)
	p[:mateq]		= getparams(f, "B82, B82", :single, "Parameters", 1)#Equilibrium concentration atmosphere  (GtC)
    p[:MIU]         = getparams(f, "B135:CW135", :all, "Base", T)       #Optimized emission control rate results from DICE2016R (base case)
    p[:EIndToggle]  = 1.                                                #Lets you toggle Industrial Emissions off (through sigma)
    p[:ml0]         = getparams(f, "B63:B63", :single, "Base", 1)       #Initial Concentration in deep oceans 2015 (GtC)
	p[:mleq]		= getparams(f, "B84, B84", :single, "Parameters", 1)#Equilibrium concentration in lower strata (GtC)
    p[:mu0]         = getparams(f, "B62:B62", :single, "Base", 1)       #Initial Concentration in biosphere/shallow oceans 2010 (GtC)
	p[:mueq]		= getparams(f, "B83:B83", :single, "Parameters", 1) #Equilibrium concentration in upper strata (GtC)
    p[:pback]	    = getparams(f, "B10:B10", :single, "Parameters", 1) #Cost of backstop 2010$ per tCO2 2015
    p[:rr]          = getparams(f, "B18:CW18", :all, "Base", T)         #Social Time Preference Factor
    p[:S]           = getparams(f, "B131:CW131", :all, "Base", T)       #Optimized savings rate (fraction of gross output) results from DICE2016 (base case)
    p[:scale1]      = getparams(f, "B49:B49", :single, "Base", 1)       #Multiplicative scaling coefficient
    p[:scale2]      = getparams(f, "B50:B50", :single, "Base", 1)       #Additive scaling coefficient
    p[:t2xco2]      = getparams(f, "B79:B79", :single, "Base", 1)       #Equilibrium temp impact (oC per doubling CO2)
    p[:tatm0]       = getparams(f, "B76:B76", :single, "Base", 1)       #Initial atmospheric temp change 2015 (C from 1940-60)
    p[:tocean0]     = getparams(f, "B77:B77", :single, "Base", 1)       #Initial temperature of deep oceans (deg C above 1940-60)

    ## FAIR PARAMETERS NEEDED FOR MODEL
    ##Weight
    p[:AtmsM] = 5.1352e18
    p[:AtmsW] = 28.97 #Molecular Weight of Dry Aid
    p[:Co2W]  = getparams(f, "B2:B2", :single, "FAIRParameters", 1)
    p[:MethW]  = getparams(f, "B3:B3", :single, "FAIRParameters", 1)
    p[:N2oW]  = getparams(f, "B4:B4", :single, "FAIRParameters", 1)

    #Sink
    p[:MethSink]  = getparams(f, "D3:D3", :single, "FAIRParameters", 1)
    p[:N2oSink]  = getparams(f, "D4:D4", :single, "FAIRParameters", 1)

    #Initial Concentrations
    p[:MethInit]  = getparams(f, "E3:E3", :single, "FAIRParameters", 1) #2015 values
    p[:N2oInit]  = getparams(f, "E4:E4", :single, "FAIRParameters", 1) #2015 values

    #PI Concentrations 
    p[:Co2PI]  = getparams(f, "F2:F2", :single, "FAIRParameters", 1)
    p[:MethPI]  = getparams(f, "F3:F3", :single, "FAIRParameters", 1)
    p[:N2oPI]  = getparams(f, "F4:F4", :single, "FAIRParameters", 1)


    ##### RCP CSVs
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
    ForcingDF = CSV.read(joinpath(data_directory, "ForcingCSV.csv"))
    EmissionsDF = CSV.read(joinpath(data_directory, "EmissionsCSV.csv"))
	RCPDF = join(Yrs, ForcingDF, on=:Year, kind=:inner)
    RCPDF = join(RCPDF, EmissionsDF, on=:Year, kind=:inner)


    p[:N2oForce]  = convert(Array{Float64}, RCPDF[:N2O])
    p[:CF4Force]  = convert(Array{Float64}, RCPDF[:CF4])
    p[:C2F6Force]  = convert(Array{Float64}, RCPDF[:C2F6])
    p[:C6F14Force]  = convert(Array{Float64}, RCPDF[:C6F14])
    p[:HFC23Force]  = convert(Array{Float64}, RCPDF[:HFC23])
    p[:HFC32Force]  = convert(Array{Float64}, RCPDF[:HFC32])
    p[:HFC43Force]  = convert(Array{Float64}, RCPDF[:HFC43_10])
    p[:HFC125Force]  = convert(Array{Float64}, RCPDF[:HFC125])
    p[:HFC134Force]  = convert(Array{Float64}, RCPDF[:HFC134a])
    p[:HFC143Force]  = convert(Array{Float64}, RCPDF[:HFC143a])
    p[:HFC227Force]  = convert(Array{Float64}, RCPDF[:HFC227ea])
    p[:HFC245Force]  = convert(Array{Float64}, RCPDF[:HFC245fa])
    p[:SF6Force]  = convert(Array{Float64}, RCPDF[:SF6])
    p[:CFC11Force]  = convert(Array{Float64}, RCPDF[:CFC_11])
    p[:CFC12Force]  = convert(Array{Float64}, RCPDF[:CFC_12])
    p[:CFC113Force]  = convert(Array{Float64}, RCPDF[:CFC_113])
    p[:CFC114Force]  = convert(Array{Float64}, RCPDF[:CFC_114])
    p[:CFC115Force]  = convert(Array{Float64}, RCPDF[:CFC_115])
    p[:CCl4Force]  = convert(Array{Float64}, RCPDF[:CARB_TET])
    p[:MethylForce]  = convert(Array{Float64}, RCPDF[:MCF])
    p[:HCFC22Force]  = convert(Array{Float64}, RCPDF[:HCFC_22])
    p[:HCFC141Force]  = convert(Array{Float64}, RCPDF[:HCFC_141B])
    p[:HCFC142Force]  = convert(Array{Float64}, RCPDF[:HCFC_142B])
    p[:Halon1211Force]  = convert(Array{Float64}, RCPDF[:HALON1211])
    p[:Halon1202Force]  = convert(Array{Float64}, RCPDF[:HALON1202])
    p[:Halon1301Force]  = convert(Array{Float64}, RCPDF[:HALON1301])
    p[:Halon2402Force]  = convert(Array{Float64}, RCPDF[:HALON2402])
    p[:CH3BrForce]  = convert(Array{Float64}, RCPDF[:CH3BR])
    p[:CH3ClForce]  = convert(Array{Float64}, RCPDF[:CH3CL])
    p[:FAero]  = convert(Array{Float64}, RCPDF[:TOTAER_DIR])
    p[:FStrat]  = convert(Array{Float64}, RCPDF[:STRATOZ])	
    p[:FTrop]  = convert(Array{Float64}, RCPDF[:TROPOZ])	
    p[:FBC]  = convert(Array{Float64}, RCPDF[:BCSNOW])	
    p[:FLandUse]  = convert(Array{Float64}, RCPDF[:LANDUSE])	
    p[:FSolar]  = convert(Array{Float64}, RCPDF[:SOLAR])	
    p[:FWater]  = convert(Array{Float64}, RCPDF[:CH4OXSTRATH2O])

    p[:MethERCP]   = 1e9*convert(Array{Float64}, RCPDF[:Methane_Emissions]) #Megatons to Kilograms is 1e9
    p[:N2oERCP]    = 1e9*convert(Array{Float64}, RCPDF[:N2o_Emissions]) 
    p[:CO2Marg]    = zeros(T)    		

    ##Add Farm Sector Parameters
    p[:Beef]  = 1e6*1.4*p[:l].*ones(T)     #Beef (in kg of protein) produced annually (loop over this for optimization)
    p[:Dairy] = 1e6*2.6*p[:l].*ones(T)
    p[:Poultry] = 1e6*2.0*p[:l] .*ones(T)
    p[:Pork]    = 1e6*2.0*p[:l] .*ones(T)
    p[:Eggs]    = 1e6*1.25*p[:l] .*ones(T)
    p[:SheepGoat] = 1e6*.4*p[:l] .*ones(T)
    p[:AFarm] = 75.0*ones(T)             #Number of animals to produce a kilogram of meat... no idea yet

    p[:sigmaBeefMeth] = 6.5*ones(T)      #Methane emissions (in kg) per kg of protein 
    p[:sigmaBeefCo2]  = 65.1*ones(T)      #Co2 emissions (in kg) per kg of protein
    p[:sigmaBeefN2o]  = 0.22*ones(T)     #N2O emissions (in kg) per kg of protein

    p[:sigmaDairyMeth] = 2.1*ones(T)      #Methane emissions (in kg) per kg of protein 
    p[:sigmaDairyCo2]  = 14.6*ones(T)      #Co2 emissions (in kg) per kg of protein
    p[:sigmaDairyN2o]  = 0.22*ones(T)     #N2O emissions (in kg) per kg of protein

    p[:sigmaPoultryMeth] = .02*ones(T)      #Methane emissions (in kg) per kg of protein 
    p[:sigmaPoultryCo2]  = 25.6*ones(T)      #Co2 emissions (in kg) per kg of protein
    p[:sigmaPoultryN2o]  = 0.03*ones(T)     #N2O emissions (in kg) per kg of protein

    p[:sigmaPorkMeth] = .70*ones(T)      #Methane emissions (in kg) per kg of protein 
    p[:sigmaPorkCo2]  = 25.1*ones(T)      #Co2 emissions (in kg) per kg of protein
    p[:sigmaPorkN2o]  = 0.04*ones(T)     #N2O emissions (in kg) per kg of protein

    p[:sigmaEggsMeth] = .07*ones(T)      #Methane emissions (in kg) per kg of protein 
    p[:sigmaEggsCo2]  = 20.1*ones(T)      #Co2 emissions (in kg) per kg of protein
    p[:sigmaEggsN2o]  = 0.03*ones(T)     #N2O emissions (in kg) per kg of protein

    p[:sigmaSheepGoatMeth] = 4.5*ones(T)      #Methane emissions (in kg) per kg of protein 
    p[:sigmaSheepGoatCo2]  = 20.0*ones(T)      #Co2 emissions (in kg) per kg of protein
    p[:sigmaSheepGoatN2o]  = 0.16*ones(T)     #N2O emissions (in kg) per kg of protein

    #For Welfare module
    p[:elasmeat]     = 1.1     #CRRA parameter on meat eating... No idea yet
    p[:AlphaMeat]    = 0.       #scalar on meat utility function
    p[:CEQ]          = 0.       #Cons. equivalent welfare losses necessary for SCM calculation

    #For IsoCost Curves
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