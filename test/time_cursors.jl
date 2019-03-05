# State tests
n=Set(["a","b","c"])
l=Set([("a","b"),("b","c")])
s=State(0.2,0.6,n,l)
@test s.t0==0.2
@test s.t1==0.6
@test s.nodes==n
@test s.links==l
@test isapprox(duration(s),0.4)
@test number_of_nodes(s)==3
@test number_of_links(s)==2