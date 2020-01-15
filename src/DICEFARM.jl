using Mimi
using ExcelReaders

include("helpers.jl")
include("FARMparameters.jl")

include("marginaldamage.jl")

include("components/totalfactorproductivity_component.jl")
include("components/grosseconomy_component.jl")
include("components/farm_component.jl")
include("components/co2emissions_component.jl")
include("components/co2cycle_component.jl")
include("components/FAIR/concentrations_component.jl")
include("components/FAIR/forcing_component.jl")
include("components/climatedynamics_component.jl")
include("components/damages_component.jl")
include("components/neteconomy_component.jl")
include("components/welfare_component.jl")

export constructdice, getdiceexcel, getdicegams

const model_years = 2015:5:2510

function constructdice(p)

    m = Model()
    set_dimension!(m, :time, model_years)

    add_comp!(m, totalfactorproductivity, :totalfactorproductivity)
    add_comp!(m, grosseconomy, :grosseconomy)
    add_comp!(m, farm, :farm)
    add_comp!(m, co2emissions, :co2emissions)
    add_comp!(m, co2cycle, :co2cycle)
    add_comp!(m, concentrations, :concentrations)
    add_comp!(m, forcing, :forcing)
    add_comp!(m, climatedynamics, :climatedynamics)
    add_comp!(m, damages, :damages)
    add_comp!(m, neteconomy, :neteconomy)
    add_comp!(m, welfare, :welfare)

    # TFP COMPONENT
    set_param!(m, :totalfactorproductivity, :a0, p[:a0])
	set_param!(m, :totalfactorproductivity, :ga0, p[:ga0])
    set_param!(m, :totalfactorproductivity, :dela, p[:dela])
    
    # GROSS ECONOMY COMPONENT
    set_param!(m, :grosseconomy, :l, p[:l])
    set_param!(m, :grosseconomy, :gama, p[:gama])
    set_param!(m, :grosseconomy, :dk, p[:dk])
    set_param!(m, :grosseconomy, :k0, p[:k0])

    connect_param!(m, :grosseconomy, :AL, :totalfactorproductivity, :AL)
    connect_param!(m, :grosseconomy, :I, :neteconomy, :I)

    #FARM COMPONENT
    set_param!(m, :farm, :Beef, p[:Beef])
    set_param!(m, :farm, :Dairy, p[:Dairy])
    set_param!(m, :farm, :Poultry, p[:Poultry])
    set_param!(m, :farm, :Pork, p[:Pork])
    set_param!(m, :farm, :Eggs, p[:Eggs])
    set_param!(m, :farm, :SheepGoat, p[:SheepGoat])
    set_param!(m, :farm, :AFarm, p[:AFarm])
    set_param!(m, :farm, :sigmaBeefMeth, p[:sigmaBeefMeth])
    set_param!(m, :farm, :sigmaBeefCo2, p[:sigmaBeefCo2])
    set_param!(m, :farm, :sigmaBeefN2o, p[:sigmaBeefN2o])
    set_param!(m, :farm, :sigmaDairyMeth, p[:sigmaDairyMeth])
    set_param!(m, :farm, :sigmaDairyCo2, p[:sigmaDairyCo2])
    set_param!(m, :farm, :sigmaDairyN2o, p[:sigmaDairyN2o])
    set_param!(m, :farm, :sigmaPoultryMeth, p[:sigmaPoultryMeth])
    set_param!(m, :farm, :sigmaPoultryCo2, p[:sigmaPoultryCo2])
    set_param!(m, :farm, :sigmaPoultryN2o, p[:sigmaPoultryN2o])
    set_param!(m, :farm, :sigmaPorkMeth, p[:sigmaPorkMeth])
    set_param!(m, :farm, :sigmaPorkCo2, p[:sigmaPorkCo2])
    set_param!(m, :farm, :sigmaPorkN2o, p[:sigmaPorkN2o])
    set_param!(m, :farm, :sigmaEggsMeth, p[:sigmaEggsMeth])
    set_param!(m, :farm, :sigmaEggsCo2, p[:sigmaEggsCo2])
    set_param!(m, :farm, :sigmaEggsN2o, p[:sigmaEggsN2o])
    set_param!(m, :farm, :sigmaSheepGoatMeth, p[:sigmaSheepGoatMeth])
    set_param!(m, :farm, :sigmaSheepGoatCo2, p[:sigmaSheepGoatCo2])
    set_param!(m, :farm, :sigmaSheepGoatN2o, p[:sigmaSheepGoatN2o])
    set_param!(m, :farm, :MeatReduc, p[:MeatReduc])

    # CO2 EMISSIONS COMPONENT
    set_param!(m, :co2emissions, :gsigma1, p[:gsigma1])
    set_param!(m, :co2emissions, :dsig, p[:dsig])
	set_param!(m, :co2emissions, :ETREE, p[:ETREE])
	set_param!(m, :co2emissions, :e0, p[:e0])
    set_param!(m, :co2emissions, :MIU, p[:MIU])
    set_param!(m, :co2emissions, :EIndReduc, p[:EIndReduc])
    set_param!(m, :co2emissions, :cca0, p[:cca0])
	set_param!(m, :co2emissions, :cumetree0, p[:cumetree0])
    set_param!(m, :co2emissions, :CO2Marg, p[:CO2Marg])

    connect_param!(m, :co2emissions, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :co2emissions, :Co2EFarm, :farm, :Co2EFarm)

    # CO2 CYCLE COMPONENT
    set_param!(m, :co2cycle, :mat0, p[:mat0])
    set_param!(m, :co2cycle, :mu0, p[:mu0])
    set_param!(m, :co2cycle, :ml0, p[:ml0])
    set_param!(m, :co2cycle, :b12, p[:b12])
    set_param!(m, :co2cycle, :b23, p[:b23])
	set_param!(m, :co2cycle, :mateq, p[:mateq])
	set_param!(m, :co2cycle, :mleq, p[:mleq])
	set_param!(m, :co2cycle, :mueq, p[:mueq])
    connect_param!(m, :co2cycle, :E, :co2emissions, :E)

    # CONCENTRATIONS COMPONENT FROM FAIR
    set_param!(m, :concentrations, :AtmsM, p[:AtmsM])
    set_param!(m, :concentrations, :AtmsW, p[:AtmsW])
    set_param!(m, :concentrations, :Co2W, p[:Co2W])
    set_param!(m, :concentrations, :MethERCP, p[:MethERCP])
    set_param!(m, :concentrations, :MethW, p[:MethW])
    set_param!(m, :concentrations, :MethSink, p[:MethSink])
    set_param!(m, :concentrations, :MethInit, p[:MethInit])
    set_param!(m, :concentrations, :N2oERCP, p[:N2oERCP])
    set_param!(m, :concentrations, :N2oW, p[:N2oW])
    set_param!(m, :concentrations, :N2oSink, p[:N2oSink])
    set_param!(m, :concentrations, :N2oInit, p[:N2oInit])

    connect_param!(m, :concentrations, :MethEFarm, :farm, :MethEFarm)
    connect_param!(m, :concentrations, :MAT, :co2cycle, :MAT)
    connect_param!(m, :concentrations, :N2oEFarm, :farm, :N2oEFarm)

    # FORCINGS COMPONENT FROM FAIR/RCP
    set_param!(m, :forcing, :FTrop, p[:FTrop])
    set_param!(m, :forcing, :FStrat, p[:FStrat])
    set_param!(m, :forcing, :FWater, p[:FWater])
    set_param!(m, :forcing, :FAero, p[:FAero])
    set_param!(m, :forcing, :FBC, p[:FBC])
    set_param!(m, :forcing, :FSolar, p[:FSolar])
    set_param!(m, :forcing, :Co2PI, p[:Co2PI])
    set_param!(m, :forcing, :N2oPI, p[:N2oPI])
    set_param!(m, :forcing, :MethPI, p[:MethPI])
    set_param!(m, :forcing, :CF4Force, p[:CF4Force])
    set_param!(m, :forcing, :C2F6Force, p[:C2F6Force])
    set_param!(m, :forcing, :C6F14Force, p[:C6F14Force])
    set_param!(m, :forcing, :HFC23Force, p[:HFC23Force])
    set_param!(m, :forcing, :HFC32Force, p[:HFC32Force])
    set_param!(m, :forcing, :HFC43Force, p[:HFC43Force])
    set_param!(m, :forcing, :HFC125Force, p[:HFC125Force])
    set_param!(m, :forcing, :HFC134Force, p[:HFC134Force])
    set_param!(m, :forcing, :HFC143Force, p[:HFC143Force])
    set_param!(m, :forcing, :HFC227Force, p[:HFC227Force])
    set_param!(m, :forcing, :HFC245Force, p[:HFC245Force])
    set_param!(m, :forcing, :SF6Force, p[:SF6Force])
    set_param!(m, :forcing, :CFC11Force, p[:CFC11Force])
    set_param!(m, :forcing, :CFC12Force, p[:CFC12Force])
    set_param!(m, :forcing, :CFC113Force, p[:CFC113Force])
    set_param!(m, :forcing, :CFC114Force, p[:CFC114Force])
    set_param!(m, :forcing, :CFC115Force, p[:CFC115Force])
    set_param!(m, :forcing, :CCl4Force, p[:CCl4Force])
    set_param!(m, :forcing, :MethylForce, p[:MethylForce])
    set_param!(m, :forcing, :HCFC22Force, p[:HCFC22Force])
    set_param!(m, :forcing, :HCFC141Force, p[:HCFC141Force])
    set_param!(m, :forcing, :HCFC142Force, p[:HCFC142Force])
    set_param!(m, :forcing, :Halon1211Force, p[:Halon1211Force])
    set_param!(m, :forcing, :Halon1202Force, p[:Halon1202Force])
    set_param!(m, :forcing, :Halon1301Force, p[:Halon1301Force])
    set_param!(m, :forcing, :Halon2402Force, p[:Halon2402Force])
    set_param!(m, :forcing, :CH3BrForce, p[:CH3BrForce])
    set_param!(m, :forcing, :CH3ClForce, p[:CH3ClForce])
    connect_param!(m, :forcing, :Co2Acc, :concentrations, :Co2Acc)
    connect_param!(m, :forcing, :N2oAcc, :concentrations, :N2oAcc)
    connect_param!(m, :forcing, :MethAcc, :concentrations, :MethAcc)

    # CLIMATE DYNAMICS COMPONENT (DICE)
    set_param!(m, :climatedynamics, :fco22x, p[:fco22x])
    set_param!(m, :climatedynamics, :t2xco2, p[:t2xco2])
    set_param!(m, :climatedynamics, :tatm0, p[:tatm0])
    set_param!(m, :climatedynamics, :tocean0, p[:tocean0])
    set_param!(m, :climatedynamics, :c1, p[:c1])
    set_param!(m, :climatedynamics, :c3, p[:c3])
    set_param!(m, :climatedynamics, :c4, p[:c4])
    connect_param!(m, :climatedynamics, :TotForcing, :forcing, :TotForcing)

    # DAMAGES COMPONENT
    set_param!(m, :damages, :a1, p[:a1])
    set_param!(m, :damages, :a2, p[:a2])
    set_param!(m, :damages, :a3, p[:a3])
    connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)

    # NET ECONOMY COMPONENT
    set_param!(m, :neteconomy, :MIU, p[:MIU])
    set_param!(m, :neteconomy, :expcost2, p[:expcost2])
    set_param!(m, :neteconomy, :pback, p[:pback])
	set_param!(m, :neteconomy, :gback, p[:gback])
    set_param!(m, :neteconomy, :S, p[:S])
    set_param!(m, :neteconomy, :l, p[:l])
    set_param!(m, :neteconomy, :CEQ, p[:CEQ])
    connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMAGES, :damages, :DAMAGES)
	connect_param!(m, :neteconomy, :SIGMA, :co2emissions, :SIGMA)

    # WELFARE COMPONENT
    set_param!(m, :welfare, :l, p[:l])
    set_param!(m, :welfare, :elasmu, p[:elasmu])
    set_param!(m, :welfare, :rr, p[:rr])
    set_param!(m, :welfare, :scale1, p[:scale1])
    set_param!(m, :welfare, :scale2, p[:scale2])
    set_param!(m, :welfare, :AlphaMeat, p[:AlphaMeat])
    set_param!(m, :welfare, :elasmeat, p[:elasmeat])
    set_param!(m, :welfare, :Beef, p[:Beef])
    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    return m

end

function getDICEFARM(;datafile = joinpath(dirname(@__FILE__), "..", "data", "DICE2016ANDFAIRParameters.xlsm"))
    params = getdice2016excelparameters(datafile)

    m = constructdice(params)

    return m
end

function getdicegams(;datafile = joinpath(dirname(@__FILE__), "..", "data", "DICE2016_IAMF_Parameters.xlsx"))
    params = getdice2016gamsparameters(datafile)

    m = constructdice(params)

    return m
end

# get_model function for standard Mimi API: use the Excel version
get_model = getDICEFARM