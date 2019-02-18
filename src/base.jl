abstract type StreamObject end
abstract type AbstractStream end

# ----------- TUPLES -------------
#
# Equality between tuples of float64 is defined at 10^-6 rouding error
≈(a::Tuple{Float64,Float64},b::Tuple{Float64,Float64};atol::Real=10^-6)=≈(a[1],b[1],atol=atol)&&≈(a[2],b[2],atol=atol)
function ≈(a::Array{Tuple{Float64,Float64}},b::Array{Tuple{Float64,Float64}};atol::Real=10^-6)
    if length(a) != length(b)
        return false
    end
    return all([x[1]≈x[2] for x in zip(a,b)])
end

# ----------- INTERVALS -------------
#
"""
Structure implementing lists of intervals.
These structures are extremely useful when working with stream graphs.
"""
mutable struct Intervals
    list::Array{Tuple{Float64,Float64},1}
end

"""
Equality between two lists of intervals
NOTE: Use approx here because of rounding errors in intervals.
"""
==(i1::Intervals,i2::Intervals)=clean(i1).list≈clean(i2).list

"""
In operator.
Returns true if the given element is inside one of the intervals of the list.
"""
function ∈(x::Float64, i::Intervals)
    for ii in i.list
        if ii[1] <= x <= ii[2]
            return true
        end
    end
    return false
end

"""Returns the number of intervals in the list."""
count(i::Intervals) = length(i.list)

"""Compute the length of a list of intervals as the sum of the interval lengths."""
length(i::Intervals)=sum([ii[2]-ii[1] for ii in i.list])

"""Merge a new interval within a list of intervals."""
merge(i::Intervals, x::Tuple{Float64,Float64})=union(i, Intervals([x]))

"""
Push a new interval at the end of the list.
WARNING: No sorting is done here...
"""
function push(i::Intervals, x::Tuple{Float64,Float64})
    push!(i.list, x)
    return i
end

"""Intersection between two list of intervals."""
function ∩(i1::Intervals, i2::Intervals)
    l = []
    n = 1
    components = vcat(i1.list,i2.list)
    sort!(components)
    push!(l, components[1])
    popfirst!(components)
    for c in components
        modif = false
        if length(l) == 0
            push!(l,c)
            continue
        end
        if c[2] <= l[end][2]
            l[end] = (l[end][1],c[2])
            modif = true
        end
        if c[1] <= l[end][2]
            l[end] = (c[1], l[end][2])
            modif = true
        end   
        if !modif
            pop!(l)
        end
        if n != length(components)
            push!(l,c)
        end
        n = n + 1
    end
    return clean(Intervals(l))
end

"""Union between two lists of intervals."""
function ∪(i1::Intervals, i2::Intervals)
    l = []
    components = union(i1.list,i2.list)
    sort!(components)
    for c in components
        if length(l) == 0 || c[1] > l[end][2]
            push!(l,c)
        elseif c[2] > l[end][2]
            l[end] = (l[end][1], c[2])
        end
    end
    return clean(Intervals(l))
end

function clean(i::Intervals)
    l = []
    sort!(i.list)
    for c in i.list
        if length(l) == 0
            push!(l,c)
            continue
        end
        if c[1] == l[end][2]
            l[end] = (l[end][1],c[2])
            continue
        end
        push!(l,c)
    end
    return Intervals(l)
end
            
"""Is subset returns True if i2 is included within i1."""
⊆(i1::Intervals,i2::Intervals)=(i1 ∩ i2)==clean(i1)
⊆(i1::Tuple{Float64,Float64},i2::Intervals)=Intervals([i1]) ⊆ i2

# ----------- NODE DEFINITIONS -------------
#
mutable struct Node <: StreamObject
    name::AbstractString
    presence::Intervals
end

==(a::Node,b::Node)=(a.name==b.name)&(a.presence==b.presence)

# ----------- LINK DEFINITIONS -------------
#
mutable struct Link <: StreamObject
    name::AbstractString
    presence::Intervals
    from::AbstractString
    to::AbstractString
    weight::Float64
end

==(l1::Link,l2::Link)=(l1.name==l2.name)&(l1.presence==l2.presence)&(l1.from==l2.from)&(l1.to==l2.to)&(l1.weight==l2.weight)

# --- Operations on StreamObjects ---
⊆(i::Intervals,o::StreamObject)=i ⊆ o.presence
⊆(i::Tuple{Float64,Float64},o::StreamObject)=i ⊆ o.presence
⊆(a::StreamObject,b::StreamObject)=a.presence ⊆ b.presence
∈(t::Float64,o::StreamObject)=t ∈ o.presence
∩(a::StreamObject,b::StreamObject)=a.presence ∩ b.presence
∪(a::StreamObject,b::StreamObject)=a.presence ∪ b.presence

