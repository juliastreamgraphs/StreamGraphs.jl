duration(o::StreamObject)=length(o.presence)

duration(s::AbstractStream)=length(s.T)

duration(W::Dict{AbstractString,Node})=sum([duration(v) for (k,v) in W])

node_duration(ls::Union{LinkStream,DirectedLinkStream})=duration(ls)

function node_duration(s::Union{StreamGraph,DirectedStreamGraph})
	length(s.V)>0 ? sum([duration(n) for (k,n) in s.W])/length(s.V) : 0
end

function node_duration(s::Union{StreamGraph,DirectedStreamGraph},tc::TimeCursor)
	k::Float64=0.0
	length(s.V)==0 && return 0.0
	start!(tc)
	k+=duration(tc.S)*number_of_nodes(tc)
	while tc.S.t1 < s.T.list[1][2]
		next!(tc)
		k+=duration(tc.S)*number_of_nodes(tc)
	end
	k/length(s.V)
end

function link_duration(s::AbstractStream)
	length(s.V)>1 ? 2*sum([duration(l) for (k,v) in s.E for (kk,l) in v])/(length(s.V)*(length(s.V)-1)) : 0
end

function link_duration(s::AbstractStream,tc::TimeCursor)
	k::Float64=0.0
	length(s.V)<=1 && return 0.0
	start!(tc)
	k+=duration(tc.S)*number_of_links(tc)
	while tc.S.t1 < s.T.list[1][2]
		next!(tc)
		k+=duration(tc.S)*number_of_links(tc)
	end
	k/(length(s.V)*(length(s.V)-1))
end

duration(s::State)=s.t1-s.t0

duration(j::DurationJump)=j.δ

duration(p::AbstractPath)=finish(p)-start(p)
