degree(s::AbstractUndirectedStream,node::AbstractString)=duration(s)!=0 ? duration(neighborhood(s,node))/duration(s) : 0.0

degree(s::AbstractUndirectedStream,node::AbstractString,t::Float64)=length(neighborhood(s,node,t))

degree(s::AbstractUndirectedStream,t::Float64)=length(s.V) != 0 ? 1.0/length(s.V)*sum([degree(s,v,t) for v in s.V]) : 0.0

degree(s::AbstractUndirectedStream)=length(s.V) != 0 ? 1.0/length(s.V)*sum([degree(s,v) for v in s.V]) : 0.0

average_node_degree(ls::LinkStream)=number_of_nodes(ls)!=0 ? 2.0*number_of_links(ls)/number_of_nodes(ls) : 0.0

average_node_degree(s::StreamGraph)=duration(s.W)!=0 ? 1.0/duration(s.W)*sum([length(times(s,v))*degree(s,v) for v in s.V]) : 0.0

function average_time_degree(s::AbstractStream)
    k = node_duration(s)
    τ = times(s)
    k != 0 ? 1.0/k*sum([node_contribution(s,0.5*(t[2]+t[1]))*degree(s,0.5*(t[2]+t[1]))*(t[2]-t[1]) for t in zip(τ[1:end-1],τ[2:end])]) : 0.0
end

