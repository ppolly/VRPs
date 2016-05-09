using JuMP, Cbc
#using JuMP, Gurobi #if Gurobi is to be used.
m = Model(solver=CbcSolver())
#m = Model(solver=GurobiSolver()) if GurobiSolver is to be used.

## matrix of travel times between node i and j. node 1 = depot
t =[0 2 10 2;
    2 0 8 4;
    10 8 0 8;
    2 4 8 0]

T = 100 #upper limit of the vehicle travel time
C= 10 #vehicle capacity

n = 4 # number of node, including depot
d= [0 2 4 4] #demand at each node


@variable(m, x[1:n,1:n], Bin) # binary
@variable(m, a[2:n] >=0) #variable, arrival time
@variable(m, u[2:n] >=0) #variable, flow after node i is visited

@objective(m, Min, sum{a[i], i=2:n}) #objective is to minimize the total travel time

# constraint 2.12
for j = 2:n
  @constraint(m, sum{x[i,j], i=1:n} ==1)
end

# constraint 2.13
for i = 2:n
  @constraint(m, sum{x[i,j], j=1:n} ==1 )
end

# constraint 2.14
  @constraint(m, sum{x[i,1], i=2:n} ==1 )

# constraint 2.15
  @constraint(m, sum{x[1,j], j=2:n} ==1 )

# constraint 2.16
  for i = 2:n
    for j = 2:n

     @constraint(m, - u[j] + u[i] - C*(1-x[i,j]) +  d[j] <= 0 )

    end
  end

  # constraint 2.17.1
  for i = 2:n
    @constraint(m, - u[i] +  d[i] <= 0)
  end

  # constraint 2.17.2
  for i = 2:n
    @constraint(m, u[i]  - C <= 0)
  end

# constraint 2.18
for i = 2:n
  for j = 2:n
   @constraint(m, t[i,j] + a[i] - a[j] - T*(1-x[i,j]) <= 0 )
  end
end

# constraint 2.19
for i = 2:n
   @constraint(m, t[1,i] - a[i]  <= 0 )
end

print(m) 
status = solve(m)

println("Objective value: ", getobjectivevalue(m))
println("x = ", getvalue(x))
println("a = ", getvalue(a))
println("u = ", getvalue(u))
