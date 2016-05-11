using JuMP, Cbc

m = Model(solver=CbcSolver())

## matrix of travel time between node i and j. node 1 = depot This is an example from the paper. Symmetric case.
t =[0 6 4 4;
    6 0 7 7;
    4 7 0 2;
    4 7 2 0]

T = 100
C= 6
K=2
n = 4 # number of node, including depot
d= [0 4 4 4] #demand at each node


@variable(m, x[1:n,1:n, 1:K], Bin) # binary
@variable(m, a[1:n, 1:K] >=0)
@variable(m, y[1:n, 1:K] >=0)



#  @objective(m, Min, sum{t[i,j]*x[i,j,k], i=1:n, j=1:n, k=1:K})
 @objective(m, Min, sum{a[i,k], i=1:n, k=1:K})
#

#constraint 2.26
for j = 2:n
  @constraint(m, sum{x[i,j,k], i=1:n, k=1:K} >=1)
end

#constraint 2.27
for i = 1:n
 for k=1:K
 @constraint(m, sum{x[i,j,k], j=1:n} - sum{x[j,i,k], j=1:n} ==0 )
end
end

# constraint 2.28
  @constraint(m, sum{x[1,j,k], j=2:n, k=1:K} == K)

# constraint 2.29
  for i = 2:n
    for k=1:K
    @constraint(m, y[i,k] -  d[i]*sum{x[i,j,k], j=1:n} <= 0)
  end
  end

#constraint 2.30
  for k=1:K
   @constraint(m, sum{y[i,k], i=2:n} -  C <= 0)
  end

#constraint 2.31
  for i=2:n
   @constraint(m, sum{y[i,k], k=1:K}  -d[i] == 0)
  end

# constraint 2.32
for i = 2:n
  for j = 2:n
for k=1:K
   @constraint(m, t[i,j] + a[i,k] - a[j,k] - T*(1-x[i,j,k]) <= 0 )
  end
 end
 end

#constraint 2.33
 for i = 2:n
   for k=1:K
   @constraint(m, a[i,k] -  t[1,i]*x[1,i,k] >= 0)
 end
 end

#this is to prevent xiik =0 cases.
for i=1:n
for k=1:K
 @constraint(m, x[i,i,k] == 0)
end
end


print(m) 
status = solve(m)

println("Objective value: ", getobjectivevalue(m))
println("x = ", getvalue(x))
println("a = ", getvalue(a))
println("y = ", getvalue(y))
