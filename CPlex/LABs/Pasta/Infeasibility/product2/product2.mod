/*********************************************
 * OPL Model
 * Author: IBM ILOG
 *********************************************/
 
{string} Products = ...;
{string} Resources = ...;

tuple ProductData {
   float demand;
   float insideCost;
   float outsideCost;   //Consumption has been removed
}

tuple consumptionData
{
  string product;
  string resource;
  float c;           //The amount of the resource needed to produce 
                     //1 unit of the product
}

{consumptionData} consumption=...; //declares a set of values which are 
                                   //instances of the tuple "consumptionData"

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
      resourceAvailability: sum(<p,r,c> in consumption) c * insideProduction[p] <= availability[r];
   forall(p in Products)
      demandFulfillment: insideProduction[p] + outsideProduction[p] >= product[p].demand;
}



