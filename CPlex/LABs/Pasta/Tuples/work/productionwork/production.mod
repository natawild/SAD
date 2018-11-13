/*********************************************
 * OPL Model
 * Author: IBM ILOG
 *********************************************/

{string} Products = ...;
{string} Resources = ...;

float consumption[Products][Resources] = ...;
float availability[Resources] = ...;
float demand[Products] = ...;
float insideCost[Products] = ...;
float outsideCost[Products]  = ...;
float maxOutsideProduction = ...; // The maximum amount that may be outsourced for any product.

dvar float+ insideProduction[Products];
dvar float+ outsideProduction[Products] in 0..maxOutsideProduction;

minimize
   //Fill in here
   
subject to {
   forall(r in Resources)
      resourceAvailability: //Fill in here

   forall(p in Products)
      demandFulfillment: //Fill in here
}



