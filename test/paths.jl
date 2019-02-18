p = Path()
@test length(p) == 0
@test start(p) == 0.0
@test finish(p) == 0.0
@test duration(p) == 0.0

p = Path([Jump(0.5,"a","c"),Jump(1.5,"c","b"),Jump(2.2,"b","d")])
@test length(p)==3
@test start(p) == 0.5
@test finish(p) == 2.2
@test duration(p)==2.2-0.5
@test is_valid(p)

p2 = Path([Jump(0.5,"a","c"),Jump(1.5,"d","b"),Jump(2.2,"b","d")])
@test !is_valid(p2)

dp = DurationPath([DurationJump(0.5,"a","c",0.6),DurationJump(1.5,"c","b",0.5),DurationJump(2.2,"b","d",0.3)])
@test length(dp) == 3
@test start(dp) == 0.5
@test finish(dp) == 2.5
@test duration(dp) == 2.0
@test is_valid(dp)

p2 = Path([Jump(2.5,"d","c"),Jump(3.1,"c","e")])
@test is_valid(p+p2)
@test length(p+p2) == 5
@test start(p+p2) == 0.5
@test finish(p+p2) == 3.1
@test duration(p+p2) == 3.1-0.5
#@test Path([Jump(2.2,"b","d"),Jump(2.5,"d","c")]) ⊆ (p+p2)

dp2 = DurationPath([DurationJump(2.5,"d","e",1.6),DurationJump(4.5,"e","b",0.01)])
@test is_valid(dp+dp2)
@test length(dp+dp2) == 5
@test start(dp+dp2) == 0.5
@test finish(dp+dp2) == 4.51
@test duration(dp+dp2) == 4.51-0.5
#@test DurationPath([DurationJump(1.5,"c","b",0.5),DurationJump(2.2,"b","d",0.3),DurationJump(2.5,"d","e",1.6)]) ⊆ (dp+dp2)