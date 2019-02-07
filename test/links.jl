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

ll1 = [l1,l2,l3]
ll2 = [l2,l1,l3]
ll3 = [l3,l2,l1]

@test ll1 == ll2
@test ll1 != ll3