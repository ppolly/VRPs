using JuMP, Cbc
m = Model(solver=CbcSolver())

@variable(m, x1 >= 0)
@variable(m, x2 >= 0)

@objective(m, Max, 2x1 + x2 )

@constraint(m, 3x1 + 2x2 <= 15.0 )
@constraint(m, x1  <= 3.0 )

print(m)
status = solve(m)

println("Objective value: ", getobjectivevalue(m))
println("x1 = ", getvalue(x1))
println("x2 = ", getvalue(x2))
