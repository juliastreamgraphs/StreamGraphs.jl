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