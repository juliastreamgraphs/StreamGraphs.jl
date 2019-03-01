# LinkStream tests
ls = LinkStream("test", Intervals([(0.0, 10.0)]), Set(), Dict())
add_node!(ls,"a")
@test ls.V == Set(["a"])
@test ls.E == Dict()
add_node!(ls,"b")
@test ls.V == Set(["a","b"])
@test ls.E == Dict()

l = Link("a to b", Intervals([(1.5,3.0)]), "a", "b", 1.0)
add_link!(ls,l)
@test ls.V == Set(["a","b"])
@test ls.E == Dict("a"=>Dict("b"=>l))
@test 2.0 ∈ times(ls,"a","b")
@test 2.0 ∈ times(ls,"b","a")
@test 1.4999 ∉ times(ls,"a","b")
@test 1.4999 ∉ times(ls,"b","a")
@test duration(ls) == 10.0
@test node_duration(ls) == 10.0
@test link_duration(ls) == 1.5
@test nodes(ls,1.6)==ls.V
@test nodes(ls,1.0)==ls.V
@test links(ls,1.6)==[l]
@test links(ls,1.0)==[]

l2 = Link("b to c", Intervals([(2.5,5.0)]), "b", "c", 1.0)
add_link!(ls,l2)
@test ls.V == Set(["a","b","c"])
@test ls.E == Dict("a"=>Dict("b"=>l),"b"=>Dict("c"=>l2))
@test 2.55 ∈ times(ls,"a","b")
@test 2.55 ∈ times(ls,"b","a")
@test 2.55 ∈ times(ls,"b","c")
@test 2.55 ∈ times(ls,"c","b")
@test 1.4999 ∉ times(ls,"b","c")
@test duration(ls) == 10.0
@test node_duration(ls) == 10.0
@test link_duration(ls) == 4.0/3.0
@test links(ls,1.499) == []
@test Set(links(ls,2.66)) == Set([l,l2])
@test links(ls,2.499) == [l]
@test links(ls,4.0) == [l2]
@test links(ls,5.1) == []

record!(ls,2.0,2.6,"a","c")
@test ls.V == Set(["a","b","c"])
@test 2.1 ∈ times(ls,"a","c")
@test 2.55 ∈ times(ls,"b","c")
@test 1.4999 ∉ times(ls,"a","c")
@test duration(ls) == 10.0
@test node_duration(ls) == 10.0
@test link_duration(ls) == 4.6/3.0

ls = LinkStream("test-figure-1",Intervals([(0.0,10.0)]))
load!(ls,"./test_data/link_stream_1.txt")
@test ls.T == Intervals([(0.0,10.0)])
@test ls.V == Set(["a","b","c","d"])
@test 1.55 ∈ times(ls,"a","b")
@test node_duration(ls) == 10.0
@test link_duration(ls) == 23.0/6.0
@test isapprox(density(ls),0.38;atol=0.01)
@test isapprox(density(ls,1.0),2.3333,atol=0.0001)
@test Set(nodes(ls,8.0)) == Set(["a","b","c","d"])
@test length((links(ls,8.0)))==4.0
@test links(ls,"c","d")==links(ls,"d","c")
@test links(ls,"c","d")==Link("c to d", Intervals(Tuple{Float64,Float64}[(6.0, 9.0)]), "c", "d", 1.0)
@test length(links(ls,"d"))==2.0
@test length(links(ls,"a"))==2.0
@test length(times(ls,"b","d"))==3.0
@test length(times(ls,"d","b"))==3.0
@test length(times(ls,"b","c"))==7.0
@test length(times(ls,"c","b"))==7.0
@test coverage(ls)==1.0
@test uniformity(ls)==1.0
@test clustering(ls,"a")==1.0
@test clustering(ls,"b")==0.375
@test clustering(ls,"c")==0.6
@test clustering(ls,"d")==0.5
@test clustering(ls)==0.61875
N_c=neighborhood(ls,"c")
@test keys(N_c)==Set(["a","b","d"])
@test N_c["a"].presence==Intervals([(2.0,5.0)])
@test N_c["b"].presence==Intervals([(1.0,8.0)])
@test N_c["d"].presence==Intervals([(6.0,9.0)])
@test degree(ls,"c")==1.3