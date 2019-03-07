function density(ls::Union{LinkStream,DirectedLinkStream})
    ((length(ls.V)==0) | (length(ls.E)==0)) && 0.0
    nom=2 * sum([duration(l) for (k,v) in ls.E for (kk,l) in v])
    denom=(length(ls.V)*(length(ls.V)-1)*duration(ls))
    denom != 0 ? nom/denom : 0.0
end

function density(ls::Union{LinkStream,DirectedLinkStream},tc::TimeCursor)
    ((length(ls.V)==0) | (length(ls.E)==0) | (duration(ls)==0)) && 0.0
    start!(tc)
    d::Float64=density(tc)*duration(tc.S)
    while tc.S.t1 < s.T.list[1][2]
        next!(tc)
        d+=density(tc)*duration(tc.S)
    end
    1.0/duration(ls)*d
end

function density(s::Union{StreamGraph,DirectedStreamGraph})
    ((length(s.V)==0) | (length(s.E)==0)) && 0.0
    denom = sum([length(times(s,u) ∩ times(s,v)) for (u,v) in s.V ⊗ s.V])
    denom != 0 ? sum([duration(l) for (k,v) in s.E for (kk,l) in v]) / denom : 0
end

function density(s::Union{StreamGraph,DirectedStreamGraph},tc::TimeCursor)
    ((length(s.V)==0) | (length(s.E)==0)) && 0.0
    start!(tc)
    nom::Float64=duration(tc.S)*number_of_links(tc)
    denom::Float64=duration(tc.S)*length(nodes(tc) ⊗ nodes(tc))
    while tc.S.t1 < s.T.list[1][2]
        next!(tc)
        nom+=duration(tc.S)*number_of_links(tc)
        denom+=duration(tc.S)*length(nodes(tc) ⊗ nodes(tc))
    end
    denom != 0 ? nom / denom : 0
end

density(ls::Union{LinkStream,DirectedLinkStream}, t::Float64)=length(ls.V)>1 ? 2 * sum([duration(l) for l in links(ls,t)])/(length(ls.V)*(length(ls.V)-1)) : 0

function density(s::Union{StreamGraph,DirectedStreamGraph}, t::Float64)
    Vt=Set{AbstractString}(nodes(s,t))
    length(Vt)!=0 ? length(links(s,t))/length(Vt ⊗ Vt) : 0.0
end

density(ls::Union{LinkStream,DirectedLinkStream},n1::AbstractString,n2::AbstractString)=duration(ls)!=0 ? duration(links(ls,n1,n2))/duration(ls) : 0

function density(s::Union{StreamGraph,DirectedStreamGraph},n1::AbstractString,n2::AbstractString)
    denom=length(times(s,n1) ∩ times(s,n2))
    denom != 0 ? length(times(s,n1,n2))/denom : 0.0
end

function density(s::AbstractStream,n::AbstractString)
    nom=sum([length(times(s,u,n)) for u in s.V if u != n])
    denom=sum([length(times(s,u) ∩ times(s,n)) for u in s.V if u != n])
    denom != 0 ? nom/denom : 0.0
end

density(tc::TimeCursor)=number_of_nodes(tc) > 1 ? (2*number_of_links(tc))/(number_of_nodes(tc)*(number_of_nodes(tc)-1)) : 0.0

function density(tc::TimeCursor,t::Float64)
    n=number_of_nodes(tc,t)
    m=number_of_links(tc,t)
    n > 1 ? (2*m)/(n*(n-1)) : 0.0
end

function density(tc::TimeCursor,t0::Float64,t1::Float64)
    n=number_of_nodes(tc,t0,t1)
    m=number_of_links(tc,t0,t1)
    n > 1 ? (2*m)/(n*(n-1)) : 0.0
end
