number_of_nodes(s::Union{StreamGraph,DirectedStreamGraph})=length(s.W) != 0 ? sum([contribution(s,n) for (k,n) in s.W]) : 0.0

number_of_nodes(ls::Union{LinkStream,DirectedLinkStream})=length(ls.V)

number_of_nodes(s::State)=length(s.nodes)

number_of_nodes(tc::TimeCursor)=number_of_nodes(tc.S)

number_of_nodes(tc::TimeCursor,t::Float64)=length(nodes(tc,t))

number_of_nodes(tc::TimeCursor,t0::Float64,t1::Float64)=length(nodes(tc,t0,t1))

number_of_links(s::AbstractStream)=length(s.E) != 0 ? sum([contribution(s,l) for (k,v) in s.E for (kk,l) in v]) : 0.0

number_of_links(s::State)=length(s.links)

number_of_links(tc::TimeCursor)=number_of_links(tc.S)

number_of_links(tc::TimeCursor,t::Float64)=length(links(tc,t))

number_of_links(tc::TimeCursor,t0::Float64,t1::Float64)=length(links(tc,t0,t1))

length(p::AbstractPath)=length(p.jumps)
