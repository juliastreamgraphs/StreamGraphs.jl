"""Load the stream graph from figure 1."""
function load_stream_graph_1()
	s=StreamGraph("stream-graph 1", Intervals([(0.0,10.0)]))
	record!(s,0.0,10.0,"a")
	record!(s,0.0,4.0,"b")
	record!(s,5.0,10.0,"b")
	record!(s,4.0,9.0,"c")
	record!(s,1.0,3.0,"d")
	record!(s,1.0,3.0,"a","b")
	record!(s,7.0,8.0,"a","b")
	record!(s,4.5,7.5,"a","c")
	record!(s,6.0,9.0,"b","c")
	record!(s,2.0,3.0,"b","d")
	s
end

"""Load the stream graph from figure 2a."""
function load_stream_graph_2a()
	s=StreamGraph("stream-graph 2a", Intervals([(0.0,3.0)]))
	record!(s,0.0,1.0,"a")
	record!(s,0.0,3.0,"b")
	record!(s,0.0,1.0,"c")
	record!(s,2.0,3.0,"c")
	record!(s,0.0,1.0,"a","b")
	record!(s,0.0,1.0,"b","c")
	record!(s,2.0,3.0,"b","c")
	s
end

"""Load the stream graph from figure 2b."""
function load_stream_graph_2b()
	s=StreamGraph("stream-graph 2b", Intervals([(0.0,3.0)]))
	record!(s,0.0,1.0,"a")
	record!(s,0.0,3.0,"b")
	record!(s,1.0,3.0,"c")
	record!(s,0.0,1.0,"a","b")
	record!(s,1.0,3.0,"b","c")
	s
end

"""Load the stream graph from figure 6a."""
function load_stream_graph_6a()
	s=StreamGraph("stream-graph 6a", Intervals([(0.0,4.0)]))
	record!(s,0.0,2.0,"a")
	record!(s,0.0,4.0,"b")
	record!(s,2.0,4.0,"c")
	record!(s,0.0,2.0,"a","b")
	record!(s,2.0,4.0,"b","c")
	s
end

"""Load the stream graph from figure 6b."""
function load_stream_graph_6b()
	s=StreamGraph("stream-graph 6b", Intervals([(0.0,4.0)]))
	record!(s,0.0,0.0,"a")
	record!(s,0.0,4.0,"b")
	record!(s,0.0,4.0,"c")
	record!(s,0.0,4.0,"b","c")
	s
end

"""Load the stream graph from figure 7."""
function load_stream_graph_7()
	s=StreamGraph("stream-graph 7", Intervals([(0.0,10.0)]))
	record!(s,0.0,10.0,"a")
	record!(s,0.0,10.0,"b")
	record!(s,0.0,5.0,"c")
	record!(s,0.0,5.0,"b","c")
	record!(s,5.0,10.0,"a","b")
	s
end

