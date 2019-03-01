
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
import Base: length, count, match, merge, merge!

########################################
# Exports

export 

		# Stream components
		Intervals, Node, Link, LinkStream, StreamGraph,
		DirectedLinkStream, DirectedStreamGraph,
		times, nodes, links, links_from, links_to,
		neighborhood, degree, average_node_degree,

		# Paths
		Jump, DurationJump, Path, DurationPath,

		# Adding to streams
		add_node!, add_link!, record!, load!, parse_line,

		# Durations
		duration, node_duration, link_duration, contribution,
		number_of_nodes, number_of_links, density,

		node_clustering, coverage, uniformity,

		# functions
		count, length, merge, merge!, push, clean, from_match, to_match, 
		match, get_idx, is_connected, is_valid, start, finish,

		# Operators
		==, ≈, ∈, ∪, ∩, ⊆, +, ×, ⊗

#######################################
# Includes

include("base.jl")

end
