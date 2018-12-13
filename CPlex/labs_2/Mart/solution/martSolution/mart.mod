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
 

// Using Set with external Initialization ( .dat file : plain file, Excel, Data Base...)
 {Product} products = ...;
 					   
 					   			   
 //Product Supply				   
 tuple Supply
 {
 	key string product;
 	int minimumStockValue; // minimim quantity to be ordered for stock/sale
 	int maximumStockValue; // potential maximum extra ordered quantity 
 }
 
 
 // Using Set with external Initialization ( .dat file : plain file, Excel, Data Base...)
 {Supply} supplies = ...;
 					   
  
 // Shelves		 
 tuple Shelf 
 {
 	key string name; // shelf name
 	int volumeCapacity; //maximum capacity
	float  promotionAccelerator; // indicator in between 0 and 1
 	int cold; // 1 for refrigeration, 0 otherwise
}

// Using Set with external Initialization ( .dat file : plain file, Excel, Data Base...)
{Shelf} shelves = ...;
		
		
// Trace for displaying input data using IBM ILOG Script		
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
// Use Generic set initialization
{ProductShelfCompatibility} coldCompatibilities = { <p,s> | p in products, s in shelves : p.cold ==1 && s.cold == 1};

//Use Script for set Initialization
/*{ProductShelfCompatibility} coldCompatibilities;
execute InitializeColdCompatibilities
{
	writeln("Initialize coldCompatibilities :");
	for ( var p in products) {
	 for ( var s in shelves) {
	 	if ( p.cold == 1 && s.cold == 1)
	 	 coldCompatibilities.add(p,s);
	 }
	}
}
*/



// Compatibility between dry  products and shelves
// Use Generic set initialization
{ProductShelfCompatibility} dryCompatibilities = { <p,s> | p in products, s in shelves : p.cold ==0 && s.cold == 0};

// All Compatibilities
// Calculate combination of all compatibilities
{ProductShelfCompatibility} compatibilities = coldCompatibilities union dryCompatibilities;

//----------------------------------------------------------------------------------------
//Decision Variables
//----------------------------------------------------------------------------------------

// Use set as an index over variables for displayed product quantities over shelves
dvar float storedQuantities[compatibilities] in 0..maxint;

// Use set as an index over variables for product total ordered quantities	
dexpr float orderedQuantities[ p in products] = sum(compat  in compatibilities : compat.product == p) storedQuantities[compat];


//----------------------------------------------------------------------------------------
// Objective
//----------------------------------------------------------------------------------------
// Profit margin for each product/shelf association according to promotional acceleration of shelf
dexpr float profit = sum(c in compatibilities) storedQuantities[c] * c.shelf.promotionAccelerator * c.product.margin;

// Maximize Profit margin
maximize profit;


//----------------------------------------------------------------------------------------
// Constraints
//----------------------------------------------------------------------------------------
subject to
{

// Minimum and Maximum product provision ( built in in the orderedQuantities variable declaration)
// For all products the sum of the ordered quantities shall be at least equal to the minimum stock value and
// Shall not exceed the maximum ordered quantity

// For all products the sum of the ordered quantities shall be at least equal to the minimum stock value 
forall( p in products, s in supplies: s.product == p.name){
	MinStockCst: orderedQuantities[p] >= s.minimumStockValue;
}

// The sum or ordered quantities shall not exceed the maximum ordered quantity
forall( p in products, s in supplies: s.product == p.name){
	MaxStockCst: orderedQuantities[p] <= s.maximumStockValue;
}	
	
	
// Do not exceed shelf capacities
// For all shelves the sum of the displayed products quantities * product unit volume shall not exceed the
// shelf total volume capacity 
forall( s in shelves)
	ShelfCapacityCst: sum(  compat  in compatibilities : compat.shelf == s) storedQuantities[compat] * compat.product.unitVolume 
		<= s.volumeCapacity;
}

//----------------------------------------------------------------------------------------
// Results
//----------------------------------------------------------------------------------------

// Diplayed Quantity for all Product/Shelf Pairs
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
	float usagePercentage;
}

// Purchased Quantity fore all Products
tuple PurchaseOrderResult
{
	string product;
	float quantity;
}


// Generic Initialization of result sets according to input data and decision variable values
{PurchaseOrderResult} POResults = {  <p.name,orderedQuantities[p]> | p in products};

// Generic Initialization of result sets according to input data and decision variable values
{StorageResult} storageResults = { <c.product.name,c.shelf.name,storedQuantities[c]>  | c in compatibilities};


// Generic Initialization of result sets according to input data and decision variable values
{ShelfUsage} shelfUsages = { <s.name, sum(c in compatibilities : c.shelf == s) storedQuantities[c] /s.volumeCapacity>  | s in shelves};


// Result Display - use IBM ILOG Script for post-processing
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

