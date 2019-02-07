# Intervals testing
I1 = Intervals([(0.0,1.0)])
I2 = Intervals([(0.0,1.0)])
@test I1 == I2
@test (I1 ∪ I2).list == [(0.0,1.0)]
@test (I1 ∩ I2).list == [(0.0,1.0)]
@test I1 ∪ I2 == I1 ∩ I2
@test I1 ∪ I2 == I2 ∪ I1
@test I1 ∩ I2 == I2 ∩ I1

I1 = Intervals([(0.0,1.0),(1.0,2.0)])
I2 = Intervals([(0.0,1.0),(1.0,2.0)])
@test I1 == I2
@test I1 ∪ I2 == I1 ∩ I2
@test (I1 ∩ I2).list == [(0.0,2.0)]
@test (I1 ∪ I2).list == [(0.0,2.0)]

I1 = Intervals([(0.0,1.0)])
I2 = Intervals([(0.0,1.0),(2.0,3.0)])
@test length(I1) == 1.0
@test length(I2) == 2.0
@test (I1 ∩ I2).list == [(0.0,1.0)]
@test length(I1 ∩ I2) == 1.0
@test (I1 ∪ I2).list == [(0.0,1.0),(2.0,3.0)]
@test length(I1 ∪ I2) == 2.0
@test I1 ⊆ I2
@test !(I2 ⊆ I1)
@test 0.5 ∈ I1
@test 1.0 ∈ I1
@test 2.5 ∈ (I1 ∪ I2)

I1 = Intervals([(0.0,1.0),(2.0,3.0)])
I2 = Intervals([(0.5,4.0)])
@test (I1 ∩ I2).list == [(0.5,1.0),(2.0,3.0)]
@test (I1 ∪ I2).list == [(0.0,4.0)]

I1 = Intervals([(0.0,1.0),(2.0,3.0)])
I2 = Intervals([(1.1,2.1),(2.9,4.0)])
@test (I1 ∩ I2).list == [(2.0,2.1),(2.9,3.0)]
@test (I1 ∪ I2).list == [(0.0,1.0),(1.1,4.0)]

I1 = Intervals([(0.0,1.0),(2.0,3.0)])
I2 = Intervals([(1.1,1.9)])
@test (I1 ∩ I2).list == []
@test (I1 ∪ I2).list == [(0.0,1.0),(1.1,1.9),(2.0,3.0)]

I1 = Intervals([(0.0,1.0),(2.0,3.0)])
I2 = Intervals([(1.0,2.0)])
@test (I1 ∩ I2).list ==[(1.0,1.0),(2.0,2.0)]
@test (I1 ∪ I2).list == [(0.0,3.0)]