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
   float oc;   
}
{outsideCostData} outsideCost with p in Products = ...;

tuple insideCostData 
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

tuple availabilityData // availability is now location-specific
{
  key string r;
  key string l;
  float a;
}
{availabilityData} availability with r in Resources, l in Locations = ...;

float maxOutsideProduction = ...; 
float maxOutsideFlow = ...;  // the maximum amount of outside production to be delivered to any one warehouse

// These declarations describe the arcs from  
// internal or external source to warehouse
int internalArc[Locations][Warehouses]=...;
int externalArc[Warehouses]=...;

dvar float+ insideProduction[Products][Locations];
dvar float+ outsideProduction[Products] in 0..maxOutsideProduction;

// new decision variables: amount of each product to deliver to each warehouse
dvar float+ insideFlow[Products][Locations][Warehouses];
dvar float+ outsideFlow[Products][Warehouses] in 0..maxOutsideFlow;
// outsideFlow is limited by contraction limit of maxOutsideFlow

// the last two lines of the objective function minimize the transportation costs
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
      demandfulfillment: outsideFlow[p][w] 
      + sum(l in Locations )(insideFlow[p][l][w]) >= d;
       
   // the amount outsourced to warehouses should equal the outside production
   forall(p in Products)
      outsideBalance: sum(w in Warehouses )(outsideFlow[p][w]) == outsideProduction[p];
      
   // the amount shipped from production locations should equal the inside production
   forall(p in Products, l in Locations)
      insideBalance: sum(w in Warehouses)(insideFlow[p][l][w])
      == insideProduction[p][l];
      
   // only use approved shipping lanes: flow of arcs with zero cost is set to zero
   forall(p in Products, l in Locations, w in Warehouses : internalArc[l][w] == 0)
      insideFlow[p][l][w] == 0;
   forall(p in Products, w in Warehouses : externalArc[w]==0)
      outsideFlow[p][w] == 0;
}



