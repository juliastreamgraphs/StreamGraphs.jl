# Tests for Links
l1 = Link("a to b", Intervals([(0.33,0.66)]), "a", "b", .5)
l2 = Link("a to b", Intervals([(0.33,0.66)]), "a", "b", .5)
l3 = Link("a to c", Intervals([(0.45,0.56)]), "a", "c", .5)

@test l1 == l2
@test l2 == l1
@test from_match(l1,l2)
@test from_match("a",l1)
@test from_match("a",l2)
@test from_match(l1,l3)
@test from_match("a",l3)
@test to_match(l1,l2)
@test to_match("b",l1)
@test to_match("b",l2)
@test to_match("c",l3)
@test !to_match(l1,l3)
@test !to_match("c",l1)
@test !to_match("a",l3)
@test match("a","b",l1)
@test match("a","b",l2)
@test match("a","c",l3)
@test !match("a","b",l3)
@test 0.5 ∈ l1
@test 0.67 ∉ l2
@test 0.51 ∈ l3
@test l3 ⊆ l1
@test l1 ⊈ l3
@test (l1 ∩ l3).list == [(0.45,0.56)]
@test (l3 ∪ l1).list == [(0.33,0.66)]

l1 = Link("a to b", Intervals([(0.33,0.66)]), "a", "b", .5)
l2 = Link("a to c", Intervals([(0.45,0.56)]), "a", "c", .5)
l3 = Link("b to c", Intervals([(0.5,1.0)]), "b", "c", .5)
L1 = [l3,l2]
@test from_match(l1,L1) == [2]
@test from_match("a",L1) == [2]
@test to_match(l2,L1) == [1,2]
@test to_match("c",L1) == [1,2]
@test match(l3,L1) == [1]
@test match("b","c",L1) == [1]
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

l1 = Link("a to b", Intervals([(0.33,0.66),(1.33,1.66)]), "a", "b", .5)
l2 = Link("a to b", Intervals([(0.2,1.1),(1.2,1.3),(1.5,1.9)]), "a", "b", .5)
l3 = merge(l1,l2)
@test l3.name == "a to b"
@test l3.from == "a"
@test l3.to == "b"
@test l3.weight == .5
@test l3.presence == Intervals([(0.2,1.1),(1.2,1.3),(1.33,1.9)])
merge!(l1,l2)
@test l1.name == "a to b"
@test l1.from == "a"
@test l1.to == "b"
@test l1.weight == .5
@test l1.presence == Intervals([(0.2,1.1),(1.2,1.3),(1.33,1.9)])