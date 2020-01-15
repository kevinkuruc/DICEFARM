# DICEFARM

This code is all up and running on my desktop. 

There is one hitch that maybe you know how to solve. So the main thing you'd have to run first is:
"CalibratingDICEFARM.jl"  which sets everything up, and makes the function getcalibratedDICEFARM()

But there is a versions problem on my machine, so I have to first run the function getDICEFARM() once before starting all of this. 

All that is to say, this will run if you do the following:
include("src\\DICEFARM.jl)
getDICEFARM()
include("src\\CalibratingDICEFARM.jl")
m = getcalibratedDICEFARM()
run(m)
