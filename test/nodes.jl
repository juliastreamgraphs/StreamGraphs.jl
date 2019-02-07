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