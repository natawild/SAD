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

float maxOutsideProduction = ...; 
float maxOutsideFlow = ...;

tuple internalLinkData    
{                     
  string l;   
  int w;
  int value;
}
{internalLinkData} internalArcs with l in Locations, w in Warehouses =...; //these tuple sets are similar to the tuple sets in sparseDelivery.mod
                                 //this is not enough to make this model truly sparse
tuple externalLinkData    
{                    
  int w;
  int value;
}
{externalLinkData} externalArcs with w in Warehouses =...; 

// These declarations describe the arcs from  
// internal or external source to warehouse
int internalArc[l in Locations][w in Warehouses];
int externalArc[w in Warehouses];

execute
{
 for(var i in internalArcs) internalArc[i.l][i.w]=i.value;  
 for(var e in externalArcs) externalArc[e.w]=e.value;  
}


dvar float+ insideProduction[Products][Locations];
dvar float+ outsideProduction[Products] in 0..maxOutsideProduction;

// new decision variables: amount of each product to deliver to each warehouse
dvar float+ insideFlow[Products][Locations][Warehouses];
dvar float+ outsideFlow[Products][Warehouses] in 0..maxOutsideFlow;

minimize
    // add the production costs
    sum(<p,l,ic> in insideCost) ic * insideProduction[p][l]
    + sum(<p,oc> in outsideCost)(oc * outsideProduction[p])
    
    // add the transportation costs
    + sum(p in Products, l in Locations, w in Warehouses)(internalArc[l][w] * insideFlow[p][l][w])
    + sum(p in Products, w in Warehouses)(externalArc[w] * outsideFlow[p][w]);
    
subject to {
   // resource availability constraint
   forall(<r,l,a> in availability)
      resourceAvailability: sum(<p,r,c> in consumption) (c * insideProduction[p][l] ) <= a;

   // demand fulfillment constraint
   forall(<p,w,d> in demand)
      demandFulfillment: outsideFlow[p][w] 
      + sum(l in Locations )(insideFlow[p][l][w]) >= d;
       
   // the amount outsourced to warehouses should equal the outside production
   forall(p in Products)
      outsideBalance: sum(w in Warehouses )(outsideFlow[p][w]) == outsideProduction[p];
      
   // the amount shipped from production locations should equal the inside production
   forall(p in Products, l in Locations)
      insideBalance: sum(w in Warehouses)(insideFlow[p][l][w])
      == insideProduction[p][l];
      
   // only use approved shipping lanes
   forall(p in Products, l in Locations, w in Warehouses : internalArc[l][w] == 0)
      insideFlow[p][l][w] == 0;
   forall(p in Products, w in Warehouses : externalArc[w]==0)
      outsideFlow[p][w] == 0;
      
}



