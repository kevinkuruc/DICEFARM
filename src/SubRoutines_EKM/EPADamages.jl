function EPADamages(Cons1::Array, BaseCons::Array, rho::Float64)
	Damages = BaseCons-Cons1
	discount = ones(length(Damages))
		for i = 2:length(Damages)
			discount[i] = (1-rho)*discount[i-1] 
		end
	DiscountedDamages = discount.*Damages
	Tot = sum(DiscountedDamages)
	return Tot
end