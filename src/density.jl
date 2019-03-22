"""
    density(ls)

Return the density of the link stream.
For a link stream the classical graph relation holds
and we have:
```math
\\delta \\left( L \\right)= \\frac{2 m}{n \\left( n-1 \\right)}
```
Note: For link streams with less than 2 nodes, this
function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function density(ls::Union{LinkStream,DirectedLinkStream})
    length(ls.V) > 1 ? 2*number_of_links(ls)/(number_of_nodes(ls)*(number_of_nodes(ls)-1)) : 0.0
end

"""
    density(s)

Return the density of the stream graph defined as:
```math
\\delta \\left( S \\right) = \\frac{ \\sum_{uv \\in V \\otimes V} \\left| T_{uv} \\right| }{\\sum_{uv \\in V \\otimes V} \\left| T_u \\cap T_v \\right|}
```
Note: For link streams with no node and/or no link, this
function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function density(s::Union{StreamGraph,DirectedStreamGraph})
    ((length(s.V)==0) | (length(s.E)==0)) && 0.0
    denom = sum([length(times(s,u) ∩ times(s,v)) for (u,v) in s.V ⊗ s.V])
    denom != 0 ? sum([duration(l) for (k,v) in s.E for (kk,l) in v]) / denom : 0
end

"""
    density(s,tc)

Return the density of the stream graph using a TimeCursor.
In this case, the density is computed as:
```math
\\delta \\left( S \\right) = \\frac{ \\int_{t \\in T} \\left| E_t \\right| dt }{\\int_{t \\in T} \\left| V_t \\otimes V_t \\right| dt}
```
Note: For link streams with no node and/or no link, this
function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function density(s::Union{StreamGraph,DirectedStreamGraph},tc::TimeCursor)
    ((length(s.V)==0) | (length(s.E)==0)) && 0.0
    start!(tc)
    nom::Float64=duration(tc.S)*number_of_links(tc)
    denom::Float64=duration(tc.S)*length(nodes(tc) ⊗ nodes(tc))
    while tc.S.t1 < s.T.list[1][2]
        next!(tc)
        nom+=duration(tc.S)*number_of_links(tc)
        denom+=duration(tc.S)*length(nodes(tc) ⊗ nodes(tc))
    end
    denom != 0 ? nom / denom : 0
end

"""
    density(s,t)

Density at a time instant t in the given stream graph, defined as:
```math
\\delta \\left( t \\right) = \\frac{ \\left| E_t \\right|}{\\left| V_t \\otimes V_t \\right|}
```
Note: If there is no node involved at t, this
function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function density(s::Union{StreamGraph,DirectedStreamGraph}, t::Float64)
    Vt=Set{AbstractString}(nodes(s,t))
    length(Vt)!=0 ? length(links(s,t))/length(Vt ⊗ Vt) : 0.0
end

"""
    density(ls,t)

Density at a time instant t in the given link stream.
In a link stream, the density of a time instant reduces to:
```math
\\delta \\left( t \\right) = \\frac{ \\left| E_t \\right|}{\\left| V \\otimes V \\right|} = l_t
```
Note: For link streams with less than 2 nodes, this
function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function density(ls::Union{LinkStream,DirectedLinkStream}, t::Float64)
    length(ls.V)>1 ? 2 * sum([duration(l) for l in links(ls,t)])/(length(ls.V)*(length(ls.V)-1)) : 0
end

"""
    density(s,n1,n2)

Density of the pair of nodes (n1,n2) in the given stream graph, defined as:
```math
\\delta \\left( uv \\right) = \\frac{ \\left| T_{uv} \\right|}{\\left| T_u \\cap T_v \\right|}
```
Note: If u and v are never involved at the same time, this
function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function density(s::Union{StreamGraph,DirectedStreamGraph},n1::AbstractString,n2::AbstractString)
    denom=length(times(s,n1) ∩ times(s,n2))
    denom != 0 ? length(times(s,n1,n2))/denom : 0.0
end

"""
    density(ls,n1,n2)

Density of the pair of nodes (n1,n2) in the given link stream.
In a link stream, the density of a pair of nodes reduces to:
```math
\\delta \\left( uv \\right) = \\frac{ \\left| T_{uv} \\right|}{\\left| T \\right|}
```
Note: If the link stream has a duration of 0, this
function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function density(ls::Union{LinkStream,DirectedLinkStream},n1::AbstractString,n2::AbstractString)
    duration(ls)!=0 ? duration(links(ls,n1,n2))/duration(ls) : 0
end

"""
    density(s,n)

Density of a node in the given stream, defined as:
```math
\\delta \\left( v \\right) = \\frac{ \\sum_{u \\in V,u \\neq v} \\left| T_{uv} \\right|}{\\sum_{u \\in V,u \\neq v} \\left| T_u \\cap T_v \\right|}
```
Note: If there is no node present at the same time as v, this
function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function density(s::AbstractStream,n::AbstractString)
    nom=sum([length(times(s,u,n)) for u in s.V if u != n])
    denom=sum([length(times(s,u) ∩ times(s,n)) for u in s.V if u != n])
    denom != 0 ? nom/denom : 0.0
end

"""
  density(tc)

Return the density of the graph representing the current
state of the TimeCursor.
"""
function density(tc::TimeCursor)
    number_of_nodes(tc) > 1 ? (2*number_of_links(tc))/(number_of_nodes(tc)*(number_of_nodes(tc)-1)) : 0.0
end

"""
  density(tc,t)

Return the density of the graph representing the state of 
the TimeCursor at time t.
"""
function density(tc::TimeCursor,t::Float64)
    n=number_of_nodes(tc,t)
    m=number_of_links(tc,t)
    n > 1 ? (2*m)/(n*(n-1)) : 0.0
end

"""
  density(tc,t0,t1)

Return the density of the aggregated graph representing the states of 
the TimeCursor at between time t0 and t1.
"""
function density(tc::TimeCursor,t0::Float64,t1::Float64)
    n=number_of_nodes(tc,t0,t1)
    m=number_of_links(tc,t0,t1)
    n > 1 ? (2*m)/(n*(n-1)) : 0.0
end
