uniformity(ls::Union{LinkStream,DirectedLinkStream})=1.0

function uniformity(s::Union{StreamGraph,DirectedStreamGraph})
    if length(s.V)==0
        return 0.0
    end
    nom=sum([length(times(s,u) ∩ times(s,v)) for (u,v) in s.V ⊗ s.V])
    denom=sum([length(times(s,u) ∪ times(s,v)) for (u,v) in s.V ⊗ s.V])
    denom != 0 ? nom/denom : 0.0
end
