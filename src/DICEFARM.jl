using MimiFAIR
using Interpolations
using Mimi

include("helpers.jl")
include("parameters.jl")

# Load MimiDICE2016 components modified to be annual and integrate with FARM module.
include(joinpath("components", "DICE", "emissions_component.jl"))
include(joinpath("components", "DICE", "damages_component.jl"))
include(joinpath("components", "DICE", "grosseconomy_component.jl"))
include(joinpath("components", "DICE", "totalfactorproductivity_component.jl"))
include(joinpath("components", "DICE", "neteconomy_component.jl"))
include(joinpath("components", "DICE", "welfare_component.jl"))
include(joinpath("components", "farm_component.jl"))


# p = dice and farm parameters
# start_year = first year to run FAIR (1765)
# end year = last year to run FAIR coupled to DICE+FARM (2500)
# start_dice_year = first year to switch dice on and fully couple to fair.

function initialize_dice_farm(p, start_year, end_year, start_dice_year, TCR, ECS)

    # Create an instance of FAIR to couple in DICE-FARM components.
    m = MimiFAIR.get_model(rcp_scenario="RCP60", start_year=start_year, end_year=end_year, TCR=TCR, ECS=ECS)

    #--------------------------------------------------------------------------------------------------------------------
    # TODO: Hide all of this in a function or data prep step in the future. Just putting here to be clear what's going on.
    #--------------------------------------------------------------------------------------------------------------------

        # Create "backup" emissions scenarios to run FAIR for periods before 2015 (after which DICEFARM kicks in).
        # NOTE: Interpolating from 2010-2015 for CO2 so no jumps between RCP and DICE CO2 scenarios (CH4 and N2O follow RCP).
        run(m)
        rcp_landuse_co2 = m[:landuse_rf, :landuse_emiss] # landuse only used for albedo change forcing (GtC)
        rcp_total_co2   = m[:co2_cycle, :E]  # Total FAIR CO2 emissions = fossil + landuse (GtC)
        rcp_fossil_ch4  = m[:ch4_cycle, :fossil_emiss_CH₄] #Mt CH4/yr
        rcp_fossil_n2o  = m[:n2o_cycle, :fossil_emiss_N₂O] #Mt N/yr (but double check this unit)

        # Just hard-coding this in for now... DICE2016 industrial CO2 emissions in 2015 (not affected by policy) units = GtC.
        dice_fossilco2_2015  = 9.754465143940621
        dice_landuseco2_2015 = 0.7095205635082936
        dice_totalco2_2015   = dice_fossilco2_2015 + dice_landuseco2_2015

        # Calculate RCP index to begin interpolation so there's a smooth transition from historicla RCP to present day DICE CO2 emissions.
        rcp_years      = collect(1765:2500)
        rcp_2010_index = findfirst(x-> x == 2010, rcp_years)
        rcp_2015_index = findfirst(x-> x == 2015, rcp_years)

        # Calculate the interpolation piece for landuse and fossil CO₂ emissions (from 2010 to 2015).
        landuse_interp = dice_interpolate([rcp_landuse_co2[rcp_2010_index], dice_landuseco2_2015], 5)
        total_interp   = dice_interpolate([rcp_total_co2[rcp_2010_index], dice_totalco2_2015], 5)

        # Set up backup emissions scenarios (Mimi requires a backup value for when two compoennts do not overlap).
        # Will use: RCP emissions (1765-2009), interpolation values (2010-2014), then -9999.99 so an error occurs if model coupling is incorrect (2015 onward is endogenous DICEFARM emissions).
        backup_landuse_RCPco2 = vcat(rcp_landuse_co2[1:(rcp_2010_index-1)], landuse_interp[1:5], ones(length(2015:2500)).*-9999.99)
        backup_total_RCPco2   = vcat(rcp_total_co2[1:(rcp_2010_index-1)], total_interp[1:5], ones(length(2015:2500)).*-9999.99)

        # Set up "backup" CH4 and N2O emissions. No need to interpolate since once DICE FARM kicks in, CH4 and N2O emissions will be endogenous farm emissions + remaining RCP emissions (so they sum to total RCP emissions).
        backup_fossil_RCPn2o = vcat(rcp_fossil_n2o[1:(rcp_2015_index-1)], ones(length(2015:2500)).*-9999.99)
        backup_fossil_RCPch4 = vcat(rcp_fossil_ch4[1:(rcp_2015_index-1)], ones(length(2015:2500)).*-9999.99)

        # Create annual MIU, savings rate, TFP values, and land use emissions (cropped from 2015:2500 to match RCP scenario end year, otherwise DICE runs from 2015-2510).
        # First calculate index for DICE end year that matches with FAIR (in this case, 2500).
        dice_2500_index = findfirst(x -> x == 2500, collect(2015:2510))
        annual_savings  = dice_interpolate(p[:S], 5)[1:dice_2500_index]
        annual_MIU      = dice_interpolate(p[:MIU], 5)[1:dice_2500_index]
        annual_TFP      = dice_interpolate(p[:tfp], 5)[1:dice_2500_index]
        annual_ETREE    = dice_interpolate(p[:etree], 5)[1:dice_2500_index]

        # --------------------------------------------
        # End of Data Prep Stuff
        # --------------------------------------------

    #-----------------------------------------------------------------------
    # Add DICE-FARM Components to MimiFAIR v1.3
    #-----------------------------------------------------------------------

    # Add DICEFARM components used to calculate emissions that feed into FAIR.
    add_comp!(m, emissions,    before = :ch4_cycle; first = start_dice_year)
    add_comp!(m, farm,         before = :emissions; first = start_dice_year)
    add_comp!(m, grosseconomy, before = :farm;      first = start_dice_year)
    #add_comp!(m, totalfactorproductivity, before=:grosseconomy; first= start_dice_year)

    # Add DICEFARM components to calculate climate impacts, net output, and welfare based on FAIR temperature projections.
    add_comp!(m, damages,    after = :temperature; first = start_dice_year)
    add_comp!(m, neteconomy, after = :damages;     first = start_dice_year)
    add_comp!(m, welfare,    after = :neteconomy;  first = start_dice_year)

    #-----------------------------------------------------------------------
    # Set Exogenous Component Parameters
    #-----------------------------------------------------------------------
    # ----- Total Factor Productivity ------ #
    #set_param!(m, :totalfactorproductivity, :a0,    p[:a0])
    #set_param!(m, :totalfactorproductivity, :ga0, p[:ga0])
    #set_param!(m, :totalfactorproductivity, :dela,   p[:dela]) 

    # Pad the parameters so they have the time length of the full model, not just DICE
    p = pad_parameters(p, end_year - start_dice_year + 1, start_dice_year - start_year, 0)

    # ----- Parameters Common to Multiple Components ----- #
    set_param!(m, :l,       p[:l]) # grosseconomy, neteconomy, and welfare
    set_param!(m, :MIU,     pad_parameter(annual_MIU, end_year - start_dice_year + 1, start_dice_year - start_year, 0)) # emissions and neteconomy


    # ----- Gross Economy ----- #
    #set_param!(m, :grosseconomy, :l,    p[:l])
    set_param!(m, :grosseconomy, :gama, p[:gama])
    set_param!(m, :grosseconomy, :dk,   0.0819)  #Comes from changing DICE to annual
    set_param!(m, :grosseconomy, :k0,   p[:k0])
    set_param!(m, :grosseconomy, :AL,   pad_parameter(annual_TFP, end_year - start_dice_year + 1, start_dice_year - start_year, 0))

    # ----- Agriculture Emissions ----- #
    set_param!(m, :farm, :Beef,               p[:Beef])
    set_param!(m, :farm, :Dairy,              p[:Dairy])
    set_param!(m, :farm, :Poultry,            p[:Poultry])
    set_param!(m, :farm, :Pork,               p[:Pork])
    set_param!(m, :farm, :Eggs,               p[:Eggs])
    set_param!(m, :farm, :SheepGoat,          p[:SheepGoat])
    set_param!(m, :farm, :sigmaBeefMeth,      p[:sigmaBeefMeth])
    set_param!(m, :farm, :sigmaBeefCo2,       p[:sigmaBeefCo2])
    set_param!(m, :farm, :sigmaBeefN2o,       p[:sigmaBeefN2o])
    set_param!(m, :farm, :sigmaDairyMeth,     p[:sigmaDairyMeth])
    set_param!(m, :farm, :sigmaDairyCo2,      p[:sigmaDairyCo2])
    set_param!(m, :farm, :sigmaDairyN2o,      p[:sigmaDairyN2o])
    set_param!(m, :farm, :sigmaPoultryMeth,   p[:sigmaPoultryMeth])
    set_param!(m, :farm, :sigmaPoultryCo2,    p[:sigmaPoultryCo2])
    set_param!(m, :farm, :sigmaPoultryN2o,    p[:sigmaPoultryN2o])
    set_param!(m, :farm, :sigmaPorkMeth,      p[:sigmaPorkMeth])
    set_param!(m, :farm, :sigmaPorkCo2,       p[:sigmaPorkCo2])
    set_param!(m, :farm, :sigmaPorkN2o,       p[:sigmaPorkN2o])
    set_param!(m, :farm, :sigmaEggsMeth,      p[:sigmaEggsMeth])
    set_param!(m, :farm, :sigmaEggsCo2,       p[:sigmaEggsCo2])
    set_param!(m, :farm, :sigmaEggsN2o,       p[:sigmaEggsN2o])
    set_param!(m, :farm, :sigmaSheepGoatMeth, p[:sigmaSheepGoatMeth])
    set_param!(m, :farm, :sigmaSheepGoatCo2,  p[:sigmaSheepGoatCo2])
    set_param!(m, :farm, :sigmaSheepGoatN2o,  p[:sigmaSheepGoatN2o])
    set_param!(m, :farm, :MeatReduc,          p[:MeatReduc])

    # ----- Total Greenhouse Gas Emissions ----- #
    set_param!(m, :emissions, :gsigma1,        p[:gsigma1])
    set_param!(m, :emissions, :dsig,           p[:dsig])
    set_param!(m, :emissions, :e0,             p[:e0])
   # set_param!(m, :emissions, :MIU,            pad_parameter(annual_MIU, end_year - start_dice_year + 1, start_dice_year - start_year, 0))
    set_param!(m, :emissions, :EIndReduc,      p[:EIndReduc])
    set_param!(m, :emissions, :cca0,           p[:cca0])
    set_param!(m, :emissions, :cumetree0,      p[:cumetree0])
    set_param!(m, :emissions, :MethERCP,       rcp_fossil_ch4) # Need to subtract endogenous FARM emissions from RCP scenario in second step.
    set_param!(m, :emissions, :N2oERCP,        rcp_fossil_n2o) # Need to subtract endogenous FARM emissions from RCP scenario in second step.
    set_param!(m, :emissions, :Co2Pulse,       0.0)
    set_param!(m, :emissions, :MethPulse,      0.0)
    set_param!(m, :emissions, :N2oPulse,       0.0)
    set_param!(m, :emissions, :DoubleCountCo2, p[:DoubleCountCo2])
    set_param!(m, :emissions, :ETREE,          pad_parameter(annual_ETREE, end_year - start_dice_year + 1, start_dice_year - start_year, 0))

    # ----- Climate Damages ----- #
    set_param!(m, :damages, :a1, p[:a1])
    set_param!(m, :damages, :a2, p[:a2])
    set_param!(m, :damages, :a3, p[:a3])

    # ----- Net Economy ----- #
    #set_param!(m, :neteconomy, :MIU,      pad_parameter(annual_MIU, end_year - start_dice_year + 1, start_dice_year - start_year, 0))
    set_param!(m, :neteconomy, :expcost2, p[:expcost2])
    set_param!(m, :neteconomy, :pback,    p[:pback])
    set_param!(m, :neteconomy, :gback,    p[:gback])
    set_param!(m, :neteconomy, :S,        pad_parameter(annual_savings, end_year - start_dice_year + 1, start_dice_year - start_year, 0))
    #set_param!(m, :neteconomy, :l,        p[:l])
    set_param!(m, :neteconomy, :CEQ,      p[:CEQ])

    # ----- Welfare ----- #
    #set_param!(m, :welfare, :l,         p[:l])
    set_param!(m, :welfare, :elasmu,    p[:elasmu])
    set_param!(m, :welfare, :rho,       p[:rho])
    set_param!(m, :welfare, :scale1,    p[:scale1])
    set_param!(m, :welfare, :scale2,    p[:scale2])

    #-----------------------------------------------------------------------
    # Create Internal Component Connections
    #-----------------------------------------------------------------------
    connect_param!(m, :grosseconomy, :I,  :neteconomy, :I)
    #connect_param!(m, :grosseconomy, :AL, :totalfactorproductivity, :AL)

    connect_param!(m, :emissions, :YGROSS,    :grosseconomy, :YGROSS)
    connect_param!(m, :emissions, :Co2EFarm,  :farm,         :Co2EFarm)
    connect_param!(m, :emissions, :MethEFarm, :farm,         :MethEFarm)
    connect_param!(m, :emissions, :N2oEFarm,  :farm,         :N2oEFarm)

    # Couple DICE-FARM and FAIR components.
    # Note: DICE-FARM runs from 2015-2500. FAIR runs from 1765-2500. FAIR therefore uses historical RCP emissions, then switches to endogenous DICE-FARM emissions in 2015.
    connect_param!(m, :co2_cycle  => :E_CO₂,            :emissions => :total_CO₂emiss_GtC,   backup_total_RCPco2)
    connect_param!(m, :ch4_cycle  => :fossil_emiss_CH₄, :emissions => :MethE,                backup_fossil_RCPch4)
    connect_param!(m, :n2o_cycle  => :fossil_emiss_N₂O, :emissions => :N2oE,                 backup_fossil_RCPn2o)
    connect_param!(m, :landuse_rf => :landuse_emiss,    :emissions => :landuse_CO₂emiss_GtC, backup_landuse_RCPco2)

    connect_param!(m, :damages, :TATM,   :temperature,  :T)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)

    connect_param!(m, :neteconomy, :YGROSS,  :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMAGES, :damages,      :DAMAGES)
    connect_param!(m, :neteconomy, :SIGMA,   :emissions,    :SIGMA)

    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    # Return initialized version of model.
    return m
