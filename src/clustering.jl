"""
    node_clustering(s,v)

Return the clustering coefficient of the given node v in stream s:
```math
cc \\left(v \\right) = \\frac{ \\sum_{uw \\in V \\otimes V} \\left| T_{vu} \\cap T_{vw} \\cap T_{uw} \\right| }{\\sum_{uw \\in V \\otimes V} \\left| T_{vu} \\cap T_{vw} \\right|}
```
Note: If node v never has two neighbors present at the same
time in the stream, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function node_clustering(s::AbstractUndirectedStream, v::AbstractString)
    nomin=0
    denom=0
    N=Set(AbstractString[])
    for n in keys(neighborhood(s,v))
        push!(N,n)
    end
    for (u,w) in N ⊗ N
        nomin+=length((times(s,v,u) ∩ times(s,v,w)) ∩ times(s,u,w))
        denom+=length(times(s,v,u) ∩ times(s,v,w))
    end
    denom != 0 ? nomin/denom : 0.0
end

"""
    node_clustering(s,v,t)

Return the instantaneous clustering coefficient of the given node v
at the given time t in the given stream:
```math
cc_t \\left(v \\right)= \\frac{\\sum_{uw} vu_t vw_t uw_t}{\\sum_{uw} vu_t vw_t}
```
Note: If node v does not have two neighbors at the given
time t, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function node_clustering(s::AbstractUndirectedStream,v::AbstractString,t::Float64)
    Nt=Set(AbstractString[])
    for n in neighborhood(s,v,t)
        push!(Nt,n)
    end
    nom=sum([1.0 for (u,w) in Nt ⊗ Nt if ((t ∈ times(s,v,u)) & (t ∈ times(s,v,w)) & (t ∈ times(s,u,w)))])
    denom=sum([1.0 for (u,w) in Nt ⊗ Nt if ((t ∈ times(s,v,u)) & (t ∈ times(s,v,w)))])
    denom != 0 ? nom/denom : 0.0
end

"""
    node_clustering(s)

Return the node clustering coefficient of the given stream:
```math
cc \\left( V \\right)= \\frac{1}{n} \\sum_{v \\in V} n_v cc \\left( v \\right) = \\sum_{v \\in V} \\frac{\\left| T_v \\right|}{\\left|W \\right|} cc \\left(v \\right)
```
Where n is the number of nodes in the stream.
Note: If there is no node in the stream, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function node_clustering(s::AbstractUndirectedStream)
    if length(s.V)>0
        1.0/length(s.V)*sum([contribution(s,v)*node_clustering(s,v) for v in s.V])
    else
        0.0
    end
end

"""
    time_clustering(s,t)

Return time clustering coefficient of a given time instant in the stream:
```math
cc \\left( t \\right)= \\frac{\\sum_{v}cc_t\\left(v \\right) \\sum_{uw} vu_t vw_t}{\\sum_{v} \\sum_{uw} vu_t vw_t}
```

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function time_clustering(s::AbstractUndirectedStream,t::Float64)
    nom::Float64=0.0
    denom::Float64=0.0
    for v in s.V
        acc::Float64=0.0
        for (u,w) in s.V ⊗ s.V
            if ((t ∈ times(s,v,u)) & (t ∈ times(s,v,w)))
                acc+=1.0
            end
        end
        nom+=node_clustering(s,v,t) * acc
        denom+=acc
    end
    denom != 0 ? nom/denom : 0.0
end

"""
    time_clustering(s)

Return the time clustering coefficient of the given stream:
```math
cc \\left( T \\right) = \\int_{t} \\frac{\\left| V_t \\right|}{\\left| W \\right|} cc \\left( t \\right) dt
```
Note: If nodes are never present in the stream, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function time_clustering(s::AbstractUndirectedStream)
    τ = times(s)
    dW = duration(s.W)
    dW != 0 ? 1.0/dW*sum([time_clustering(s,0.5*(t[2]+t[1])) * length(nodes(s,0.5*(t[2]+t[1]))) for t in zip(τ[1:end-1],τ[2:end])]) : 0.0
end

"""
    time_clustering(s)

Return the time clustering coefficient of the given stream using a TimeCursor.
"""
function time_clustering(s::AbstractUndirectedStream,tc::TimeCursor)
    throw("Not Implemented")
end

"""
    clustering(s)

Return the clustering coefficient of the given stream:
```math
cc \\left( S \\right) = \\int_t \\frac{1}{\\left|T \\right|} \\sum_{v} \\frac{cc_t\\left(v \\right)}{\\left|V \\right|} dt
```

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function clustering(s::AbstractUndirectedStream)
    card_TV = duration(s)*length(s.V)
    if card_TV==0
        return 0.0
    end
    τ = times(s)
    acc::Float64 = 0.0
    for v in s.V
        for t in zip(τ[1:end-1],τ[2:end])
            acc+=node_clustering(s,v,0.5*(t[1]+t[2]))*(t[2]-t[1])
        end
    end
    1.0/card_TV*acc
end

