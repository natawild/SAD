/*********************************************
 * OPL Model file
 * Author: Ilog
 * Creation date: 3/7/2006 1:48 PM
 *********************************************/

//declare a set of products
{string} Products = { "desk", "cell" };

//declare data
float Atime[Products] = [0.2, 0.4];
float Ptime[Products] = [0.5, 0.4];
float Aavail = 400;
float Pavail = 490;
float profit[Products] = [12, 20];
float minProd[Products] = [100, 100];

//declare an array of decision variables
dvar float+ production[Products];

//declare objective function and constraints
maximize
   sum (p in Products) profit[p] * production[p];
subject to {
   forall (p in Products)
      production[p] >= minProd[p];
      sum (p in Products) Atime[p] * production[p] <= Aavail;
      sum (p in Products) Ptime[p] * production[p] <= Pavail;
      
}