/*********************************************
 * OPL 6.3 Model
 * Author: IBM ILOG
 *********************************************/

//----------------------------------------------------------------------------------------
//Input Data
//----------------------------------------------------------------------------------------

 // Product characteristics
 tuple Product 
 {
	key string name; // Product name. 
 	float margin; // Profit margin 
 	float unitVolume; // Volume for one unit of product
  	int cold; // 1 for refrigeration, 0 otherwise
 };
  {Product} products = ...;
 

// Using Set with external Initialization ( .dat file : plain file, Excel, Data Base...)
// Import Products from dat file in products set
// To Fill					   
 					   			   
 //Product Supply				   
 tuple Supply
 {
 	key string product;
 	int minimumStockValue; // minimim quantity to be ordered for stock/sale
 	int maximumStockValue; // potential maximum extra ordered quantity 
 }
 
 {Supply} supplies = ...;
 
 
 
// Using Set with external Initialization ( .dat file : plain file, Excel, Data Base...)
// Import Products Supplies  from dat file in supplies set
// To Fill 					   


 
 // Shelves		 
 tuple Shelf 
 {
 	key string name; // shelf name
 	int volumeCapacity; //maximum capacity
	float  promotionAccelerator; // indicator in between 0 and 1
 	int cold; // 1 for refrigeration, 0 otherwise 
}

{Shelf} shelves = ...;

// Using Set with external Initialization ( .dat file : plain file, Excel, Data Base...)
// Import shelves  from dat file in shelves  set
// To Fill
		
		
// Trace for displaying input data		
execute Diplay_Input_data
{
 writeln("Products: ");
 writeln( products);


 writeln("Supplies: ");
 writeln( supplies);
 
 writeln("Shelves: ");
 writeln( shelves);
  		
}


//----------------------------------------------------------------------------------------
//Intermediate data
//----------------------------------------------------------------------------------------\			   
// Product / Shelf Compatibility pairs used for decision variable indexing
// One variable will be declared in order to decide which quantity of which product is displayed on
// which shelf.
// Only necessary Product/Shelf combination are created
// * Cold products can only be displayed on cold shelves.
// * Dry products can only be displayed on dry shelves			   
tuple ProductShelfCompatibility
{
	Product product;
	Shelf shelf;
}
 
// Compatibility between cold products and shelves
// Use Generic set initialization in order to select cold products and shelves pairs
{ProductShelfCompatibility} coldCompatibilities = { <p,s> | p in products, s in shelves : p.cold ==1 && s.cold == 1};


// Compatibility between dry  products and shelves
// Use Generic set initialization in order to select dry product and shelves pairs
{ProductShelfCompatibility} dryCompatibilities = { <p,s> | p in products, s in shelves : p.cold ==0 && s.cold == 0};

// All Compatibilities
// Aggregate  combinations of all compatibilities
{ProductShelfCompatibility} compatibilities = coldCompatibilities union dryCompatibilities; 

//----------------------------------------------------------------------------------------
//Decision Variables
//----------------------------------------------------------------------------------------

// Use Compatibilities set as an index over variables for displayed  product quantities over shelves
// Remark: Variables are only created for compatible product/shelf pairs

dvar float storedQuantities[compatibilities] in 0..maxint;

// Use set as an index over variables for product total ordered quantities	
dexpr float orderedQuantities[ p in products] = sum(compat  in compatibilities : compat.product == p) storedQuantities[compat];


//----------------------------------------------------------------------------------------
// Objective
//----------------------------------------------------------------------------------------
// Profit margin expression cumulating for  each product/shelf association 
// according to displayed quantity and promotional, product price and shelf promotion acceleration factor
dexpr float profit = sum(c in compatibilities) storedQuantities[c] * c.shelf.promotionAccelerator * c.product.margin;


// Maximize Profit margin
maximize profit;


//----------------------------------------------------------------------------------------
// Constraints
//----------------------------------------------------------------------------------------
subject to
{

// For all products the sum of the ordered quantities shall be at least equal to the minimum stock value 
forall( p in products, s in supplies: s.product == p.name){
	MinStockCst: orderedQuantities[p] >= s.minimumStockValue;
}

// The sum or ordered quantities shall not exceed the maximum ordered quantity
forall( p in products, s in supplies: s.product == p.name){
	MaxStockCst: orderedQuantities[p] <= s.maximumStockValue;
}	
	
	
// Do no exceed shelf capacities
// For all shelves the sum of the displayed products quantities * product unit volume shall not exceed the
// shelf total volume capacity 
forall( s in shelves)
	ShelfCapacityCst: sum(  compat  in compatibilities : compat.shelf == s) storedQuantities[compat] * compat.product.unitVolume 
		<= s.volumeCapacity;
}

//----------------------------------------------------------------------------------------
// Results
//----------------------------------------------------------------------------------------

// Displayed  Quantity for all Product/Shelf Pairs
tuple StorageResult
{
	string product;
	string shelf;
	float quantity;
}

// Shelf Capacity Usage
tuple ShelfUsage
{
	string shelf;
	float usagePercentage; // shelfVolumeUsageExpr/ shelfVolumeCapacity
}

// Purchased Quantity fore all Products
tuple PurchaseOrderResult
{
	string product;
	float quantity;
}


// Generic Initialization of result sets according to input data and decision variable values
{PurchaseOrderResult} POResults =  {  <p.name,orderedQuantities[p]> | p in products};


// Generic Initialization of result sets according to input data and decision variable values
{ShelfUsage} shelfUsages = { <s.name, sum(c in compatibilities : c.shelf == s) storedQuantities[c] /s.volumeCapacity>  | s in shelves};

// Generic Initialization of result sets according to input data and decision variable values
{StorageResult} storageResults = { <c.product.name,c.shelf.name,storedQuantities[c]>  | c in compatibilities};

// Result Display
execute DisplayResult
{

	writeln("Margin: " +  profit + " Euros" );

	writeln("Purchase Orders:");
	for ( var po in POResults)
	{
		writeln("PO for " +  po.product + " : " + po.quantity); 
	}	
	writeln("");
	
	writeln("Shelf Usage:");
	for ( var su in shelfUsages)
	{
		writeln("Shelf " +  su.shelf + " usage : " + su.usagePercentage * 100 + "%");
	}
	writeln("");
	
	writeln("Storage ");
	for ( var sr in storageResults)
	{
		writeln("Storage for product " +  sr.product +  
				" in Shelf"  + sr.shelf + 
				" : " + sr.quantity)
	}
	
}

