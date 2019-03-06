function -(S1::Set{T},S2::Set{T}) where T
    setdiff(S1,S2)
end

function ×(S1::Set{T},S2::Set{T}) where T
    S=Set()
    for s1 in S1
        for s2 in S2
            push!(S,(s1,s2))
        end
    end
    S
end

function ⊗(S1::Set{T},S2::Set{T}) where T
    S=Set()
    for s1 in S1
        for s2 in S2
            if s1<s2
                push!(S,(s1,s2))
            elseif s2<s1
                push!(S,(s2,s1))
            end
        end
    end
    S
end
