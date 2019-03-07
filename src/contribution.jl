contribution(s::AbstractStream, o::StreamObject)=duration(s)!=0 ? duration(o) / duration(s) : 0.0

contribution(ls::Union{LinkStream,DirectedLinkStream},node_name::AbstractString)=1.0

contribution(ls::Union{LinkStream,DirectedLinkStream},node_name::AbstractString,t::Float64)=1.0

contribution(s::Union{StreamGraph,DirectedStreamGraph},node_name::AbstractString)=contribution(s,s.W[node_name])

contribution(s::AbstractDirectedStream, from::AbstractString, to::AbstractString)=haskey(s.E,from)&haskey(s.E[from],to) ? contribution(s,s.E[from][to]) : 0

contribution(s::AbstractUndirectedStream, from::AbstractString, to::AbstractString)=from<=to ? contribution(s,s.E[from][to]) : contribution(s,s.E[to][from])

node_contribution(s::AbstractStream,t::Float64)=length(s.V) != 0 ? length(nodes(s,t))/length(s.V) : 0.0

node_contribution(s::AbstractStream,tc::TimeCursor,t::Float64)=length(s.V) != 0 ? length(nodes(tc,t))/length(s.V) : 0.0

link_contribution(s::AbstractStream,t::Float64)=length(s.V) != 0 ? length(links(s,t))/length(s.V ⊗ s.V) : 0.0

link_contribution(s::AbstractStream,tc::TimeCursor,t::Float64)=length(s.V) != 0 ? length(links(tc,t))/length(s.V ⊗ s.V) : 0.0