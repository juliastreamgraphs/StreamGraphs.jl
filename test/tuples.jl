# Tuple equality tests
@test (0.0,1.0) ≈ (0.00000000001,0.99999999)
@test !((0.0,1.0) ≈ (0.00001,0.9999))
@test [(0.0,1.0),(2.00000001,2.49999999)] ≈ [(0.00000001,0.999999999),(2.0,2.5)]
@test !([(0.0,1.0),(2.0,3.0)] ≈ [(0.0000001,0.999999)])