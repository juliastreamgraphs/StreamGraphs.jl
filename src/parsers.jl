function parse_line_auv(line::AbstractString, Δ::Float64)
    line = strip(line)
    elts = split(line," ")
    length(elts) != 3 && throw("Format auv expects lines with three elements.")
    t,u,v = elts
    t = parse(Float64,t)
    t0 = t - Δ / 2
    t1 = t + Δ /2
    t0,t1,u,v
end

parse_line_auv(line::AbstractString)=parse_line_auv(line,1.0)

function parse_line_abuv(line::AbstractString)
    line = strip(line)
    elts = split(line," ")
    length(elts) != 4 && throw("Format abuv expects lines with four elements.")
    t0,t1,u,v = elts
    t0 = parse(Float64,t0)
    t1 = parse(Float64,t1)
    t0,t1,u,v
end

parse_line_abuv(line::AbstractString,Δ::Float64)=parse_line_abuv(line)

parsers=Dict("auv"=>parse_line_auv,
             "abuv"=>parse_line_abuv
            )

function parse_line(line::AbstractString,format::AbstractString)
    haskey(parsers,format) ? parsers[format](line) : throw("Unknown format $format")
end

function parse_line(line::AbstractString,format::AbstractString,Δ::Float64)
    haskey(parsers,format) ? parsers[format](line,Δ) : throw("Unknown format $format")
end

function load!(s::AbstractStream, f::AbstractString, format::AbstractString)
    open(f) do file
        for line in eachline(file)
            t0,t1,u,v = parse_line(line,format)
            record!(s,t0,t1,u,v)
        end
    end
end

function load!(s::AbstractStream, f::AbstractString, format::AbstractString, Δ::Float64)
    open(f) do file
        for line in eachline(file)
            t0,t1,u,v = parse_line(line,format,Δ)
            record!(s,t0,t1,u,v)
        end
    end
end

function string(e::Event)
    if typeof(e)==LinkEvent
        e.arrive ? "$(e.t) + $(e.object[1]) $(e.object[2])" : "$(e.t) - $(e.object[1]) $(e.object[2])"
    elseif typeof(e)==NodeEvent
        e.arrive ? "$(e.t) + $(e.object)" : "$(e.t) - $(e.object)"
    else
        throw("Unknown type for event object.")
    end
end

function parse_to_events(f::AbstractString,format::AbstractString,Δ::Float64)
    format ∉ ["auv","abuv"] && throw("Only auv and abuv formats can be parsed to events.")
    D=Dict{Tuple{AbstractString,AbstractString},Array{Float64,1}}()
    events=Event[]
    open(f) do file
        for line in eachline(file)
            t0,t1,u,v = parse_line(line,format,Δ)
            if haskey(D,(u,v))
                if t0 > D[(u,v)][2]
                    push!(events,LinkEvent(D[(u,v)][1],true,(u,v)))
                    push!(events,LinkEvent(D[(u,v)][2],false,(u,v)))
                    D[(u,v)]=[t0,t1]
                else
                    D[(u,v)][2]=t1
                end
            else
                D[(u,v)]=[t0,t1]
            end
        end
    end
    for (obj,interv) in D
        push!(events,LinkEvent(interv[1],true,obj))
        push!(events,LinkEvent(interv[2],false,obj))
    end
    sort!(events, by = v -> v.t)
end

function dump(f::AbstractString,events::Vector{Event})
    open(f,"w") do file
        for event in events
            write(file,"$(string(event))\n")
        end
    end
end
