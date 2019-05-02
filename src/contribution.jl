"""
	contribution(s,o)

Return the contribution of the given node or link in the Stream.
The contribution of a node v in a stream is defined as:
```math
n_v=\\frac{\\left| T_v \\right|}{\\left| T \\right|}
```
The contribution of a link uv in a stream is defined as:
```math
m_{uv}=\\frac{\\left| T_{uv} \\right|}{\\left| T \\right|}
```
Note: If the stream has no duration, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function contribution(s::AbstractStream, o::StreamObject)
	duration(s) != 0 ? duration(o) / duration(s) : 0.0
end

"""
	contribution(ls,n)

Return the contribution of the given node in the link stream.
By definition, this is always 1 since nodes have no dynamics in link streams. 
"""
function contribution(ls::Union{LinkStream,DirectedLinkStream}, n::String)
	return 1.0
end

"""
	contribution(s,n)

Return the contribution of the given node in the stream graph. 
"""
function contribution(s::Union{StreamGraph,DirectedStreamGraph}, n::String)
	contribution(s,s.W[n])
end

"""
	contribution(ls,n,t)

Return the contribution of the given node at the given time in the link stream.
By definition, this is always 1 since nodes have no dynamics in link streams.
"""
function contribution(ls::Union{LinkStream,DirectedLinkStream}, n::String, t::Real)
	return 1.0
end

"""
	contribution(s,from,to)

Return the contribution of the directed link in the directed stream.
"""
function contribution(s::AbstractDirectedStream, from::String, to::String)
	((haskey(s.E,from)) && (haskey(s.E[from],to))) ? contribution(s,s.E[from][to]) : 0
end

"""
	contribution(s,from,to)

Return the contribution of the undirected link in the undirected stream.
This means that contribution(s,from,to)==contribution(s,to,from)
"""
function contribution(s::AbstractUndirectedStream, from::String, to::String)
	if haskey(s.E,from) && haskey(s.E[from],to)
		contribution(s,s.E[from][to])
	elseif haskey(s.E,to) && haskey(s.E[to],from)
		contribution(s,s.E[to][from])
	else
		throw("Unknown link ($(from),$(to)).")
	end
end

"""
	node_contribution(s,t)

Return the node contribution of the given time instant in the stream.
The node contribution of a time instant is defined as:
```math
k_t = \\frac{\\left| V_t \\right|}{\\left| V \\right|}
```
Note: If the stream has no node, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function node_contribution(s::AbstractStream, t::Real)
	length(s.V) != 0 ? length(nodes(s,t)) / length(s.V) : 0.0
end

"""
	node_contribution(s,tc,t)

Return the node contribution of the given time instant in the stream 
using a time cursor.
"""
function node_contribution(s::AbstractStream, tc::TimeCursor, t::Real)
	length(s.V) != 0 ? length(nodes(tc,t)) / length(s.V) : 0.0
end

"""
	link_contribution(s,t)

Return the link contribution of the given time instant in the stream.
The link contribution of a time instant is defined as:
```math
l_t = \\frac{\\left| E_t \\right|}{\\left| V \\otimes V \\right|}
```
Note: If the stream has no node, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function link_contribution(s::AbstractStream, t::Real)
	length(s.V) != 0 ? length(links(s,t)) / length(s.V ⊗ s.V) : 0.0
end

"""
	link_contribution(s,tc,t)

Return the link contribution of the given time instant in the stream using a time cursor.
"""
function link_contribution(s::AbstractStream, tc::TimeCursor, t::Real)
	length(s.V) != 0 ? length(links(tc,t)) / length(s.V ⊗ s.V) : 0.0
end