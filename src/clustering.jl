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

function node_clustering(s::AbstractUndirectedStream,v::AbstractString,t::Float64)
    Nt=Set(AbstractString[])
    for n in neighborhood(s,v,t)
        push!(Nt,n)
    end
    nom=sum([1.0 for (u,w) in Nt ⊗ Nt if ((t ∈ times(s,v,u)) & (t ∈ times(s,v,w)) & (t ∈ times(s,u,w)))])
    denom=sum([1.0 for (u,w) in Nt ⊗ Nt if ((t ∈ times(s,v,u)) & (t ∈ times(s,v,w)))])
    denom != 0 ? nom/denom : 0.0
end

node_clustering(s::AbstractUndirectedStream)=length(s.V)>0 ? 1.0/length(s.V)*sum([contribution(s,v)*node_clustering(s,v) for v in s.V]) : 0.0

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

function time_clustering(s::AbstractUndirectedStream)
    τ = times(s)
    dW = duration(s.W)
    dW != 0 ? 1.0/dW*sum([time_clustering(s,0.5*(t[2]+t[1])) * length(nodes(s,0.5*(t[2]+t[1]))) for t in zip(τ[1:end-1],τ[2:end])]) : 0.0
end

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

