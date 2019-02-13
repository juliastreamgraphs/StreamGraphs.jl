# Static nodes tests
a = SNode("a")
b = SNode("a")
c = SNode("c")

@test a==b
@test b==a
@test a==a
@test a!=c
@test b!=c

l1 = [a,c,b]
l2 = [a,c,b]
l3 = [b,c,a]
l4 = [c,a,b]

@test l1==l2
@test l1==l1
@test l1==l3
@test l3==l2
@test l1!=l4
@test l4!=l2


# Dynamic nodes tests
a = DNode("a",Intervals([(0.0,1.0),(1.0,2.0)]))
b = DNode("a",Intervals([(0.0,1.0),(1.0,2.0)]))
c = DNode("c",Intervals([(0.000001,0.99)]))

@test a==b
@test b==a
@test a==a
@test a!=c
@test b!=c
@test c ⊆ a
@test a ⊆ b
@test a ⊈ c
@test b ⊈ c
@test a ⊆ a
@test (0.5,0.99) ⊆ a
@test (0.6,1.5) ⊆ b
@test (-0.001,0.9) ⊈ c
@test (0.0,0.99) ⊆ c
@test 0.5 ∈ a
@test 0.98 ∈ c
@test 2.5 ∉ a
@test 2.0 ∉ c
@test (a ∩ c).list == [(0.000001,0.99)]
@test (a ∪ c).list == [(0.0,2.0)]

a = DNode("a",Intervals([(0.0,1.0),(1.0,2.0)]))
b = DNode("b",Intervals([(0.0,1.5),(1.6,2.5)]))
c = DNode("c",Intervals([(1.0,1.6)]))
d = DNode("d",Intervals([(0.3,1.2)]))
L = [a,b,c]
@test a ∈ L
@test b ∈ L
@test d ∉ L
@test c ∈ L
@test get_idx(a,L) == [1]
@test get_idx(b,L) == [2]
@test get_idx(d,L) == []
@test get_idx("a",L) == [1]
@test get_idx("b",L) == [2]
@test get_idx("d",L) == []
@test get_idx(1.0,L) == [1,2,3]
@test get_idx(1.61,L) == [1,2]
@test get_idx(2.4,L) == [2]
@test get_idx(2.6,L) == []
@test a ⊆ L
@test d ⊈ L
@test DNode("a",Intervals([(0.3,0.9)])) ⊆ L
@test DNode("a",Intervals([(0.3,1.2)])) ⊆ L
@test DNode("b",Intervals([(1.3,1.5)])) ⊆ L
@test DNode("b",Intervals([(1.3,1.9)])) ⊈ L
L2 = [a,c]
@test L2 ⊆ L
@test L ∩ L2 == [a,c]
@test L ∪ L2 == [a,b,c]
L2 = [a,b,d]
@test L2 ⊈ L
@test L ∩ L2 == [a,b]
@test L ∪ L2 == [a,b,c,d]
@test L2 ∪ L == [a,b,d,c]
L2 = []
@test L2 ⊆ L
@test L ∩ L2 == []
@test L ∪ L2 == L
L2 = [DNode("a",Intervals([(0.3,0.9)])), DNode("b",Intervals([(1.3,1.5)]))]
@test L2 ⊆ L
L2 = [DNode("a",Intervals([(0.3,0.9)])), DNode("b",Intervals([(1.3,1.9)]))]
@test L2 ⊈ L