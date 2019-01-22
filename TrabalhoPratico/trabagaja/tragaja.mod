/*********************************************
 * OPL 12.8.0.0 Model
 * Author: Celia
 * Creation Date: 20/01/2019 at 01:02:20
 *********************************************/

  
 {string} products = ...;
 {string} components = ...;
 {string} supliers = ...;
 {string} clients = ...;
 
 int P =...;
 range period = 1..P;
   
  /*Parametros*/
  
 int capacidadeR1=...;
 int custoExtensao=...;

 int custoProducao[products]=...;
 int QtdProdutos[products]=...; 
 int consumoComponentes[products][components]=...;
 int consumoR1[products]=...;
 int qtdstockProdutos[products]=...;
 int custoArmazenamentoProduto[products]=...;
 
 int qtdstockComponentes[components]=...;
 float custoArmazenarComponente[components]=...;
 int custoUnitarioPorComponenteS1[components]=...;
 int custoUnitarioPorComponenteS2=...;
 
 int capacidadeTransporte=...;

 
 int procura[products][clients][period]=...;


 
 /* Variaveis Decisao */

dvar int+ Producao [products][period];
dvar int+ qtdComponentesConsumidos[components][period];
dvar int+ QtdFornecidaProdutos[products][clients][period];
dvar int+ QtdFornecidaComponenteS1[components][period];
dvar int+ QtdFornecidaComponenteS2[period];
dvar int+ QtdArmazenadaProdutos[products][1..P+1];
dvar int+ QtdArmazenadaComponentes[components][0..P];
//extenção capacidade
dvar int+ extensaoCapacidade [period] ;


dvar int+ QtdProduzida[products][period];
dvar int+ NumeroHorasExtra[period];

/*Funcao Objetivo*/

 minimize sum (j in period) 
(sum (i in products) QtdProduzida[i][j] * custoProducao[i] 
+ sum (k in components) (QtdFornecidaComponenteS1[k][j] * custoUnitarioPorComponenteS1[k] + 
QtdFornecidaComponenteS2[j] * custoUnitarioPorComponenteS2) + NumeroHorasExtra[j] * custoExtensao
+ sum (i in products) QtdArmazenadaProdutos[i][j] *  custoArmazenamentoProduto[i]
+ sum (k in components)  QtdArmazenadaComponentes[k][j] * custoArmazenarComponente[k]);
  

 /*Restricoes*/
 
 subject to {
 
forall (j in period)
 extensaoCapacidade[j]<=8;  
 
forall(k in components) QtdArmazenadaComponentes[k][0] == qtdstockComponentes[k];
forall(i in products) QtdArmazenadaProdutos[i][1] == qtdstockProdutos[i];
forall (i in products, j in period) QtdProduzida[i][j] + QtdArmazenadaProdutos[i][j] 
>= sum (m in clients) procura[i][m][j];

forall (i in products, m in clients)
sum (j in period) QtdFornecidaProdutos[i][m][j] == sum(j in period) procura [i][m][j];

forall(i in products, j in period) Producao[i][j] * QtdProdutos[i] ==QtdProduzida[i][j];

forall (j in period, k in components)
  qtdComponentesConsumidos["Component1"][j] <= QtdFornecidaComponenteS1[k][j] +  QtdFornecidaComponenteS2[j];
	
forall (j in period, i in products)
sum (m in clients) QtdFornecidaProdutos[i][m][j] <= QtdProduzida[i][j] +  QtdArmazenadaProdutos[i][j];	
  
forall(j in period)
sum(k in components) QtdFornecidaComponenteS1[k][j] <= capacidadeTransporte;

forall (i in products, j in period)
QtdArmazenadaProdutos[i][j] + QtdProduzida[i][j] - 
sum (m in clients) QtdFornecidaProdutos[i][m][j] == QtdArmazenadaProdutos[i][j+1];

forall (k in components, j in period) 
qtdComponentesConsumidos[k][j] == sum (i in products) 
(consumoComponentes[i][k] * Producao[i][j])- QtdArmazenadaComponentes[k][j];

forall (k in components, j in period)
  QtdArmazenadaComponentes[k][j-1] + qtdComponentesConsumidos[k][j]- 
  sum(i in products) (consumoComponentes[i][k] * Producao[i][j]) == QtdArmazenadaComponentes[k][j];
  
forall(j in period) 
sum (i in products) consumoR1[i] * Producao[i][j] <= capacidadeR1 + extensaoCapacidade[j];



}

 
