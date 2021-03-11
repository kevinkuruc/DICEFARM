#Timestep conversion function
function getindexfromyear_dice_2016(year)
    baseyear = 2015

    if rem(year - baseyear, 5) != 0
        error("Invalid year")
    end

    return div(year - baseyear, 5) + 1
end



#Get parameters from DICE2016 excel sheet
#range is the range of cell values on the excel sheet and must be a string, "B56:B77"
#parameters = :single for just one value, or :all for entire time series
#sheet is the sheet in the excel file to reference (i.e. "Base")
#T is the length of the time period (i.e 100)

#example:   getparams("B15:BI15", :all, "Base",  100)


function getparams(f, range::String, parameters::Symbol, sheet::String, T)

    if parameters == :single
        data = readxl(f, "$(sheet)!$(range)")
        vals = Float64(data[1])

    elseif parameters == :all
        data = readxl(f, "$(sheet)!$(range)")
        s = size(data)

        if length(s) == 2 && s[1] == 1
            # convert 2D row vector to 1D col vector
            data = vec(data)
        end

        dims = length(size(data))
        vals = Array{Float64, dims}(data)
    end

    return vals
end


#######################################################################################################################
# LINEARLY INTERPOLATE DICE RESULTS TO ANNUAL VALUES
#######################################################################################################################
# Description: This function uses linear interpolation to create an annual time series from DICE results (which have
#              five year timesteps).
#
# Function Arguments:
#
#       data    = The DICE results to be interpolated
#       spacing = Length of model time steps (5 for DICE).
#----------------------------------------------------------------------------------------------------------------------

function dice_interpolate(data, spacing)

    # Create an interpolation object for the data (assume first and last points are end points, e.g. no interpolation beyond support).
    interp_linear = interpolate(data, BSpline(Linear()), OnGrid())

    # Create points to interpolate for (based on spacing term).
    interp_points = collect(1:(1/spacing):length(data))

    # Carry out interpolation.
    return interp_linear[interp_points]
end


#########################################################################################################################
# SET EMISSIONS INTENSITIES (IN REGIONAL RUNS WHERE THIS SWITCHES)
#########################################################################################################################
# Description: This function takes a 6x3 matrix of Animal Products x Emissions intensities and sets the intensities for
#              farm module
#
# Function Arguments: 
#           m           = model to set parameters of
#           intesities  = 6x3 Matrix of emissions intensities for: Beef, Dairy, Poultry, Pork, Eggs, Sheep/Goats; Co2, CH4, N20
#------------------------------------------------------------------------------------------------------------------------

function set_intensities(m, intensities)
    set_param!(m, :farm, :sigmaBeefCo2, intensities[1,1])    
    set_param!(m, :farm, :sigmaBeefMeth, intensities[1,2])
    set_param!(m, :farm, :sigmaBeefN2o, intensities[1,3])
    set_param!(m, :farm, :sigmaDairyCo2, intensities[2,1])
    set_param!(m, :farm, :sigmaDairyMeth, intensities[2,2])
    set_param!(m, :farm, :sigmaDairyN2o, intensities[2,3])
    set_param!(m, :farm, :sigmaPoultryCo2, intensities[3,1])
    set_param!(m, :farm, :sigmaPoultryMeth, intensities[3,2])
    set_param!(m, :farm, :sigmaPoultryN2o, intensities[3,3])
    set_param!(m, :farm, :sigmaPorkCo2, intensities[4,1])
    set_param!(m, :farm, :sigmaPorkMeth, intensities[4,2])
    set_param!(m, :farm, :sigmaPorkN2o, intensities[4,3])
    set_param!(m, :farm, :sigmaEggsCo2, intensities[5,1])
    set_param!(m, :farm, :sigmaEggsMeth, intensities[5,2])
    set_param!(m, :farm, :sigmaEggsN2o, intensities[5,3]) 
    set_param!(m, :farm, :sigmaSheepGoatCo2, intensities[6,1])
    set_param!(m, :farm, :sigmaSheepGoatMeth, intensities[6,2])
    set_param!(m, :farm, :sigmaSheepGoatN2o, intensities[6,3])  
end

function pad_parameters(p::Dict, time_len::Int,  begin_padding::Number, end_padding::Number)

    padded_p = deepcopy(p)

    for key in keys(p)
        values = p[key]
        size(values,1) == time_len ? padded_p[key] = pad_parameters(values, time_len, begin_padding, end_padding) :  padded_p[key] = values
    end

    return padded_p
end

function pad_parameter(data::Array, time_len::Number, begin_padding::Number, end_padding::Number)
    size(data, 1) != time_len ? error("time dimension must match rows") : nothing

    new_data = deepcopy(data)
    if begin_padding != 0
        begin_padding_rows = Array{Union{Missing, Number}}(missing, begin_padding, size(data, 2)) 
        new_data = vcat(begin_padding_rows, new_data)
    end

    if end_padding != 0
        end_padding_rows = Array{Union{Missing, Number}}(missing, end_padding, size(data, 2)) 
        new_data = vcat(new_data, end_padding_rows)
    end

    ndims(data) == 1 ? new_data = new_data[:,1] : nothing 

    return new_data
end