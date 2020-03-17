using CSV
using DataFrames
include("VegSocialCosts.jl")
# Define Intensities

function DietaryCostsByCountry()

d= CSV.read(joinpath(dirname(@__FILE__), "..", "data", "2013Diets.csv"))
VegCosts = zeros(size(d)[1], 2)
ESEA_Intensities 	= [49.9 8.85 .266	; 19.92 2.17 .069	; 35.7 .031 .049; 26.7 .81 .053	; 26.9 0.05 .039; 30.0 4.36 .13]
EEU_Intensities  	= [29.9 2.11 .07	; 10.1 1.84 .03		; 14.4 .02 .02	; 25.1 .35 .03	; 8.2 .02 .03	; 14.3 1.84 .05]
LatAm_Intensities 	= [141.84 7.89 .24	; 13.15 2.9 .24		; 25.44 .02 .02	; 27.4 .62 0.04	; 16.9 .17 .02	; 12.46 6.29 .13]
MidEast_Intensities = [16.04 5.62 .43	; 14.9 3.48 .25		; 27.34 .02 .03	; 39.9 0.65 .04	; 14.2 .1 .02	; 24.3 5.32 .4]
NO_Intensities 		= [14.08 3.67 .14	; 14.4 1.44 .02		; 14.35 .02 .02	; 15.24 .61 .02	; 7.57 .12 .02	; 22.3 4.17 .18]
Oceania_Intensities = [21.7 4.39 .22	; 15.02 2.93 .10	; 28.4 .02 .02	; 25.02 2.01 .02; 12.8 .05 .02	; 16.25 2.93 .10]
Russia_Intensities 	= [27.0 2.08 .06	; 8.8 1.23 .03		; 17.9  .02 .01	; 20.8  .28  .03; 9.08 .02  .01	; 13.06 4.14 .12]
SAS_Intensities		= [58.46 12.7 .32	; 25.14 3.31 .10	; 21.5 1.52 .05	; 24.3 .02 .04	; 14.03 .07 .03	; 36.6 6.94 .16]
SSA_Intensities 	= [5.9 11.3 .41		; 5.6 5.23 .16		; 28.5 .04 .03	; 13.3 1.17 .04	; 10.8 .08 .04	; 6.28 7.28 .20]
WEU_Intensities		= [26.4 2.6 .12		; 12.2 0.99 .04		; 23.9 .02 .02	; 27.2 .46 .04	; 15.2 .02 .02	; 18.9 2.44 .09]
test = create_dice_farm();
for i = 1:length(VegCosts[:,1])
    Diets = zeros(6)
    Diets[1] = d[i, :bovine]
    Diets[2] = d[i, :milk]
    Diets[3] = d[i, :poultry]
    Diets[4] = d[i, :pig]
    Diets[5] = d[i, :eggs]
    Diets[6] = d[i, :muttongoat]
    if d[i, :gleam_region]=="ne_na"
        intensity = MidEast_Intensities
    elseif d[i, :gleam_region]=="s_asia"
        intensity = SAS_Intensities
    elseif d[i, :gleam_region]=="w_europe"
        intensity = WEU_Intensities
    elseif d[i, :gleam_region]=="ssa"
        intensity = SSA_Intensities
    elseif d[i, :gleam_region]=="lac"
        intensity = LatAm_Intensities
    elseif d[i, :gleam_region]=="oceania"
        intensity = Oceania_Intensities
    elseif d[i, :gleam_region]=="northam"
        intensity = NO_Intensities
    elseif d[i, :gleam_region]=="e_se_asia"
        intensity = ESEA_Intensities
    elseif d[i, :gleam_region]=="e_europe"
        intensity = EEU_Intensities
    elseif d[i, :gleam_region]=="russianfed"
        intensity = Russia_Intensities
    end
    sol = VegSocialCosts(Diets, intensity)
    VegCosts[i,1] = sol[1,2]
    VegCosts[i,2] = sol[2,2]
    Country = d[i, :country]
    println("Finished $Country")
end

out = DataFrame(Country = d[:country], VeganCosts = VegCosts[:,1], VegetarianCosts = VegCosts[:,2])
return out

end