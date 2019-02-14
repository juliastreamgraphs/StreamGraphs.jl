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
    from::Node
    to::Node
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

# --- Operations on Links ---
from_match(l1::Link,l2::Link)=(l1.from==l2.from)
to_match(l1::Link,l2::Link)=(l1.to==l2.to)
match(l1::Link,l2::Link)=from_match(l1,l2)&to_match(l1,l2)

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
to_match(l1::Link,l::Vector{Link})=findall(x->to_match(x,l1),l)
match(l1::Link,l::Vector{Link})=findall(x->match(x,l1),l)

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

==(ls1::LinkStream,ls2::LinkStream)=(ls1.T==ls2.T)&(ls1.V==ls2.V)&(ls1.E==ls2.E)

struct StreamGraph <: AbstractStream
    name::AbstractString
    T::Intervals
    V::Set{AbstractString}
    W::Vector{Node}
    E::Vector{Link}
end

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