duration(o::StreamObject)=length(o.presence)

# --- Operations on Nodes ---
function merge(n1::Node,n2::Node)
    if n1.name!=n2.name
        throw("Cannot merge nodes with different names...")
    end
    return Node(n1.name, n1 ∪ n2)
end

function merge!(n1::Node,n2::Node)
    if n1.name!=n2.name
        throw("Cannot merge nodes with different names...")
    end
    n1.presence = n1 ∪ n2
end

# --- Operations on Links ---
from_match(l1::Link,l2::Link)=(l1.from==l2.from)
from_match(name::AbstractString,l::Link)=(name==l.from)
to_match(l1::Link,l2::Link)=(l1.to==l2.to)
to_match(name::AbstractString,l::Link)=(name==l.to)
match(l1::Link,l2::Link)=from_match(l1,l2)&to_match(l1,l2)
match(from::AbstractString,to::AbstractString,l::Link)=from_match(from,l)&to_match(to,l)

function merge(l1::Link,l2::Link)
    if !match(l1,l2)
        throw("Cannot merge links with different end points...")
    end
    return Link(l1.name, l1 ∪ l2, l1.from, l1.to, l1.weight)
end

function merge!(l1::Link,l2::Link)
    if !match(l1,l2)
        throw("Cannot merge links with different end points...")
    end
    l1.presence = l1 ∪ l2
end

# --- Operations on Vectors of Nodes ---
get_idx(n::Node,a::Vector{Node})=findall(i->i==n,a)
get_idx(name::AbstractString,a::Vector{Node})=findall(i->i.name==name,a)
get_idx(t::Float64,a::Vector{Node})=findall(i->t ∈ i,a)

function ∪(a::Vector{Node},b::Vector{Node})
    c = Vector(Node[])
    for aa in a
        idx = get_idx(aa.name,b)
        if length(idx)==0
            new = Node(aa.name, aa.presence)
        elseif length(idx)==1
            new = Node(aa.name, aa ∪ b[idx][1])
        else
            throw("More than one node named $aa.name in array.")
        end
        push!(c,new)
    end
    for bb in b
        idx = get_idx(bb,a)
        if length(idx)==0
            new = Node(bb.name, bb.presence)
            push!(c,new)
        elseif length(idx)!=1
            throw("More than one node named $aa.name in array.")
        end
    end
    return c
end

function ∩(a::Vector{Node},b::Vector{Node})
    c = Vector(Node[])
    for aa in a
        idx = get_idx(aa.name,b)
        if length(idx)==1
            new = Node(aa.name, aa ∩ b[idx][1])
            push!(c,new)
        elseif length(idx)!=0
            throw("More than one node named $aa.name in array.")
        end
    end
    return c
end

# --- Operations on Vectors of Links ---
from_match(l1::Link,l::Vector{Link})=findall(x->from_match(x,l1),l)
from_match(name::AbstractString,l::Vector{Link})=findall(x->from_match(name,x),l)
to_match(l1::Link,l::Vector{Link})=findall(x->to_match(x,l1),l)
to_match(name::AbstractString,l::Vector{Link})=findall(x->to_match(name,x),l)
match(l1::Link,l::Vector{Link})=findall(x->match(x,l1),l)
match(from::AbstractString,to::AbstractString,l::Vector{Link})=findall(x->match(from,to,x),l)

get_idx(l::Link,a::Vector{Link})=findall(i->i==l,a)
get_idx(name::AbstractString,a::Vector{Link})=findall(i->i.name==name,a)
get_idx(t::Float64,a::Vector{Link})=findall(i->t ∈ i,a)

function ∪(a::Vector{Link},b::Vector{Link})
    c = Vector(Link[])
    for aa in a
        idx = match(aa,b)
        if length(idx)==0
            new = Link(aa.name, aa.presence, aa.from, aa.to, aa.weight)
        elseif length(idx)==1
            new = Link(aa.name, aa ∪ b[idx][1], aa.from, aa.to, aa.weight)
        else
            throw("More than one link matching from $aa.from and to $aa.to in array.")
        end
        push!(c,new)
    end
    for bb in b
        idx = match(bb,a)
        if length(idx)==0
            new = Link(bb.name, bb.presence, bb.from, bb.to, bb.weight)
            push!(c,new)
        elseif length(idx)!=1
            throw("More than one link matching from $aa.from and to $aa.to in array.")
        end
    end
    return c
