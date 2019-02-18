
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
import Base: length, match, merge, merge!

########################################
# Exports

export 

		# Stream components
		Intervals, Node, Link, StreamObject, AbstractStream, 
		LinkStream, StreamGraph,

		# Adding to streams
		add_node!, add_link!, record!, load!, parse_line,

		# Durations
		duration, node_duration, link_duration, contribution,

		# functions
		count, length, merge, merge!, push, clean, from_match, to_match, 
		match, get_idx, is_connected,

		# Operators
		==, ≈, ∈, ∪, ∩, ⊆

#######################################
# Includes

include("base.jl")

end
