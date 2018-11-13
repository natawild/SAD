/*********************************************
 * OPL Model file
 * Author: Ilog
 * Creation date: 3/7/2006 1:48 PM
 *********************************************/

// declare data
{string} Products = ...;
float Atime[Products] = ...;
float Ptime[Products] = ...;
float profit[Products] = ...;
float minProd[Products] = ...;
float Aavail = ...;
float Pavail = ...;

// declare decision variables
dvar float+ production[Products];

// declare objective function and constraints
maximize
   sum (p in Products) profit[p] * production[p];
subject to {
   forall (p in Products)
      production[p] >= minProd[p]; 
      sum (p in Products) Atime[p] * production[p] <= Aavail;
      sum (p in Products) Ptime[p] * production[p] <= Pavail;
      
}

