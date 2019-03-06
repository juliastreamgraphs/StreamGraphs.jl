
__precompile__()

"""
Module for studying stream graphs and link streams.
"""

module StreamGraphs

#######################################
# Imports

import Base.≈
import Base.==
import Base.∈
import Base.∪
import Base.∩
import Base.⊆
import Base.+
import Base.-
import Base: length, count, match, merge, merge!, string

abstract type AbstractStream end
abstract type AbstractDirectedStream <: AbstractStream end
abstract type AbstractUndirectedStream <: AbstractStream end
abstract type StreamObject end
abstract type AbstractPath end
abstract type Event end

########################################
# Exports

export 

		# Stream components
		Intervals, Node, Link, LinkStream, StreamGraph,
		DirectedLinkStream, DirectedStreamGraph,
		times, nodes, links, links_from, links_to,
		neighborhood, degree, average_node_degree,
		average_time_degree, State, Transition, TimeCursor,

		# Paths
		Jump, DurationJump, Path, DurationPath,

		# Adding to streams
		add_node!, add_link!, record!, load!, parse_line,

		# Durations
		duration, node_duration, link_duration, contribution,
		number_of_nodes, number_of_links, density, node_contribution,
		link_contribution,

		node_clustering, time_clustering, clustering, coverage, 
		uniformity,

		Δnodes, Δlinks, apply!, next_transition, previous_transition,
		next!, previous!, goto!, start!, end!, Event, NodeEvent, LinkEvent,

		parse_line_auv, parse_line_abuv, parse_line, parse_to_events,
		string, dump,

		# functions
		count, length, merge, merge!, push, clean, from_match, to_match, 
		match, get_idx, is_connected, is_valid, start, finish,

		# Operators
		==, ≈, ∈, ∪, ∩, ⊆, +, -, ×, ⊗

#######################################
# Includes

include("sets.jl")
include("intervals.jl")
include("base.jl")
include("nodes.jl")

end