# StreamGraph tests
s=load_stream_graph_1()
@test length(s.V)==4
@test duration(s)==10.0
@test times(s,"a")==Intervals([(0.0,10.0)])
@test times(s,"b")==Intervals([(0.0,4.0),(5.0,10.0)])
@test times(s,"c")==Intervals([(4.0,9.0)])
@test times(s,"d")==Intervals([(1.0,3.0)])
@test times(s,"a","b")==Intervals([(1.0,3.0),(7.0,8.0)])
@test times(s,"b","a")==Intervals([(1.0,3.0),(7.0,8.0)])
@test times(s,"a","c")==Intervals([(4.5,7.5)])
@test times(s,"c","a")==Intervals([(4.5,7.5)])
@test times(s,"b","c")==Intervals([(6.0,9.0)])
@test times(s,"c","b")==Intervals([(6.0,9.0)])
@test times(s,"b","d")==Intervals([(2.0,3.0)])
@test times(s,"d","b")==Intervals([(2.0,3.0)])
@test times(s,"a","d")==Intervals([])
@test Set(nodes(s,0.0))==Set(["a","b"])
@test Set(nodes(s,2.0))==Set(["a","b","d"])
@test Set(nodes(s,4.0))==Set(["a","b","c"])
@test Set(nodes(s,4.00001))==Set(["a","c"])
@test Set(nodes(s,1.5,2.5))==Set(["a","b","d"])
@test Set(nodes(s,0.0,4.0))==Set(["a","b"])
@test Set(nodes(s,1.5,9.0))==Set(["a"])
@test Set(nodes(s,5.0,10.0))==Set(["a","b"])
@test Set(nodes(s,0.0,10.0))==Set(["a"])
@test Set(nodes(s,0.0,0.0))==Set(["a","b"])
@test Set(links(s,0.0,3.0))==Set([Link("a to b",Intervals([(1.0,3.0)]),"a","b",1.0),Link("b to d",Intervals([(2.0,3.0)]),"b","d",1.0)])
@test coverage(s)==0.65
@test number_of_nodes(s)==2.6
@test number_of_links(s)==1.0
@test node_duration(s)==6.5
@test isapprox(link_duration(s),1.6666666;atol=0.00001)
@test uniformity(s)==0.39285714285714285
@test density(s)==0.45454545454545453
@test density(s,2.0)==2.0/3.0
@test density(s,"a","b")==1.0/3.0
@test density(s,"b","a")==1.0/3.0
@test density(s,"b","d")==1.0/2.0
@test density(s,"d","b")==1.0/2.0
@test density(s,"d")==0.25
Na=neighborhood(s,"a")
@test length(Na)==2
@test Na["b"].presence==Intervals([(1.0,3.0),(7.0,8.0)])
@test Na["c"].presence==Intervals([(4.5,7.5)])
@test degree(s,"a")==0.6
@test neighborhood(s,"a",0.0)==[]
@test neighborhood(s,"a",1.0)==["b"]
@test Set(neighborhood(s,"a",7.4))==Set(["b","c"])
@test Set(neighborhood(s,"b",7.4))==Set(["a","c"])
@test Set(neighborhood(s,"d",2.4))==Set(["b"])
@test degree(s,"a",0.0)==0
@test degree(s,"a",1.0)==1
@test degree(s,"a",7.4)==2
@test degree(s,"b",7.4)==2
@test degree(s,"d",2.4)==1
@test degree(s,0.0)==0.0
@test degree(s,1.0)==0.5
@test degree(s,2.0)==1.0
@test degree(s,6.0)==1.0
@test degree(s,7.1)==6.0/4.0
@test degree(s)==0.5
@test times(s)==[0.0,1.0,2.0,3.0,4.0,4.5,5.0,6.0,7.0,7.5,8.0,9.0,10.0]
@test time_clustering(s)==0.11538461538461539
@test clustering(s)==0.037500000000000006

s2a=load_stream_graph_2a()
s2b=load_stream_graph_2b()
@test isapprox(number_of_nodes(s2a),2.0;atol=0.00001)
@test isapprox(number_of_nodes(s2b),2.0;atol=0.00001)
@test number_of_links(s2a)==1
@test number_of_links(s2b)==1
@test density(s2a)==0.75
@test density(s2b)==1.0
@test times(s2a)==[0.0,1.0,2.0,3.0]
@test times(s2b)==[0.0,1.0,3.0]

s6a=load_stream_graph_6a()
s6b=load_stream_graph_6b()
@test density(s6a)==1.0
@test density(s6b)==1.0
@test degree(s6a,"a")==0.5
@test degree(s6a,"b")==1.0
@test degree(s6a,"c")==0.5
@test average_node_degree(s6a)==0.75

s7=load_stream_graph_7()
@test number_of_nodes(s7)==2.5
@test degree(s7,"a")==0.5
@test degree(s7,"b")==1.0
@test degree(s7,"c")==0.5
@test isapprox(average_node_degree(s7),0.7;atol=0.000001)
@test node_duration(s7)==25.0/3.0
@test times(s7)==[0.0,5.0,10.0]
@test node_contribution(s7,2.5)==1.0
@test degree(s7,2.5)==2.0/3.0
@test node_contribution(s7,7.5)==2.0/3.0
@test degree(s7,7.5)==2.0/3.0
@test average_time_degree(s7)==2.0/3.0
@test time_clustering(s7,2.5)==0.0
@test time_clustering(s7,5.0)==0.0
@test time_clustering(s7)==0.0
@test clustering(s7)==0.0