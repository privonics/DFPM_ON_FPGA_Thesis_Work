#include "stdafx.h"
#include <iostream>
#include <stdio.h>
//#include <time.h>
#include <Windows.h>
#include <Math.h>

/*
#define _WIN32_WINNT 0x0600
#define NTDDI_WIN7 (0x06010000)
#define _WIN32_WINNT_WIN7 (0x0601)
*/

/*
* This application is used for an estimation of the number of clock cycles used during an execution of 
* the Dynamic Functional Particle Method algorithm. The method can be used to solve many problems requiring 
* numerical methods. In this application, DFPM was used to solve the classical A*X = B problem, 
* where A is a matrix of coefficients, X, a vector of of variables and B a vector of coefficients.
* The values of the variables in vector X are computed by the method and printed to the console/screen.
*
* In order to estimate the number of cycles used, the Kernel and Usertimes were first obtained and then
* the total number of clock cycles used in both Kernel and User modes were obtained. This was done to make it easier
* to identify the number of clock cycles used up in each mode separately.
*
* In this implementation, the actual DFPM algorithm was repeated a thousand (1000) times. This was done 
* in consideration of the fact that a single execution of the algorithm might be completed in a very 
* short time. So short that the time used during both User and Kernel modes for execution might be too 
* small to be noted that they will be registered as zero. Thus making it ifficult to identify the number
* of clock cycles spent in each mode.
*
* By repeating the algorithm a thousand times, and then dividing the number of clock cycles obtained by 
* a thousand. A reasonable approximate of the average number of clock cycles used by the process in user
* mode was obtained.
*/


int main(){
	using namespace std;

	//************Initial initializations
	//Creating matrix A
	int a[5][5] = { { 8, 2, 3, 4, 5 },
					{ 1, 7, 3, 4, 5 },
					{ 1, 2, 9, 4, 5 },
					{ 1, 2, 3, 8, 5 },
					{ 1, 6, 3, 4, 9 } };

	//Creating vector B
	int b[5] = { 1, 2, 3, 4, 5 };

	int mu = 1;

	double dt = 0.1;

	volatile double Ax[5];
	volatile double B_Minus_Ax[5];
	volatile double B_Minus_Ax_Minus_MuV[5];
	volatile double muV[5];

	double tolerance = 7.8125e-3;


	int i, j, count;

	count = 0;

	int noOfCompleteAlgorithmRepetitions = 1000;

	
	//*********** Creating multiple arrays for the vectorNorm and Vectors V and X
	volatile double arrayOfV[1000][5];
	volatile double arrayOfX[1000][5];
	volatile double arrayOfVectorNorm[1000];
	
	for (int outerIndex = 0; outerIndex < noOfCompleteAlgorithmRepetitions; outerIndex++){

		arrayOfVectorNorm[outerIndex] = 10000;

		for (int innerIndex = 0; innerIndex < 5; innerIndex++){
			arrayOfV[outerIndex][innerIndex] = 1;
			arrayOfX[outerIndex][innerIndex] = 1;
		}
	}

	//********Noting the Kernel and User times at the begining of the algorithm execution
	FILETIME creationTime1, exitTime1, kernelTime1, userTime1;
	double startTime_Kernel, startTime_User;
	bool myBool1;

	if (myBool1 = GetProcessTimes(GetCurrentProcess(), &creationTime1, &exitTime1, &kernelTime1, &userTime1)){
		startTime_Kernel = (double)(kernelTime1.dwLowDateTime
			| ((unsigned long long)kernelTime1.dwHighDateTime << 32))*0.0000001;
		startTime_User = (double)(userTime1.dwLowDateTime
			| ((unsigned long long)userTime1.dwHighDateTime << 32))*0.0000001;
	}
	else {
		cout << "Function GetProcessTimes failed on the first call" << endl;
	}

	//***Algorithm computations and repetitions
	while (count < noOfCompleteAlgorithmRepetitions){//Enabling repetition here

		//The actual algorithm
		while (arrayOfVectorNorm[count] > tolerance){

			arrayOfVectorNorm[count] = 0;

			i = 0;

			while (i < 5){

				Ax[i] = 0;

				j = 0;

				while (j < 5){

					//A*X is done here
					Ax[i] += (a[i][j] * arrayOfX[count][j]);
					j++;
				}//Ax[i] gets a new value at this end of the loop

				muV[i] = mu*arrayOfV[count][i];

				B_Minus_Ax[i] = b[i] - Ax[i];

				B_Minus_Ax_Minus_MuV[i] = B_Minus_Ax[i] - muV[i];

				arrayOfVectorNorm[count] += ((B_Minus_Ax[i])*(B_Minus_Ax[i]));

				arrayOfV[count][i] += B_Minus_Ax_Minus_MuV[i] * dt;
				arrayOfX[count][i] += arrayOfV[count][i] * dt;

				i++;
			}
		}
		count++;
	}

	ULONG64 myCycleTime = 0;
	bool myBool3;

	if (myBool3 = QueryProcessCycleTime(GetCurrentProcess(), &myCycleTime)){
		cout << "The The total number of clock cycles used for "
			<< noOfCompleteAlgorithmRepetitions <<" repetitions is : " << myCycleTime << endl;
	}
	else {
		cout << "Failed accessing the Process Cycle time" << endl;
	}


	FILETIME creationTime2, exitTime2, kernelTime2, userTime2;
	double stopTime_Kernel, stopTime_User;
	bool myBool2;

	if (myBool2 = GetProcessTimes(GetCurrentProcess(), &creationTime2, &exitTime2, &kernelTime2, &userTime2)){
		stopTime_Kernel = (double)(kernelTime2.dwLowDateTime
			| ((unsigned long long)kernelTime2.dwHighDateTime << 32))*0.0000001;
		stopTime_User = (double)(userTime2.dwLowDateTime
			| ((unsigned long long)userTime2.dwHighDateTime << 32))*0.0000001;
	} else {
		cout << "Function GetProcessTimes failed on the second call" << endl;
	}



	for (int pos = 0; pos < 5; pos++){
		cout << arrayOfX[count - 1][pos] << endl;
	}

	double totalUserTime = stopTime_User - startTime_User;
	double totalKernelTime = stopTime_Kernel - startTime_Kernel;

	if (myBool1 & myBool2 & myBool3){
		cout << "The number of repetitions is : " << count << endl;
		cout << "The total kernel time in seconds : " << totalKernelTime << endl;
		cout << "The total user time in seconds : " << totalUserTime << endl;
		cout << "The cpu time in seconds : " << (totalKernelTime + totalUserTime) << endl;

		cout << "The total number of clock cycles used during each run of the complete algorithm is : "
			<< (myCycleTime / noOfCompleteAlgorithmRepetitions) << " cycles." << endl;

		cout << "In consideration of the possibility of Kernel time being too low to be measured,"
			<< " the minimum number of processor clock cycles in User mode is : "
			<< (((totalUserTime - (1 * 0.0000001)) / 
			(totalUserTime + totalKernelTime))*(myCycleTime / noOfCompleteAlgorithmRepetitions))
			<< " cycles." << endl;

	}else {
		cout << "One of the processor information obtaining processes failed" <<endl;
	}
	
	return 0;
}