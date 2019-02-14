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