"""
	duration(o)

Return the cardinal of the presence intervals of the given object.
"""
function duration(o::StreamObject)
	return cardinal(o.presence)
end

"""
	duration(s)

Return the duration of the stream.
"""
function duration(s::AbstractStream)
	return cardinal(s.T)
end

"""
	duration(W)

Return the sum of the nodes' durations in W.
"""
function duration(W::Dict{String,Node})
	length(W) != 0 ? sum([duration(v) for (k,v) in W]) : 0.0
end

"""
	node_duration(ls)

Return the node duration in the given Link Stream.
By definition, this is just the duration of the link stream itself.
"""
function node_duration(ls::Union{LinkStream,DirectedLinkStream})
	return duration(ls)
end

"""
	node_duration(s)

Return the node duration in the given Stream Graph.
The node duration is computed as:
```math
k = \\frac{\\left| W \\right|}{\\left| V \\right|}
```
Note: If the stream has no node, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function node_duration(s::Union{StreamGraph,DirectedStreamGraph})
	length(s.V) > 0 ? duration(s.W) / length(s.V) : 0
end

"""
	node_duration(s,tc)

Return the node duration in the given Stream Graph using a TimeCursor.
In this case, the node duration is computed as:
```math
k = \\int_{k \\in T} k_t dt
```
Where
```math
k_t=\\frac{\\left| V_t \\right|}{\\left| V \\right|}
```
is the node contributions of a time instant t.
Note: If the stream has no node, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function node_duration(s::Union{StreamGraph,DirectedStreamGraph}, tc::TimeCursor)
	k::Real = 0
	length(s.V) == 0 && return 0.0
	start!(tc)
	k += duration(tc.S) * number_of_nodes(tc)
	while tc.S.t1 < s.T.list[1][2]
		next!(tc)
		k += duration(tc.S) * number_of_nodes(tc)
	end
	k / length(s.V)
end

"""
	link_duration(s)

Return the link duration in the given Stream.
The link duration is computed as:
```math
l = \\frac{\\left| E \\right|}{\\left| V \\otimes V \\right|}
```
Note: If the stream has no node, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function link_duration(s::AbstractStream)
	length(s.V) > 1 ? 2 * sum([duration(l) for (k,v) in s.E for (kk,l) in v]) / (length(s.V) * (length(s.V) - 1)) : 0
end

"""
	link_duration(s,tc)

Return the link duration in the given Stream using a TimeCursor.
In this case, the link duration is computed as:
```math
l = \\int_{t \\in T} l_t dt
```
Where
```math
l_t = \\frac{ \\left| E_t \\right|}{\\left| V \\otimes V \\right|}
```
is the link contributions of a time instant t.
Note: If the stream has no node, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function link_duration(s::AbstractStream, tc::TimeCursor)
	k::Real = 0
	length(s.V) <= 1 && return 0.0
	start!(tc)
	k += duration(tc.S) * number_of_links(tc)
	while tc.S.t1 < s.T.list[1][2]
		next!(tc)
		k += duration(tc.S) * number_of_links(tc)
	end
	k / (length(s.V) * (length(s.V) - 1))
end

"""
	duration(s)

Return the duration of a given state.
"""
function duration(s::State)
	s.t1 - s.t0
end

"""
	duration(j)

Return the duration of a given DurationJump.
"""
function duration(j::DurationJump)
	j.δ
end

"""
	duration(p)

Return the duration of a given Path.
"""
function duration(p::AbstractPath)
	finish(p) - start(p)
end
