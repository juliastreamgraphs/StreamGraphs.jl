# LinkStream tests
ls = LinkStream("test", Intervals([(0.0, 10.0)]), Set(), [])
add_node!(ls,"a")
@test ls.V == Set(["a"])
@test ls.E == []
add_node!(ls,"b")
@test ls.V == Set(["a","b"])
@test ls.E == []
l = Link("a to b", Intervals([(1.5,3.0)]), "a", "b", 1.0)
add_link!(ls,l)
@test ls.V == Set(["a","b"])
@test ls.E == [l]
@test is_connected(ls,"a","b",2.0)
@test !is_connected(ls,"a","b",1.4999)
@test duration(ls) == 10.0
@test node_duration(ls) == 10.0
@test link_duration(ls) == 1.5
l2 = Link("b to c", Intervals([(2.5,5.0)]), "b", "c", 1.0)
add_node!(ls,"c")
add_link!(ls,l2)
@test ls.V == Set(["a","b","c"])
@test ls.E == [l,l2]
@test is_connected(ls,"a","b",2.55)
@test is_connected(ls,"b","c",2.55)
@test !is_connected(ls,"b","c",1.4999)
@test duration(ls) == 10.0
@test node_duration(ls) == 10.0
@test link_duration(ls) == 4.0/3.0
record!(ls,2.0,2.6,"a","c")
@test ls.V == Set(["a","b","c"])
@test length(ls.E) == 3
@test is_connected(ls,"a","c",2.1)
@test is_connected(ls,"b","c",2.55)
@test !is_connected(ls,"a","c",1.4999)
@test duration(ls) == 10.0
@test node_duration(ls) == 10.0
@test link_duration(ls) == 4.6/3.0

ls = LinkStream("test-figure-1",Intervals([(0.0,10.0)]))
load!(ls,"./test_data/link_stream_1.txt")
@test ls.T == Intervals([(0.0,10.0)])
@test ls.V == Set(["a","b","c","d"])
@test length(ls.E) == 5
@test node_duration(ls) == 10.0
@test link_duration(ls) == 23.0/6.0

# StreamGraph tests
s1 = StreamGraph("s1", Intervals([(0.0, 10.0)]), Set(["a","c"]), [a,c], [l2])
s2 = StreamGraph("s1", Intervals([(0.0, 10.0)]), Set(["a","c"]), [a,c], [l2])
@test s1==s2
@test 0.0 ∈ s1
@test 5.87 ∈ s2
@test 10.001 ∉ s1
@test "a" ∈ s1
@test "c" ∈ s2
@test "x" ∉ s1
@test a ∈ s1
@test c ∈ s2
@test b ∉ s1
@test l2 ∈ s1
@test l1 ∉ s1
@test (0.0,10.0) ⊆ s1
@test (0.5,0.75) ⊆ s2
@test (8.1,10.1) ⊈ s2