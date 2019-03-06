function add_node!(ls::Union{LinkStream,DirectedLinkStream}, n::AbstractString)
    push!(ls.V,n)
end

function add_node!(s::Union{StreamGraph,DirectedStreamGraph}, n::Node)
    if n.name ∉ s
        push!(s.V,n.name)
        s.W[n.name] = n
    else
        merge!(s.W[n.name],n)
    end
end

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

function record!(s::AbstractStream, t0::Float64, t1::Float64, from::AbstractString, to::AbstractString)
    if (t0,t1) ⊈ s
        throw("Stream $(s.name) is defined over $(s.T). Invalid link between t0=$t0 and t1=$t1.")
    end
    new = Link("$from to $to", Intervals([(t0,t1)]), from, to, 1)
    add_link!(s,new)
end

function record!(s::Union{StreamGraph,DirectedStreamGraph}, t0::Float64, t1::Float64, n::AbstractString)
    if (t0,t1) ⊈ s
        throw("Stream $(s.name) is defined over $(s.T). Invalid link between t0=$t0 and t1=$t1.")
    end
    new = Node(n,Intervals([(t0,t1)]))
    add_node!(s,new)
end
