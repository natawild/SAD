/*********************************************
 * OPL Model
 * Author: IBM ILOG
 *********************************************/
 
/*******
* Data *
*******/

{string} Warehouses = ...;
int NbStores = ...;
range Stores = 0..NbStores-1;

int FixedCost = ...;                         // fixed cost for opening a warehouse
int Capacity[Warehouses] = ...;              // maximum number stores assigned to each warehouse
int SupplyCost[Stores][Warehouses] = ...;    // supply cost between each store and each warehouse

/*********************
* Decision variables *
*********************/

dvar boolean Open[Warehouses];               // 1 if warehouse is open, 0 otherwise
dvar boolean Supply[Stores][Warehouses];     // 1 if store supplied by warehouse, 0 otherwise   

/*********************
* Objective function *
*********************/

minimize
  sum( w in Warehouses ) FixedCost * Open[w] 
  + sum( w in Warehouses , s in Stores ) SupplyCost[s][w] * Supply[s][w];
    
/**************
* Constraints *
**************/

subject to{
   
  forall( s in Stores )
    ctEachStoreHasOneWarehouse: sum( w in  Warehouses ) Supply[s][w] == 1;
    
  forall( w in Warehouses, s in Stores )
    ctUseOpenWarehouses: Supply[s][w] <= Open[w];
    
  forall( w in Warehouses )
    ctMaxUseOfWarehouse: sum( s in Stores ) Supply[s][w] <= Capacity[w];
}

// this script is only for clearer output in the Console and serves no computational purpose
{int} storesof[w in Warehouses] = { s | s in Stores : Supply[s][w] == 1 };
execute {
   writeln("open=",open);
   writeln("storesof=",storesof);
}
