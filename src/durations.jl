duration(o::StreamObject)=length(o.presence)

duration(s::AbstractStream)=length(s.T)

duration(W::Dict{AbstractString,Node})=sum([duration(v) for (k,v) in W])

node_duration(ls::Union{LinkStream,DirectedLinkStream})=duration(ls)

node_duration(s::Union{StreamGraph,DirectedStreamGraph})=length(s.V)>0 ? sum([duration(n) for (k,n) in s.W])/length(s.V) : 0

link_duration(s::AbstractStream)=length(s.V)>1 ? 2*sum([duration(l) for (k,v) in s.E for (kk,l) in v])/(length(s.V)*(length(s.V)-1)) : 0

duration(s::State)=s.t1-s.t0

duration(j::DurationJump)=j.δ

duration(p::AbstractPath)=finish(p)-start(p)
