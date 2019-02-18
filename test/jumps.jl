j1 = Jump(0.5,"a","b")
j2 = Jump(0.5,"a","b")
j3 = Jump(0.6,"a","b")
@test j1.t==0.5
@test j2.from == "a"
@test j2.to == "b"
@test j1==j2
@test j1!=j3

j1 = DurationJump(0.5,"a","b",1.3)
j2 = DurationJump(0.5,"a","b",1.3)
j3 = DurationJump(0.5,"a","b",2.2)
@test j1.t==0.5
@test j2.from == "a"
@test j2.to == "b"
@test j1.δ == 1.3
@test duration(j2) == 1.3
@test j1==j2
@test j1!=j3