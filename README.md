# DICEFARM

DICEFARM is used in two projects: (1) The high climate costs of animal based foods (EKM) and (2) Optimal Animal Agriculture Under Environmental and Population Externalities (SCW). 

The model itself is constructed in DICEFARM.jl; and the modifications for SCW are located in "AnimalWefareModel.jl" in the "Subroutines_SCW" folder.

### How To Install Required Packages

This code runs on [Julia v1.2 or later](https://julialang.org/downloads/) and requires several Julia packages. 

(1) To install these packages, first enter the package manager by hitting the `]` key in the Julia console. Once in the package manager, run the following code:

```julia
add CSV  
add DataFrames  
add ExcelReaders
add Interpolations
add Mimi  
add Plots
add Roots
add StatsPlots
```

(2) While still in the package manager, run the following line to install the Mimi implementation of the [FAIR v1.3 simple climate model](https://gmd.copernicus.org/articles/11/2273/2018/):

```julia
add https://github.com/FrankErrickson/MimiFAIR13.jl.git
```

(3) To exit back to Julia, hit the `backspace` key. 


### Run DICEFARM and View Results

(1) First, [Clone or download](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository) the `DICEFARM` Git repository. Once this is on your computer, set this folder as your working directory in the Julia console.

(2) Run the following code to get an instance of the DICEFARM model and view results:

```julia
# Load the file to create the DICEFARM model.
include("src/DICEFARM.jl")

# Create an instance of the model.
m = create_dice_farm()

# Run the model.
run(m)

# View the projected global temperature anomalies (syntax is model_name[:component_name, :variable_name]).
m[:temperature, :T]

# If you want to see interactive plots of all model output, run the following code.
explore(m)
```

### Run Paper Replication Code

```julia
# To reproduce the results from "The High Climate Costs of Animal Based Foods," run the following file:
include("src/The_high_social_costs_of_animal_based_foods_ALLRESULTS.jl")
```
