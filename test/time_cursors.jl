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

S0=State(-1.0,0.0,Set(),Set())
T=Dict{Float64,Transition}()
T[0.0]=Transition(-1.0,0.0,1.0,Set(["a","b"]),Set(),Set(),Set())
T[1.0]=Transition(0.0,1.0,2.0,Set(["d"]),Set(),Set([("a","b")]),Set())
T[2.0]=Transition(1.0,2.0,3.0,Set(),Set(),Set([("b","d")]),Set())
T[3.0]=Transition(2.0,3.0,4.0,Set(),Set(["d"]),Set(),Set([("a","b"),("b","d")]))
T[4.0]=Transition(3.0,4.0,4.5,Set(["c"]),Set(["b"]),Set(),Set())
T[4.5]=Transition(4.0,4.5,5.0,Set(),Set(),Set([("a","c")]),Set())
T[5.0]=Transition(4.5,5.0,6.0,Set(["b"]),Set(),Set(),Set())
T[6.0]=Transition(5.0,6.0,7.0,Set(),Set(),Set([("b","c")]),Set())
T[7.0]=Transition(6.0,7.0,7.5,Set(),Set(),Set([("a","b")]),Set())
T[7.5]=Transition(7.0,7.5,8.0,Set(),Set(),Set(),Set([("a","c")]))
T[8.0]=Transition(7.5,8.0,9.0,Set(),Set(),Set(),Set([("a","b")]))
T[9.0]=Transition(8.0,9.0,10.0,Set(),Set(["c"]),Set(),Set([("b","c")]))
T[10.0]=Transition(9.0,10.0,11.0,Set(),Set(["a","b"]),Set(),Set())
tc=TimeCursor(S0,T)
@test number_of_nodes(tc)==0
@test number_of_links(tc)==0
next!(tc)
@test number_of_nodes(tc)==2
@test nodes(tc)==Set(["a","b"])
@test number_of_links(tc)==0
next!(tc)
@test number_of_nodes(tc)==3
@test nodes(tc)==Set(["a","b","d"])
@test number_of_links(tc)==1
@test links(tc)==Set([("a","b")])
next!(tc)
@test number_of_nodes(tc)==3
@test nodes(tc)==Set(["a","b","d"])
@test number_of_links(tc)==2
@test links(tc)==Set([("a","b"),("b","d")])
next!(tc)
@test number_of_nodes(tc)==2
@test nodes(tc)==Set(["a","b"])
@test number_of_links(tc)==0
@test links(tc)==Set()
previous!(tc)
@test number_of_nodes(tc)==3
@test nodes(tc)==Set(["a","b","d"])
@test number_of_links(tc)==2
@test links(tc)==Set([("a","b"),("b","d")])
previous!(tc)
@test number_of_nodes(tc)==3
@test nodes(tc)==Set(["a","b","d"])
@test number_of_links(tc)==1
@test links(tc)==Set([("a","b")])
end!(tc)
@test number_of_nodes(tc)==2
@test nodes(tc)==Set(["a","b"])
@test number_of_links(tc)==0
start!(tc)
@test number_of_nodes(tc)==2
@test nodes(tc)==Set(["a","b"])
@test number_of_links(tc)==0
goto!(tc,4.2)
@test number_of_nodes(tc)==2
@test nodes(tc)==Set(["a","c"])
@test number_of_links(tc)==0
goto!(tc,7.2)
@test number_of_nodes(tc)==3
@test nodes(tc)==Set(["a","c","b"])
@test number_of_links(tc)==3
@test links(tc)==Set([("a","b"),("a","c"),("b","c")])
goto!(tc,2.999999)
@test number_of_nodes(tc)==3
@test nodes(tc)==Set(["a","d","b"])
@test number_of_links(tc)==2
@test links(tc)==Set([("a","b"),("b","d")])
goto!(tc,3.0)
@test number_of_nodes(tc)==2
@test nodes(tc)==Set(["a","b"])
@test number_of_links(tc)==0
@test nodes(tc,6.8)==Set(["a","b","c"])
@test links(tc,6.8)==Set([("a","c"),("b","c")])
@test nodes(tc,4.0)==Set(["a","b","c"])
@test links(tc,4.0)==Set()
@test nodes(tc,0.0)==Set(["a","b"])
@test links(tc,0.0)==Set()
@test nodes(tc,10.0)==Set(["a","b"])
@test links(tc,10.0)==Set()
@test nodes(tc,0.0,10.0)==Set(["a","b","c","d"])
@test links(tc,0.0,10.0)==Set([("a","b"),("a","c"),("b","d"),("b","c")])
@test nodes(tc,0.0,0.0)==Set(["a","b"])
@test links(tc,0.0,0.0)==Set()
@test nodes(tc,1.0,3.0)==Set(["a","b","d"])
@test links(tc,1.0,3.0)==Set([("a","b"),("b","d")])
@test nodes(tc,0.9999,3.000001)==Set(["a","b","d"])
@test links(tc,0.9999,3.000001)==Set([("a","b"),("b","d")])
@test nodes(tc,4.0,4.0)==Set(["a","b","c"])
@test nodes(tc,3.9999,4.0)==Set(["a","b","c"])
@test nodes(tc,4.0,4.0001)==Set(["a","b","c"])
@test nodes(tc,4.00001,4.1)==Set(["a","c"])