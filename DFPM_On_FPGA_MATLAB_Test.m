%%%%%%%%%%%%%%
%This script runs an implementation of the DFPM in MATLAB and then parses
%the same problemimplementation to the FPGA implementation through a port
%object that is bound to the UART, which is connected to the FPGA.

%%*********************************************************%%%%
%The following parameters define the problem and they can be changed right
%from inside this script by modifying lines 56 and 59 for the MATLAB
%implementation and line 118 for the FPGA implementation.
%Problem model A*x = b
%A = [9 2 3 4 5; 1 7 3 4 5; 1 2 9 4 5; 1 2 3 8 5; 1 2 3 4 9]
%b = [1 2 3 4 5]
%x, which is the solution, will be printed to the MATLAB console on the PC
%in decimal format.

%%**********************************************************%%%
%Fixed parameters relevant to the test:
%The following parameters are fixed in the sense that these same parameters
%are available and modifiable in this script for the MATLAB implementation
%but for the FPGA implementation, one needs to modify the code in the FPGA
%and resythesize, re-map and re-generate the bit programming file and then
%program the FPGA before the algorithm run conditions can be at par between
%the two inmolementations. 
%The parameters are:
%X = [1 1 1 1 1] 
%V = [1 1 1 1 1]
%dt = 0.1 (discretization coefficient)
%mu = 1.0 (damping coefficent)

%%********************************************************%%%
%Communication parameters:
%Since the PC communicates with the FPGA through USART on the COM port,
%The parameters are listed below:
%Baud Rate: 9600
%Number of data bits: 8
%Parity: None
%Stop bits: 1
%Handshaking: None

%In order to have a hitch free test, please follow these steps:
% 1. Program the FPGA with the git programmming file
% 2. Ensure that a USB to RS232 communication cable is connected between
%    the PC's USB port and the FPGA's RS232 port.
% 3. Check and verify the identity of the port to shich the FPGA is
%    connected (in the WIndows device manager or command line)
%    (NOTE: If this same code is to run in a linux environment, then the
%    port identity should be checked in the command line as well and 
%    necessary modifications made to this script)
% 4. Ensure that the COM port identity corresponds to the COM port identity
%    in the connection parameters indicated in the com object creation.
% 5. Run the script and check the solution on the MATLAB console. :-)
% 6. If there is any errror, verify that the steps 1 to 5 were followed.


%%***First part - MATLAB implementation*********%%%%%%%%%%%%%%%%%%%%%%%%%
A = [9 2 3 4 5; 1 8 3 4 5; 1 2 7 4 5; 1 2 3 8 5; 1 2 3 4 9];

x = [1 1 1 1 1]';
b = [1 2 3 4 5]';
v = [1 1 1 1 1]';

dt = 0.1;

mu = 1;

tol = 2^(-7);

for i = 1:10000,

    v = v + (b - A*x - mu*v) * dt;
    x = x + v*dt;

    if norm(b - A*x) < tol, 
        break, 
    end

end
i
%Printing out the values in the solution vector
fprintf('The values obtained from the MATLAB implementation:\n%d, %d, %d, %d, %d\n\n', x(1), x(2), x(3), x(4), x(5));

%****End of the first part**********%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%******Second part - the MATLAB to FPGA implementation/communication*%%

%Communicating through a port object with the following parameters:
%**Com port ID: COM5 -should be modified as appropriate
%**Baud Rate: 9600
%**No of data bits: 8
%**Parity: odd
%**Stop bit: 1

%Creation of the port object
thePort = serial('COM12');

%Opening the port object created
fopen(thePort);

%Setting the Baud rate
thePort.BaudRate = 9600;

%Setting the number of data bits
thePort.DataBits = 8;

%Setting the parity
thePort.Parity = 'odd';

%Setting the stop bit
thePort.StopBits = 1;

%Setting the Terminator to "Carriage Return"
thePort.Terminator = 'cr';

%get(thePort)

%fprintf(thePort, 'This is a Print');

%Sending tha parameters of the problem statement to the FPGA
fwrite(thePort, '[9 2 3 4 5;1 8 3 4 5;1 2 7 4 5;1 2 3 8 5;1 2 3 4 9][1 2 3 4 5]::', 'async');


%Acquiring the solution from the FPGA
theSolution = fread(thePort);
%theSolution = fgets(thePort)

%%Storing up each of the 4 digits of 8 bits making up the solution for each
%%of the solution elements
x1_arr = [theSolution(2), theSolution(3), theSolution(4), theSolution(5)];

x2_arr = [theSolution(7), theSolution(8), theSolution(9), theSolution(10)];

x3_arr = [theSolution(12), theSolution(13), theSolution(14), theSolution(15)];

x4_arr = [theSolution(17), theSolution(18), theSolution(19), theSolution(20)];

x5_arr = [theSolution(22), theSolution(23), theSolution(24), theSolution(25)];

solutionMatrix = [x1_arr; x2_arr; x3_arr; x4_arr; x5_arr];

elementMultipliers = [1, 1, 1, 1, 1];

solutionVector = [1, 1, 1, 1, 1];

for i = 1 : length(solutionMatrix)
    %Checking to see if the MSB of the solution is '1'
    %This will only be true if the solution element 
    %being considered in this case is a negative number
    
    %%%Negative numbers%%%%%%%%%%%    
    if solutionMatrix(i, 2) == 255
        
        %This number will eventually be multiplied with the final value of
        %the solution element
        elementMultipliers(i) = -1;
        
        %%%%Conversion of the 2's complement negative number starts here%%%%
        %%%%%%%%%%%%%%%
        %Inverting every bit of the four 8 bit digits representing the
        %solution element
        
        solutionMatrix(i, 1) = 255 - solutionMatrix(i, 1);
        solutionMatrix(i, 2) = 255 - solutionMatrix(i, 2);
        solutionMatrix(i, 3) = 255 - solutionMatrix(i, 3);
        solutionMatrix(i, 4) = 255 - solutionMatrix(i, 4);

        
        %Adding one to the solution element
        solutionMatrix(i, 4) = solutionMatrix(i, 4) + 1;
        %%%%%%%%%%%%%%%
        %%%%Conversion of the 2's complement negative number ends here%%%%
        
        %Summing up the digits in order to obtain the solution element
        solutionVector(i) = solutionMatrix(i, 1) * 255 + solutionMatrix(i, 2) + (solutionMatrix(i, 3)/255) + (solutionMatrix(i, 4)/65536);
               
    %%%Positive numbers%%%%%%%%%%%%%%
    else
        %Summing up the digits in order to obtain the solution element
        solutionVector(i) = solutionMatrix(i, 1) + solutionMatrix(i, 2) + (solutionMatrix(i, 3)/255) + (solutionMatrix(i, 4)/65536);
    end;
end;

solutionVector = elementMultipliers .* solutionVector;

fclose(thePort)

delete(thePort)

clear thePort

%Printing out the values in the solution vector as computed by the FPGA
fprintf('The values obtained from the FPGA implementation:\n%d, %d, %d, %d, %d\n\n', solutionVector(1), solutionVector(2), solutionVector(3), solutionVector(4), solutionVector(5));

%%**End of the FPGA implementation*****%%%%%%%%%%%%%

plot(x, 'b*');
hold on;
plot(solutionVector, 'rx');
title('Plot of values obtained in MATLAB implementation vs. FPGA implementation for : A = [6 2 3 4 5; 1 8 3 4 5; 1 2 7 4 5; 1 2 3 8 5; 1 2 3 4 9], and b = [5 4 3 2 1]');
legend('MATLAB implementation', 'FPGA Implementation');