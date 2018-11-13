{string} Products = ...;
{string} Components = ...;

float usage[Products][Components] = ...;
float profit[Products] = ...;
float stock[Components] = ...;

dvar float+ production[Products];


maximize
  sum (p in Products) profit[p] * production[p];
subject to {
  forall (c in Components)
    sum (p in Products) usage[p][c] * production[p] <= stock[c];
}






