coverage(ls::Union{LinkStream,DirectedLinkStream})=1.0

coverage(s::Union{StreamGraph,DirectedStreamGraph})=((length(s.V)!=0) & (duration(s)!=0)) ? sum([duration(n) for (k,n) in s.W])/(duration(s)*length(s.V)) : 0.0

