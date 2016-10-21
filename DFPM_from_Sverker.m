A=[9 2 3 4 5; 1 7 3 4 5; 1 2 9 4 5; 1 2 3 8 5; 1 2 3 4 9];

x=[1 1 1 1 1]';
b=[1 2 3 4 5]';
v=[1 1 1 1 1]';

dt = 0.1;

mu = 1;

tol = 2^(-7);

for i=1:10000,

v=v+(b-A*x-mu*v)*dt;
x=x+v*dt;

    if norm(b-A*x)<tol, 
        break, 
    end

end

fprintf('The values obtained from the MATLAB implementation:\n%d, %d, %d, %d, %d\n\n', x(1), x(2), x(3), x(4), x(5));
%i