end

function ∩(a::Vector{Link},b::Vector{Link})
    c = Vector(Link[])
    for aa in a
        idx = match(aa,b)
        if length(idx)==1
            new = Link(aa.name, aa ∩ b[idx][1], aa.from, aa.to, aa.weight)
            push!(c,new)
        elseif length(idx)!=0
            throw("More than one link matching from $aa.from and to $aa.to in array.")
        end
    end
    return c
end

# ----------- STREAM DEFINITIONS -------------
#
struct LinkStream <: AbstractStream
    name::AbstractString
    T::Intervals
    V::Set{AbstractString}
    E::Vector{Link}
end

LinkStream(name) = LinkStream(name, Intervals([]), Set(), [])
LinkStream(name,T) = LinkStream(name, T, Set(), [])

==(ls1::LinkStream,ls2::LinkStream)=(ls1.T==ls2.T)&(ls1.V==ls2.V)&(ls1.E==ls2.E)

struct StreamGraph <: AbstractStream
    name::AbstractString
    T::Intervals
    V::Set{AbstractString}
    W::Vector{Node}
    E::Vector{Link}
end

StreamGraph(name) = StreamGraph(name, Intervals([]), Set(), [], [])
StreamGraph(name,T) = StreamGraph(name, T, Set(), [], [])

==(s1::StreamGraph,s2::StreamGraph)=(s1.T==s2.T)&(s1.V==s2.V)&(s1.W==s2.W)&(s1.E==s2.E)

# ----------- OPERATIONS ON STREAMS -------------
#
∈(t::Float64,s::AbstractStream)=t ∈ s.T
∈(n::Node,s::StreamGraph)=n ∈ s.W
∈(l::Link,s::AbstractStream)=l ∈ s.E
∈(n::AbstractString,s::AbstractStream)=n ∈ s.V
⊆(t::Tuple{Float64,Float64},s::AbstractStream)=t ⊆ s.T
⊆(ls1::LinkStream,ls2::LinkStream)=(ls1.T ⊆ ls2.T)&(ls1.V ⊆ ls2.V)&(ls1.E ⊆ ls2.E)
⊆(s1::StreamGraph,s2::StreamGraph)=(s1.T ⊆ s2.T)&(s1.V ⊆ s2.V)&(s1.W ⊆ s2.W)&(s1.E ⊆ s2.E)
∩(ls1::LinkStream,ls2::LinkStream)=LinkStream("$ls1.name n $ls2.name", ls1.T ∩ ls2.T, ls1.V ∩ ls2.V, ls1.E ∩ ls2.E)
∩(s1::StreamGraph,s2::StreamGraph)=StreamGraph("$s1.name n $s2.name", s1.T ∩ s2.T, s1.V ∩ s2.V, s1.W ∩ s2.W, s1.E ∩ s2.E)
∪(ls1::LinkStream,ls2::LinkStream)=LinkStream("$ls1.name u $ls2.name", ls1.T ∪ ls2.T, ls1.V ∪ ls2.V, ls1.E ∪ ls2.E)
∪(s1::StreamGraph,s2::StreamGraph)=StreamGraph("$s1.name u $s2.name", s1.T ∪ s2.T, s1.V ∪ s2.V, s1.W ∪ s2.W, s1.E ∪ s2.E)

function is_connected(s::AbstractStream, a::AbstractString, b::AbstractString, t::Float64)
    idx = match(a,b,s.E)
    append!(idx,match(b,a,s.E))
    if length(idx)==0
        return false
    elseif length(idx)==1
        return t ∈ s.E[idx][1]
    else
        throw("More than one link with end points $a and $b...")
    end
end

# ----------- ADDING THINGS TO STREAMS -------------
#
function add_node!(ls::LinkStream, n::AbstractString)
    push!(ls.V,n)
end

function add_node!(s::StreamGraph, n::Node)
    idx=get_idx(n.name,s.W)
    if length(idx)==0
        push!(s.V,n.name)
        push!(s.W,n)
    elseif length(idx)==1
        merge!(s.W[idx][1],n)
    else
        throw("More than one node named $n.name in stream $s.name...")
    end
end

function add_link!(s::AbstractStream, l::Link)
    idx=match(l,s.E)
    if length(idx)==0
        push!(s.E,l)
    elseif length(idx)==1
        merge!(s.E[idx][1],l)
    else
        throw("More than one link with end points ($l.from,$l.to)...")
    end
end

