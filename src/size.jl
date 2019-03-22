"""
	number_of_nodes(s)

Return the number of nodes in the Stream Graph.
The number of nodes in a Stream Graph is defined as:
```math
n=\\sum_{v \\in V} n_v = \\frac{\\left| W \\right|}{\\left| T \\right|}
```
Where
```math
n_v=\\frac{\\left| T_v \\right|}{\\left| T \\right|}
```
is the contribution of node v.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function number_of_nodes(s::Union{StreamGraph,DirectedStreamGraph})
	length(s.W) != 0 ? sum([contribution(s,n) for (k,n) in s.W]) : 0.0
end

"""
	number_of_nodes(ls)

Return the number of nodes in the Link Stream.
The number of nodes in a Link Stream reduces to:
```math
n=\\left| V \\right|
```

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
number_of_nodes(ls::Union{LinkStream,DirectedLinkStream})=length(ls.V)

"""
	number_of_nodes(s)

Return the number of nodes in a state.
"""
number_of_nodes(s::State)=length(s.nodes)

"""
	number_of_nodes(tc)

Return the number of nodes at the cursor's current state.
"""
number_of_nodes(tc::TimeCursor)=length(nodes(tc))

"""
	number_of_nodes(tc,t)

Return the number of nodes in Gt using a time cursor.
"""
number_of_nodes(tc::TimeCursor,t::Float64)=length(nodes(tc,t))

"""
	number_of_nodes(tc,t0,t1)

Return the number of nodes which presence intersects with [t0;t1] using a time cursor.
"""
number_of_nodes(tc::TimeCursor,t0::Float64,t1::Float64)=length(nodes(tc,t0,t1))

"""
	number_of_links(s)

Return the number of links in the Stream.
The number of links in a Stream is defined as:
```math
m=\\sum_{uv \\in V \\otimes V} m_{uv} = \\frac{\\left| E \\right|}{\\left| T \\right|}
```
Where
```math
m_{uv}=\\frac{\\left| T_{uv} \\right|}{\\left| T \\right|}
```
is the contribution of the pair of nodes uv.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function number_of_links(s::AbstractStream)
	length(s.E) != 0 ? sum([contribution(s,l) for (k,v) in s.E for (kk,l) in v]) : 0.0
end

"""
	number_of_links(s)

Return the number of links in a state.
"""
number_of_links(s::State)=length(s.links)

"""
	number_of_links(tc)

Return the number of links in a cursor's current state.
"""
number_of_links(tc::TimeCursor)=number_of_links(tc.S)

"""
	number_of_links(tc,t)

Return the number of links present at a given time using a time cursor.
"""
number_of_links(tc::TimeCursor,t::Float64)=length(links(tc,t))

"""
	number_of_links(tc,t0,t1)

Return the number of links which presence intersects with [t0;t1] using a time cursor.
"""
number_of_links(tc::TimeCursor,t0::Float64,t1::Float64)=length(links(tc,t0,t1))

"""
	length(p)

Return the number of jumps in a path.
"""
length(p::AbstractPath)=length(p.jumps)
