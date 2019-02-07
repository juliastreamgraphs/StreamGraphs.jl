# Equality between tuples of float64 is defined at 10^-6 rouding error
≈(a::Tuple{Float64,Float64},b::Tuple{Float64,Float64};atol::Real=10^-6)=≈(a[1],b[1],atol=atol)&&≈(a[2],b[2],atol=atol)
function ≈(a::Array{Tuple{Float64,Float64}},b::Array{Tuple{Float64,Float64}};atol::Real=10^-6)
    if length(a) != length(b)
        return false
    end
    return all([x[1]≈x[2] for x in zip(a,b)])
end