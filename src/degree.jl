function degree(s::AbstractUndirectedStream,node::AbstractString)
	duration(s)!=0 ? duration(neighborhood(s,node))/duration(s) : 0.0
end

function degree(s::AbstractUndirectedStream,node::AbstractString,t::Float64)
	length(neighborhood(s,node,t))
end

function degree(s::AbstractUndirectedStream,t::Float64)
	length(s.V) != 0 ? 1.0/length(s.V)*sum([degree(s,v,t) for v in s.V]) : 0.0
end

function degree(s::AbstractUndirectedStream)
	length(s.V) != 0 ? 1.0/length(s.V)*sum([degree(s,v) for v in s.V]) : 0.0
end

function average_node_degree(ls::LinkStream)
	number_of_nodes(ls)!=0 ? 2.0*number_of_links(ls)/number_of_nodes(ls) : 0.0
end

function average_node_degree(s::StreamGraph)
	duration(s.W)!=0 ? 1.0/duration(s.W)*sum([length(times(s,v))*degree(s,v) for v in s.V]) : 0.0
end

function average_time_degree(s::AbstractStream)
    k = node_duration(s)
    τ = times(s)
    k != 0 ? 1.0/k*sum([node_contribution(s,0.5*(t[2]+t[1]))*degree(s,0.5*(t[2]+t[1]))*(t[2]-t[1]) for t in zip(τ[1:end-1],τ[2:end])]) : 0.0
end

function average_time_degree(s::AbstractStream,tc::TimeCursor)
	length(s.V)==0 && 0.0
	dW=duration(s.W)
	dW==0 && 0.0
	start!(tc)
	δ=collect(values(degrees(tc.S)))
	d::Float64=sum(δ)/length(s.V)*number_of_nodes(tc)*duration(tc.S)
    while tc.S.t1 < s.T.list[1][2]
        next!(tc)
        δ=collect(values(degrees(tc.S)))
        d+=sum(δ)/length(s.V)*number_of_nodes(tc)*duration(tc.S)
    end
    1.0/dW*d
end

function degrees(S::State)
	l=String[]
	for ll in S.links
    	push!(l,ll[1])
    	push!(l,ll[2])
	end
	ul=unique(l)
	Dict([(i,count(x->x==i,l)) for i in ul])
end

function average_degree(S::State)
	d=collect(values(degrees(S)))
	length(d)==0 && 0.0
	sum(d)/length(d)
end

degrees(tc::TimeCursor)=degrees(tc.S)

average_degree(tc::TimeCursor)=average_degree(tc.S)