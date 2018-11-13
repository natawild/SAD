/*********************************************
 * OPL Model file
 * Author: Ilog
 * Creation date: 3/7/2006 1:48 PM
 *********************************************/

{string} Products = ...;
float Atime[Products] = ...;
float Ptime[Products] = ...;
float profit[Products] = ...;
int minProd[Products] = ...; // the minimum production
float Aavail = ...;
float Pavail = ...;

dvar int+ production[Products]; //the number of products must be an integer




maximize
   sum (p in Products) profit[p] * production[p];
subject to {
   forall (p in Products)
      production[p] >= minProd[p]; //This constraint is not labeled; it is a constrained decision variable only.
                               //As it represents a minimum well below production objectives, there is
                               //little or no interest to use it for relaxation. 
      ct2: sum (p in Products) Atime[p] * production[p] <= Aavail;
      ct3: sum (p in Products) Ptime[p] * production[p] <= Pavail;
      
}