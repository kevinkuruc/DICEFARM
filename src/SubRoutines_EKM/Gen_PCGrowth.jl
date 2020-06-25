function Gen_PCGrowth(m)
	run(m)
	CPC = m[:neteconomy, :CPC][2015-1764:end]
	pop = m[:welfare, :l]
	T   = length(CPC)
	PCGrowth = ones(T)
	Cumulative_PC_growth = ones(T)
		for t = 2:T
			if t<=100
			PCGrowth[t] = (1+.25*log(CPC[t]/CPC[t-1]))
			else
			PCGrowth[t] = 1.
			end
			
			for j = 1:t
					Cumulative_PC_growth[t] = Cumulative_PC_growth[t]*PCGrowth[j]  
			end
 		end
data_directory = joinpath(dirname(pwd()), "data")
df=DataFrame(PCGrowth=Cumulative_PC_growth)
CSV.write(joinpath(data_directory, "PC_Growth.csv"), df)
end