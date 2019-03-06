==(a::Node,b::Node)=(a.name==b.name)&(a.presence==b.presence)

nodes(ls::Union{LinkStream,DirectedLinkStream})=ls.V

nodes(ls::Union{LinkStream,DirectedLinkStream},t::Float64)=ls.V

nodes(ls::Union{LinkStream,DirectedLinkStream},t0::Float64,t1::Float64)=ls.V

nodes(s::Union{StreamGraph,DirectedStreamGraph},t::Float64)=[n for (n,interv) in s.W if t ∈ interv]

nodes(s::Union{StreamGraph,DirectedStreamGraph})=[b for (a,b) in s.W]

nodes(s::Union{StreamGraph,DirectedStreamGraph},t0::Float64,t1::Float64)=t0<=t1 ? [n for (n,interv) in s.W if Intervals([(t0,t1)]) ⊆ interv] : []

nodes(tc::TimeCursor)=tc.S.nodes

function nodes(tc::TimeCursor,t::Float64)
    goto!(tc,t)
    if haskey(tc.T,t)
        s1=nodes(tc)
        previous!(tc)
        return s1 ∪ nodes(tc)
    else
        return nodes(tc)
    end
end

function nodes(tc::TimeCursor,t0::Float64,t1::Float64)
    N=Set{AbstractString}()
    goto!(tc,t0)
    haskey(tc.T,t0) && previous!(tc)
    N=N ∪ nodes(tc)
    while tc.S.t1 < t1
        next!(tc)
        N=N ∪ nodes(tc)
    end
    if haskey(tc.T,t1)
        next!(tc)
        N=N ∪ nodes(tc)
    end
    N
end
