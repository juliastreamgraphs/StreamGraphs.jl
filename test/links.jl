# Tests for Links
l1 = Link("a to b", Intervals([(0.33,0.66)]), a, b, .5)
l2 = Link("a to b", Intervals([(0.33,0.66)]), a, b, .5)
l3 = Link("a to c", Intervals([(0.45,0.56)]), a, c, .5)

@test l1 == l2
@test l2 == l1
@test from_match(l1,l2)
@test from_match(l1,l3)
@test to_match(l1,l2)
@test !to_match(l1,l3)
@test 0.5 ∈ l1
@test 0.67 ∉ l2
@test 0.51 ∈ l3
@test l3 ⊆ l1
@test l1 ⊈ l3
@test (l1 ∩ l3).list == [(0.45,0.56)]
@test (l3 ∪ l1).list == [(0.33,0.66)]

l1 = Link("a to b", Intervals([(0.33,0.66)]), a, b, .5)
l2 = Link("a to c", Intervals([(0.45,0.56)]), a, c, .5)
l3 = Link("b to c", Intervals([(0.5,1.0)]), b, c, .5)
L1 = [l3,l2]
@test from_match(l1,L1) == [2]
@test to_match(l2,L1) == [1,2]
@test match(l3,L1) == [1]
@test get_idx(l2,L1) == [2]
@test get_idx("b to c",L1) == [1]
@test l2 ∈ L1
@test l3 ∈ L1
@test l1 ∉ L1
L1 = [l1,l2,l3]
@test get_idx(0.4,L1) == [1]
@test get_idx(0.55,L1) == [1,2,3]
@test get_idx(1.0001,L1) == []
L2 = [l1,l3]
@test L1 ∩ L2 == [l1,l3]
@test L1 ∪ L2 == [l1,l2,l3]