s1 = StreamGraph("s1", 0.0, 10.0, [a,c], [l2], Dict(), Dict())
s2 = StreamGraph("s1", 0.0, 10.0, [a,c], [l2], Dict(), Dict())
@test s1==s2
@test 0.0 ∈ s1
@test 5.87 ∈ s2
@test 10.001 ∉ s1
@test a ∈ s1
@test c ∈ s2
@test b ∉ s1
@test l2 ∈ s1
@test l1 ∉ s1
@test (0.0,10.0) ⊆ s1
@test (0.5,0.75) ⊆ s2
@test (8.1,10.1) ⊈ s2
@test [a] ⊆ s1
@test [a,c] ⊆ s2
@test [DNode("a",Intervals([(0.5,1.5)]))] ⊆ s1
@test [DNode("a",Intervals([(0.5,1.5)])),DNode("c",Intervals([(1.2,1.6)]))] ⊆ s1
@test [DNode("a",Intervals([(0.5,1.5)])),DNode("c",Intervals([(1.2,1.7)]))] ⊈ s1
@test [a,b] ⊈ s1
@test [l2] ⊆ s1