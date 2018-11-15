/*********************************************
 * OPL Model
 * Author: IBM ILOG
 *********************************************/
 
{string} Products = ...;
{string} Resources = ...;
{string} Locations = ...; // declare production locations
{string} Warehouses = ...; // declare the distributors' warehouses

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
   key string w;
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

// create a tuple named "internalLinkData" containing location, warehouse, and cost
tuple internalLinkData // declare allowable internal routes
{
	string location;
	string warehouse; 
	float cost;
}
// declare the "internalArc" set, making sure that any instance includes the 
// locations and warehouses from the "internalLinkData" tuple


// create a tuple named "externalLinkData" containing warehouse and cost
tuple externalLinkData // declare allowable external routes
{
	string warehouse;
	float cost;
}
// declare the "externalArc" set, making sure that any instance includes the 
// warehouses from the "externalLinkData" tuple

/********************************************************
 * The tuples "internalLinkData" and "externalLinkData" *
 * and the other new material                           *
 * replace these lines from delivery.prj:               *
 *                                                      *
 * int internalArc[Locations][Warehouses]=...;          *
 * int externalArc[Warehouses]=...;                     *
 ********************************************************/
 
float maxOutsideProduction = ...; 
float maxOutsideFlow = ...; 

dvar float+ insideProduction[Products][Locations];
dvar float+ outsideProduction[Products] in 0..maxOutsideProduction;

// new decision variables: amount of each product to deliver to each warehouse
dvar float+ insideFlow[Products][internalArc];
dvar float+ outsideFlow[Products][externalArc] in 0..maxOutsideFlow;

// revise the objective function to take the new structure into account

minimize
    // add the production costs
    sum(<p,l,ic> in insideCost) ic * insideProduction[p][l]
    + sum(<p,oc> in outsideCost)(oc * outsideProduction[p]) // OK
    // add the transportation costs
    // Replace the next two lines with expressions that use the newly defined tuples
    // and arc sets
    + sum(p in Products, l in Locations, w in Warehouses)(internalArc[l][w] * insideFlow[p][l][w])
    + sum(p in Products, w in Warehouses)(externalArc[w] * outsideFlow[p][w]);
    
subject to {
   // resource availability constraint
   forall(<r,l,a> in availability)
      resourceAvailability: sum(<p,r,c> in consumption) (c * insideProduction[p][l] ) <= a;

   // demand fulfillment constraint
   forall(<p,w,d> in demand)
      demandFulfillment: sum(<w,c> in externalArc)(outsideFlow[p][<w,c>]) 
      + sum(<l,w,c> in internalArc )(insideFlow[p][<l,w,c>]) >= d;
       
// Rewrite the following two constraints to take the new definitions of the insideFlow
// and outsideFlow variables into account
   // the amount outsourced to warehouses should equal the outside production
   forall(p in Products)
      outsideBalance: sum(w in Warehouses )(outsideFlow[p][w]) == outsideProduction[p];
      
   // the amount shipped from production locations should equal the inside production
   forall(p in Products, l in Locations)
      insideBalance: sum(w in Warehouses)(insideFlow[p][l][w])
      == insideProduction[p][l];
    
// The remaining constraints are no longer needed, as these conditions
// are guaranteed by the new data structure itself.
   forall(p in Products, l in Locations, w in Warehouses : internalArc[l][w] == 0)
      insideFlow[p][l][w] == 0;
   forall(p in Products, w in Warehouses : externalArc[w]==0)
      outsideFlow[p][w] == 0;
      
}