end



#Original FAIR values are TCR = 1.6; ECS=2.75
function create_dice_farm(;start_year=1765, end_year=2500, start_dice_year=2015, TCR::Float64=1.69, ECS::Float64=3.1, datafile=joinpath(dirname(@__FILE__), "..", "data", "DICE2016_Excel.xlsm"))

    # Load DICE-FARM parameters to initialize model.
    dicefarm_parameters = getdice2016excelparameters(start_dice_year, end_year, datafile)

    # Initialize and run an instance of DICE-FARM coupled to FAIR to endogenize agriculture emissions.
    dice_farm = initialize_dice_farm(dicefarm_parameters, start_year, end_year, start_dice_year, TCR, ECS)
    run(dice_farm)

    # Need to subtract endogenous FARM CO₂ emissions from exogenous DICE land-use emissions to avoid double-counting.
    new_etree = dice_farm[:emissions, :ETREE] .- dice_farm[:emissions, :Co2EFarm]

    # Subtract agriculture CH4 emissions from exogenous RCP values to avoid double-counting (need to convert FARM emissions from from kg to Mt)
    new_rcp_CH₄ = dice_farm[:emissions, :MethERCP] .- (dice_farm[:emissions, :MethEFarm] / 1e9)

    # Subtract agriculture N2O emissions from exogenous RCP values to avoid double-counting (need to convert FARM emissions from from kg to Mt and from N2O -> N)
    new_rcp_N₂O = dice_farm[:emissions, :N2oERCP] .- (dice_farm[:emissions, :N2oEFarm] / 1e9 * (28.01/44.01))

    # Update exogenous (non-FARM agriculture) emission sources for land use CO₂, CH₄, and N₂O.
    update_param!(dice_farm, :ETREE, new_etree)
    update_param!(dice_farm, :N2oERCP, new_rcp_N₂O)
    update_param!(dice_farm, :MethERCP, new_rcp_CH₄)

    # Return model with updated emission scenarios that fully endogenize the FARM emissions.
    return dice_farm
end
