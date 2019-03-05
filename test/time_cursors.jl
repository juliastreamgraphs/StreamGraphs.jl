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

# Transition tests
narr=Set(["d"])
ndep=Set(["a"])
larr=Set([("b","d")])
ldep=Set([("a","b")])
t=Transition(0.2,0.6,2.3,narr,ndep,larr,ldep)
@test t.tprev==0.2
@test t.t==0.6
@test t.tnxt==2.3
@test t.node_arrivals==narr
@test t.node_departures==ndep
#@test t.links_arrivals==larr
@test t.link_departures==ldep
@test Δnodes(t)==0
@test Δlinks(t)==0
apply!(s,t)
@test s.t0==0.6
@test s.t1==2.3
@test s.nodes==Set(["b","c","d"])
@test s.links==Set([("b","c"),("b","d")])
apply!(s,t)
@test s.t0==0.2
@test s.t1==0.6
@test s.nodes==Set(["a","b","c"])
@test s.links==Set([("a","b"),("b","c")])