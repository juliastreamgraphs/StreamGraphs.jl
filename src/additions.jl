
"""
    add_node!(ls,n)

Add node n to the LinkStream ls.
Arguments:
    - ls::LinkStream : LinkStream.
    - n::String : Name of the node to be added.
"""
function add_node!(ls::Union{LinkStream,DirectedLinkStream}, n::String)
    if n in ls.V
        println("Warning: Node $(n) already in LinkStream $(ls.name).")
    end
    push!(ls.V,n)
end

"""
    add_node(s,n)

Add node n to the StreamGraph s.
Arguments:
    - s::StreamGraph : StreamGraph.
    - n::Node : Node to be added.
"""
function add_node!(s::Union{StreamGraph,DirectedStreamGraph}, n::Node)
    if n.name ∉ s
        push!(s.V,n.name)
        s.W[n.name] = n
    else
        merge!(s.W[n.name],n)
    end
end

"""
    add_link!(ls,l)

Add link l to the directed LinkStream ls.
Arguments:
    - ls::DirectedLinkStream : LinkStream.
    - l::Link : Link to be added.
"""
function add_link!(ls::DirectedLinkStream, l::Link)
    if l.from ∉ ls
        add_node!(ls,l.from)
    end
    if l.to ∉ ls
        add_node!(ls,l.to)
    end
    if !haskey(ls.E,l.from)
        ls.E[l.from] = Dict()
    end
    if !haskey(ls.E[l.from],l.to)
        ls.E[l.from][l.to] = l
    else
        merge!(ls.E[l.from][l.to],l)
    end
end

"""
    add_link!(ls,l)

Add link l to the LinkStream ls.
Arguments:
    - ls::LinkStream : LinkStream.
    - l::Link : Link to be added.
"""
function add_link!(ls::LinkStream, l::Link)
    if l.from ∉ ls
        add_node!(ls,l.from)
    end
    if l.to ∉ ls
        add_node!(ls,l.to)
    end
    if l.to < l.from
        l.from,l.to=l.to,l.from
    end
    if !haskey(ls.E,l.from)
        ls.E[l.from] = Dict()
    end
    if !haskey(ls.E[l.from],l.to)
        ls.E[l.from][l.to] = l
    else
        merge!(ls.E[l.from][l.to],l)
    end
end

"""
    add_link!(s,l)

Add link l to the directed StreamGraph s.
Arguments:
    - s::DirectedStreamGraph : StreamGraph.
    - l::Link : Link to be added.
"""
function add_link!(s::DirectedStreamGraph, l::Link)
    if l.from ∉ s
        new_from = Node(l.from, l.presence)
        add_node!(s,new_from)
    elseif l.presence ⊈ s.W[l.from].presence
        new_from = Node(l.from, l.presence)
        merge!(s.W[l.from],new_from)
    end
    if l.to ∉ s
        new_to = Node(l.to, l.presence)
        add_node!(s,new_to)
    elseif l.presence ⊈ s.W[l.to].presence
        new_to = Node(l.to, l.presence)
        merge!(s.W[l.to],new_to)
    end
    if !haskey(s.E,l.from)
        s.E[l.from] = Dict()
    end
    if !haskey(s.E[l.from],l.to)
        s.E[l.from][l.to] = l
    else
        merge!(s.E[l.from][l.to],l)
    end
end

"""
    add_link!(s,l)

Add link l to the StreamGraph s.
Arguments:
    - s::StreamGraph : StreamGraph.
    - l::Link : Link to be added.
"""
function add_link!(s::StreamGraph, l::Link)
    if l.from ∉ s
        new_from = Node(l.from, l.presence)
        add_node!(s,new_from)
    elseif l.presence ⊈ s.W[l.from].presence
        new_from = Node(l.from, l.presence)
        merge!(s.W[l.from],new_from)
    end
    if l.to ∉ s
        new_to = Node(l.to, l.presence)
        add_node!(s,new_to)
    elseif l.presence ⊈ s.W[l.to].presence
        new_to = Node(l.to, l.presence)
        merge!(s.W[l.to],new_to)
    end
    if l.to < l.from
        l.from,l.to=l.to,l.from
    end
    if !haskey(s.E,l.from)
        s.E[l.from] = Dict()
    end
    if !haskey(s.E[l.from],l.to)
        s.E[l.from][l.to] = l
    else
        merge!(s.E[l.from][l.to],l)
    end
end

"""
    record!(s,t0,t1,from,to)

Record a new link in stream s between node from and to between t0 and t1.
Arguments:
    - s::AbstractStream : Stream entity.
    - t0::Real : Starting time of the new link.
    - t1::Real : Ending time of the new link.
    - from::String : Name of the from node.
    - to::String : Name of the to node.
"""
function record!(s::AbstractStream, t0::Real, t1::Real, from::String, to::String)
    if (t0,t1) ⊈ s
        throw("Stream $(s.name) is defined over $(string(s.T)). Invalid link between t0=$(t0) and t1=$(t1).")
    end
    new = Link("$from to $to", t0, t1, from, to)
    add_link!(s,new)
end

"""
    record!(s,t0,t1,n)

Record a new node's presence in stream s between t0 and t1.
Arguments:
    - s::Union{StreamGraph,DirectedStreamGraph} : StreamGraph.
    - t0::Real : Arrival time of the node.
    - t1::Real : Departure time of the node.
    - n::String : Name of the node.
"""
function record!(s::Union{StreamGraph,DirectedStreamGraph}, t0::Real, t1::Real, n::String)
    if (t0,t1) ⊈ s
        throw("Stream $(s.name) is defined over $(string(s.T)). Invalid link between t0=$(t0) and t1=$(t1).")
    end
    new = Node(n,t0,t1)
    add_node!(s,new)
end