function record!(ls::LinkStream, t0::Float64, t1::Float64, from::AbstractString, to::AbstractString)
    if (t0,t1) ⊈ ls
        throw("Stream $ls.name is defined over $ls.T. Invalid link between t0=$t0 and t1=$t1.")
    end
    if from ∉ ls
        add_node!(ls,from)
    end
    if to ∉ ls
        add_node!(ls,to)
    end
    new = Link("$from to $to", Intervals([(t0,t1)]), from, to, 1)
    add_link!(ls,new)
end

function record!(s::StreamGraph, t0::Float64, t1::Float64, n::AbstractString)
    if (t0,t1) ⊈ s
        throw("Stream $ls.name is defined over $ls.T. Invalid link between t0=$t0 and t1=$t1.")
    end
    new = Node(n,Intervals([(t0,t1)]))
    if n ∉ s
        add_node!(s,new)
    else
        idx=get_idx(n,s.W)
        if length(idx)==1
            merge!(s.W[idx][1],new)
        else
            throw("Problem adding node $n in stream $s.name.")
        end
    end
end

function record!(s::StreamGraph, t0::Float64, t1::Float64, from::AbstractString, to::AbstractString)
    if (t0,t1) ⊈ s
        throw("Stream $ls.name is defined over $ls.T. Invalid link between t0=$t0 and t1=$t1.")
    end
    if from ∉ s
        add_node!(s,from)
    end
    if to ∉ s
        add_node!(s,to)
    end
    new = Link("$from to $to", Intervals([(t0,t1)]), from, to, 1)
    add_link!(ls,new)
end

# ----------- READ FROM FILES -------------
#
function load!(s::AbstractStream, f::AbstractString; Δ=1)
    open(f) do file
        for line in eachline(file)
            t0,t1,u,v = parse_line(line;Δ=Δ)
            record!(s,t0,t1,u,v)
        end
    end
end

function parse_line(line::AbstractString; Δ=1)
    line = strip(line)
    elements = split(line," ")
    if length(elements)==4
        t0,t1,u,v = elements
        t0 = parse(Float64,t0)
        t1 = parse(Float64,t1)
    elseif length(elements)==3
        t,u,v = elements
        t = parse(Float64,t)
        t0 = t - Δ / 2
        t1 = t + Δ /2
    else
        throw("Unknown line format: $line")
    end
    return t0,t1,u,v
end


# ----------- METRICS OF STREAMS -------------
#
duration(s::AbstractStream)=length(s.T)
node_duration(ls::LinkStream)=duration(ls)

function node_duration(s::StreamGraph)
    if length(s.W)!=0
        return sum([duration(n) for n in s.W]) / length(s.V)
    else
        throw("There is 0 node in stream $s.name...")
    end
end

function link_duration(s::AbstractStream)
    if length(s.E)!=0
        return 2 * sum([duration(l) for l in s.E]) / (length(s.V)*(length(s.V)-1))
    else
        throw("There is 0 link in stream $s.name...")
    end
end

function contribution(s::AbstractStream, o::StreamObject)
    if duration(s)!=0
        return duration(o) / duration(s)
    else
        throw("Stream $s.name has no duration...")
    end
end

contribution(ls::LinkStream, node_name::AbstractString)=1

function contribution(s::StreamGraph, node_name::AbstractString)
    idx=get_idx(node_name,s.W)
    if length(idx)==1
        return contribution(s,s.W[idx][1])
    else
        throw("Cannot compute contribution of node $node_name.")
    end
end

function contribution(s::AbstractStream, from::AbstractString, to::AbstractString)
    idx=match(from,to,s.E)
    if length(idx)==1
        return contribution(s,s.E[idx][1])
    else
        throw("Cannot compute contribution of link ($from,$to).")
    end
end

number_of_nodes(s::StreamGraph)=sum([contribution(s,n) for n in s.W])
number_of_nodes(ls::LinkStream)=length(ls.V)
number_of_links(s::AbstractStream)=sum([contribution(s,l) for l in s.E])

density(ls::LinkStream)=2 * sum([duration(l) for l in ls.E]) / (length(ls.V)*(length(ls.V)-1)*duration(ls)) 

function density(ls::LinkStream, n1::AbstractString, n2::AbstractString)
    idx_link = match(n1,n2,ls.E)
    if length(idx_link) == 1
        return duration(ls.E[idx_link][1]) / duration(ls)
    elseif length(idx_link) == 0
        return 0
    else
        throw("More than one link in stream $ls.name with from name $n1 and to name $n2.")
    end
end