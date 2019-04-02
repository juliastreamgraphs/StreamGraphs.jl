"""
	degree(s,node)

Return the degree of the given node in the givn stream.

```math
d \\left(v \\right)= \\left| \\mathcal{N} \\left(v\\right) \\right|
```

Where 

```math
\\mathcal{N} \\left(v\\right)=\\left\\{ \\left(t,u\\right),\\ \\left(t,uv \\right) \\in E}
```

is the neighborhood of node v.
Note: If the stream has a duration of 0, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function degree(s::AbstractUndirectedStream,node::AbstractString)
	duration(s)!=0 ? duration(neighborhood(s,node))/duration(s) : 0.0
end

"""
	degree(s,node,tc)

Return the degree of the given node in the given stream using a TimeCursor.
Note: Not implemented yet...
"""
function degree(s::AbstractUndirectedStream,node::AbstractString,tc::TimeCursor)
	throw("Not Implemented")
end

"""
	degree(s,node,t)

Return the instantaneous degree of the given node at the given time in the given stream.
```math
d_t \\left(v \\right)= \\left| \\mathcal{N}_t \\left(v\\right) \\right|
```

Where 

```math
\\mathcal{N}_t\\left(v\\right)=\\left\\{ u,\\ \\left(t,uv \\right) \\in E}
```

is the instantaneous neighborhood of node v.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function degree(s::AbstractUndirectedStream,node::AbstractString,t::Float64)
	length(neighborhood(s,node,t))
end

"""
	degree(s,t)

Return the degree at t of the stream s.
```math
d\\left(t\\right) = \\sum_v \\frac{d_t \\left(v \\right)}{\\left|V\\right||}
```
Note: If the stream has no node, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function degree(s::AbstractUndirectedStream,t::Float64)
	length(s.V) != 0 ? 1.0/length(s.V)*sum([degree(s,v,t) for v in s.V]) : 0.0
end

"""
	degree(s)

Return the degree of the stream s.
```math
d\\left(S\\right)= \\sum_v \\frac{1}{\\left|V\\right|}d\\left(v\\right)
```
Note: If the stream has no node, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function degree(s::AbstractUndirectedStream)
	length(s.V) != 0 ? 1.0/length(s.V)*sum([degree(s,v) for v in s.V]) : 0.0
end

"""
	degree(s,tc)

Return the degree of stream s using a TimeCursor.
In this case, the degree is computed using:
```math
d\\left(S\\right)= \\int_t \\frac{1}{\\left|T\\right|}d\\left(t\\right) dt
```
Note: If the stream has no node or a duration of 0, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function degree(s::AbstractUndirectedStream,tc::TimeCursor)
	((duration(s)==0) | (length(s.V)==0)) && 0.0
	start!(tc)
	δ=collect(values(degrees(tc.S)))
	d::Float64=sum(δ)*duration(tc.S)
	while tc.S.t1 < s.T.list[1][2]
        next!(tc)
        δ=collect(values(degrees(tc.S)))
        d+=sum(δ)*duration(tc.S)
    end
    1.0/(duration(s)*length(s.V))*d
end

"""
	average_node_degree(s)

Return the average node degree of the given stream graph.
```math
d\\left(V\\right)=\\frac{1}{n} \\sum_{v \\in V} n_v d\\left( v \\right)
```
Note: If card(W)=0, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function average_node_degree(s::StreamGraph)
	duration(s.W)!=0 ? 1.0/duration(s.W)*sum([length(times(s,v))*degree(s,v) for v in s.V]) : 0.0
end

"""
	average_node_degree(ls)

Return the average node degree of the given link stream.
For link streams, the average node degree simplifies to:
```math
d\\left(L\\right) = \\frac{2 m}{n}
```
Note: If the link stream has no node, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function average_node_degree(ls::LinkStream)
	number_of_nodes(ls)!=0 ? 2.0*number_of_links(ls)/number_of_nodes(ls) : 0.0
end

"""
	average_time_degree(s)

Return the average time degree of the given stream.
```math
d\\left(T\\right)=\\int_t \\frac{\\left|V_t\\right|}{\\left|W\\right|} d\\left(t\\right) dt
```
Note: If the node duration is 0, this function returns 0.

Warning: This function is very inefficient, use `average_time_degree(s,tc)` if possible.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function average_time_degree(s::AbstractStream)
    k = node_duration(s)
    τ = times(s)
    k != 0 ? 1.0/k*sum([node_contribution(s,0.5*(t[2]+t[1]))*degree(s,0.5*(t[2]+t[1]))*(t[2]-t[1]) for t in zip(τ[1:end-1],τ[2:end])]) : 0.0
end

"""
	average_time_degree(s,tc)

Return the average time degree of the given stream using a TimeCursor.
"""
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

"""
	degrees(s)

Return the degree distribution of the graph corresponding to the given state.
"""
function degrees(S::State)
	l=String[]
	for ll in S.links
    	push!(l,ll[1])
    	push!(l,ll[2])
	end
	ul=unique(l)
	Dict([(i,count(x->x==i,l)) for i in ul])
end

"""
	average_degree(s)

Return the average degree of the graph corresponding to the given state.
"""
function average_degree(S::State)
	d=collect(values(degrees(S)))
	length(d)==0 && 0.0
	sum(d)/length(d)
end

"""
	degrees(tc)

Return the degree distribution of the cursor's current state.
"""
degrees(tc::TimeCursor)=degrees(tc.S)

"""
	average_degree(tc)

Return the average degree of the cursor's current state.
"""
average_degree(tc::TimeCursor)=average_degree(tc.S)

"""
	expected_degree(s,node)

Return the expected degree of the given node in the given stream.
Note: Not implemented yet...
"""
function expected_degree(s::AbstractStream,node::AbstractString)
	throw("Not Implemented")
end

"""
	expected_degree(s,node,tc)

Return the expected degree of the given node in the given stream using a TimeCursor.
```math
\\hat{d}\\left(v\\right)=\\int_t \\frac{d_t \\left(v\\right)}{\\left|T_v\\right|} dt
```

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function expected_degree(s::AbstractStream,node::AbstractString,tc::TimeCursor)
	Tv=times(s,node)
	length(Tv)==0 && 0.0
	start!(tc)
	δ=degrees(tc.S)
	d::Float64=0
	if haskey(δ,node)
		d+=δ[node]*duration(tc.S)
	end
    while tc.S.t1 < s.T.list[1][2]
        next!(tc)
        δ=degrees(tc.S)
        if haskey(δ,node)
        	d+=δ[node]*duration(tc.S)
        end
    end
    1.0/length(Tv)*d
end

"""
	expected_degree(s,node,t)

Return the expected degree of the given node at the given time in the given stream.
Note: Not implemented yet...
"""
function expected_degree(s::AbstractStream,node::AbstractString,t::Float64)
	throw("Not Implemented")
end

"""
	expected_degree(s,node,t,tc)

Return the expected degree of the given node at the given time in the given 
stream using a TimeCursor.
Note: Not implemented yet...
"""
function expected_degree(s::AbstractStream,node::AbstractString,t::Float64,tc::TimeCursor)
	throw("Not Implemented")
end

"""
	average_expected_degree(s)

Return the average expected degree of the given stream.
```math
\\hat{d}\\left(S\\right)=\\frac{2 m}{n}
```
Note: If the stream has no node, this function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function average_expected_degree(s::AbstractStream)
	number_of_nodes(s)!=0 ? 2 * number_of_links(s) / number_of_nodes(s) : 0.0
end