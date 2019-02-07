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

l1 = [a,c,b]
l2 = [a,c,b]
l3 = [b,c,a]
l4 = [c,a,b]
l5 = [a]
l6 = [c,b,a]

@test l1==l2
@test l1==l1
@test l1==l3
@test l3==l2
@test l1!=l4
@test l4!=l2
@test l4 ⊆ l1
@test l5 ⊆ l6
@test l6 ⊈ l5
@test l5 != l6