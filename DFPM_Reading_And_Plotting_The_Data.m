A = [9 2 3 4 5;1 7 3 4 5;1 2 9 4 5;1 2 3 8 5;1 2 3 4 9];

x = [1 1 1 1 1]';
b = [1 2 3 4 5]';
v = [1 1 1 1 1]';

dt = 0.1;

mu = 1;

x_set = zeros(150, 5);



for i = 1:10000,

    v = v + (b - A*x - mu*v) * dt;
    x = x + v*dt;
    
    x_set(i, 1) = x(1);
    x_set(i, 2) = x(2);
    x_set(i, 3) = x(3);
    x_set(i, 4) = x(4);
    x_set(i, 5) = x(5);

    if norm(b - A*x) < 7.8125e-3, 
        break, 
    end

end








x_0_data = load('x0.txt');
x_1_data = load('x1.txt');
x_2_data = load('x2.txt');
x_3_data = load('x3.txt');
x_4_data = load('x4.txt');

x0 = zeros(1, (length(x_0_data)/5));
x1 = zeros(1, (length(x_0_data)/5));
x2 = zeros(1, (length(x_0_data)/5));
x3 = zeros(1, (length(x_0_data)/5));
x4 = zeros(1, (length(x_0_data)/5));

for i = 1:length(x_0_data)/5   
   %**X0
   if x_0_data((5*i) - 4) > 127
       x0(i) = (-1) * (((255 - x_0_data(5*i - 4))*256) + (255 - x_0_data(5*i - 3)) + (255 - x_0_data(5*i - 2))/255 + (255 - x_0_data(5*i - 1))/65535 + 1/65535);       
   else
       x0(i) = (x_0_data((5*i) - 4))*256 + (x_0_data((5*i) - 3)) + (x_0_data((5*i) - 2)/255) + ((x_0_data((5*i) - 1))/65535);
   end
   
   %**X1
   if x_1_data((5*i) - 4) > 127
       x1(i) = (-1) * (((255 - x_1_data(5*i - 4))*256) + (255 - x_1_data(5*i - 3)) + (255 - x_1_data(5*i - 2))/255 + (255 - x_1_data(5*i - 1))/65535 + 1/65535);       
   else
       x1(i) = (x_1_data((5*i) - 4))*256 + (x_1_data((5*i) - 3)) + (x_1_data((5*i) - 2)/255) + ((x_1_data((5*i) - 1))/65535);
   end
   
   %**X2
   if x_2_data((5*i) - 4) > 127
       x2(i) = (-1) * (((255 - x_2_data(5*i - 4))*256) + (255 - x_2_data(5*i - 3)) + (255 - x_2_data(5*i - 2))/255 + (255 - x_2_data(5*i - 1))/65535 + 1/65535);       
   else
       x2(i) = (x_2_data((5*i) - 4))*256 + (x_2_data((5*i) - 3)) + (x_2_data((5*i) - 2)/255) + ((x_2_data((5*i) - 1))/65535);
   end
   
   %X3
   if x_3_data((5*i) - 4) > 127
       x3(i) = (-1) * (((255 - x_3_data(5*i - 4))*256) + (255 - x_3_data(5*i - 3)) + (255 - x_3_data(5*i - 2))/255 + (255 - x_3_data(5*i - 1))/65535 + 1/65535);       
   else
       x3(i) = (x_3_data((5*i) - 4))*256 + (x_3_data((5*i) - 3)) + (x_3_data((5*i) - 2)/255) + ((x_3_data((5*i) - 1))/65535);
   end
   
   %X4
   if x_4_data((5*i) - 4) > 127
       x4(i) = (-1) * (((255 - x_4_data(5*i - 4))*256) + (255 - x_4_data(5*i - 3)) + (255 - x_4_data(5*i - 2))/255 + (255 - x_4_data(5*i - 1))/65535 + 1/65535);       
   else
       x4(i) = (x_4_data((5*i) - 4))*256 + (x_4_data((5*i) - 3)) + (x_4_data((5*i) - 2)/255) + ((x_4_data((5*i) - 1))/65535);
   end
   
end


x_axis = [1 : 1 : length(x0)];
x1_axis = [1 : 1 : 150];

plot(x_axis, x0, 'k');
hold on
plot(x_axis, x1, 'r');
plot(x_axis, x2, 'g');
plot(x_axis, x3, 'b');
plot(x_axis, x4, 'y');




plot(x1_axis, x_set(:, 1), 'k');
plot(x1_axis, x_set(:, 2), 'r');
plot(x1_axis, x_set(:, 3), 'g');
plot(x1_axis, x_set(:, 4), 'b');
plot(x1_axis, x_set(:, 5), 'y');
