# Node tests
a = Node("a",Intervals([(0.0,1.0),(1.0,2.0)]))
b = Node("a",Intervals([(0.0,1.0),(1.0,2.0)]))
c = Node("c",Intervals([(0.000001,0.99)]))

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

a = Node("a",Intervals([(0.0,1.0),(1.0,2.0)]))
b = Node("b",Intervals([(0.0,1.5),(1.6,2.5)]))
c = Node("c",Intervals([(1.0,1.6)]))
d = Node("d",Intervals([(0.3,1.2)]))
L = Vector([a,b,c])
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
L2 = Vector([a,b])
@test L2 ⊆ L
@test L ∩ L2 == [a,b]
@test L ∪ L2 == [a,b,c]
L2 = Vector([a,b,d])
@test L2 ⊈ L
@test L ∩ L2 == [a,b]
@test L ∪ L2 == [a,b,c,d]
@test L2 ∪ L == [a,b,d,c]
L2 = Vector([])
@test L2 ⊆ L
@test L ∩ L2 == []
@test L ∪ L2 == L
L2 = [Node("a",Intervals([(0.3,0.9)])), 
      Node("x",Intervals([(1.3,1.5)])),
      Node("z",Intervals([(1.2,1.3)]))]
@test all(L2 .⊆ L)
L2 = [Node("a",Intervals([(0.3,0.9)])), 
      Node("b",Intervals([(1.3,1.9)])),
      Node("z",Intervals([(1.2,1.3)]))]
@test !all(L2 .⊆ L)

a1 = Node("a",Intervals([(0.5,1.0),(1.5,2.5)]))
a2 = Node("a",Intervals([(0.0,0.45),(0.6,1.0),(1.1,1.4),(2.3,3.0)]))
a3 = merge(a1,a2)
@test a3.name == "a"
@test a3.presence == Intervals([(0.0,0.45),(0.5,1.0),(1.1,1.4),(1.5,3.0)])
merge!(a1,a2)
@test a1.name == "a"
@test a1.presence == Intervals([(0.0,0.45),(0.5,1.0),(1.1,1.4),(1.5,3.0)])
