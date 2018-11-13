/*********************************************
 * OPL Model
 * Author: IBM ILOG
 *********************************************/
 
{string} Products = ...;
{string} Resources = ...;
{string} Locations = ...; // declare production locations
range Warehouses = 1..40000; // declare the distributors' warehouses

tuple outsideCostData {
   key string p;
   float oc;   //insideCost and demand have been removed
}
{outsideCostData} outsideCost with p in Products = ...;

tuple insideCostData // InsideCost is now location-specific
{
   key string p;
   key string l;
   float ic;
}
{insideCostData} insideCost with p in Products, l in Locations = ...;

tuple demandData // demand is now warehouse-specific
{
   key string p;
   key int w;
   float d;
}
{demandData} demand with p in Products, w in Warehouses = ...;

tuple consumptionData
{
  key string p;
  key string r;
  float c;           
}
{consumptionData} consumption with p in Products, r in Resources = ...; 

tuple availabilityData
{
  key string r;
  key string l;
  float a;
}
{availabilityData} availability with r in Resources, l in Locations = ...;

tuple internalLinkData // declare allowable internal routes
{
  key string l;
  key int w;
  float cost;
}
{internalLinkData} internalArc with l in Locations, w in Warehouses = ...;

tuple externalLinkData // declare allowable external routes
{
  key int w;
  float cost;
}
{externalLinkData} externalArc with w in Warehouses = ...;

float maxOutsideProduction = ...; 
float maxOutsideFlow = ...; 

dvar float+ insideProduction[Products][Locations];
dvar float+ outsideProduction[Products] in 0..maxOutsideProduction;

// new decision variables: amount of each product to deliver to each warehouse
dvar float+ insideFlow[Products][internalArc];
dvar float+ outsideFlow[Products][externalArc] in 0..maxOutsideFlow;

minimize
    // add the production costs
    sum(<p,l,ic> in insideCost) ic * insideProduction[p][l]
    + sum(<p,oc> in outsideCost)(oc * outsideProduction[p])
    // add the transportation costs
    + sum(p in Products, i in internalArc)(i.cost * insideFlow[p][i])
    + sum(p in Products, e in externalArc)(e.cost * outsideFlow[p][e]);
    
subject to {
   // resource availability constraint
   forall(<r,l,a> in availability)
      resourceAvailability: sum(<p,r,c> in consumption) (c * insideProduction[p][l] ) <= a;

   // demand fulfillment constraint
   forall(<p,w,d> in demand)
      demandFulfillment: sum(<w,c> in externalArc)(outsideFlow[p][<w,c>]) 
      + sum(<l,w,c> in internalArc )(insideFlow[p][<l,w,c>]) >= d;
       
   // the amount outsourced to warehouses should equal the outside production
   forall(p in Products)
      outsideBalance: sum(e in externalArc )(outsideFlow[p][e]) == outsideProduction[p];
      
   // the amount shipped from production locations should equal the inside production
   forall(p in Products, l in Locations)
      insideBalance: sum(<l,w,c> in internalArc)(insideFlow[p][<l,w,c>])
      == insideProduction[p][l];

      }

