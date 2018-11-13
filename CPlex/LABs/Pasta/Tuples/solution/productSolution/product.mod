/*********************************************
 * OPL Model
 * Author: IBM ILOG
 *********************************************/
 
{string} Products = ...;
{string} Resources = ...;

tuple ProductData {
   float demand;
   float insideCost;
   float outsideCost;
   float consumption[Resources];
}
ProductData product[Products] = ...;
float availability[Resources] = ...;
float maxOutsideProduction = ...; // The maximum amount that may be outsourced for any product.

dvar float+ insideProduction[Products];
dvar float+ outsideProduction[Products] in 0..maxOutsideProduction;

minimize
   sum(p in Products) (product[p].insideCost*insideProduction[p] + 
                       product[p].outsideCost*outsideProduction[p]);
subject to {
   forall(r in Resources)
      resourceAvailability: sum(p in Products) product[p].consumption[r] * insideProduction[p] <= availability[r];
   forall(p in Products)
      demandFulfillment: insideProduction[p] + outsideProduction[p] >= product[p].demand;
}
