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
   sum(p in Products) (insideCost[p]*insideProduction[p] + outsideCost[p]*outsideProduction[p]);
   
subject to {
   forall(r in Resources)
      resourceAvailability: sum(p in Products) consumption[p][r] * insideProduction[p] <= availability[r];

   forall(p in Products)
      demandFulfillment: insideProduction[p] + outsideProduction[p] >= demand[p];
}



