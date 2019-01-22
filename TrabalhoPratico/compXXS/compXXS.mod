/*********************************************
 * OPL 12.8.0.0 Model
 * Author: Celia
 * Creation Date: 19/01/2019 at 15:15:40
 *********************************************/
 {string} Produtos =...;
 {string} Componentes =...; 
 {string} Fornecedores=...; 
 {string} Clientes = ...; 
 
 int P=...; 

 range periodo = 1..P; 
 range periodoArmazenamento = 0..P+1; 
 
 //Capacidade
 int capacidadeR1=...;
 //extensao da capacidade horas de trabalho no maximo 16
 
 int taxaProducao[Produtos]=...; 
 
 int custoAtraso[Produtos]=...; 
 
 int custoNaoEntrega [Produtos]=...; 
 
 int tempoDeProcessamentoProdutos[Produtos]=...; 
 
 int prazo=...; 
 
 //capacidade de transporte T1
 int capacidadeTransporte=...; 
 
 int custoExtraTransporte=...; 
 
 /*Parametros*/
  
 int custoExtensaoCapacidade=...;

 int custoProducao[Produtos]=...;

 int consumoComponentes[Produtos][Componentes]=...;
 
 int consumoR1[Produtos]=...;

 int custoArmazenamentoProduto[Produtos]=...;
 
 float custoArmazenarComponente[Componentes]=...;
 
 int custoUnitarioPorComponente[Fornecedores][Componentes]=...; 
 
 int procura[Produtos][Clientes][periodo]=...;
 
//int ofertaFornecedores[Fornecedores][Componentes][periodo]=...; 

 /* Variaveis Decisao */
//Quantidade do produto p produzido no periodo i 
dvar int+ QuantidadeProduzida [Produtos][0..P] ;

//extenção capacidade
dvar int+ extensaoCapacidade [periodo] ;

//Quantidade entregue do produto i no dia j ao cliente x 
dvar int+ quantidadeEntregue[Produtos][Clientes][periodo]; 

//quantidades dos componentes consumidos 
dvar int+ quantidadeComponentesConsumidos[Componentes][periodo]; 

//Quantidade Armazenada dos produtos
dvar int+ quantidadeArmazenadaP[Produtos][periodoArmazenamento]; 

//Quantidade Armazenada dos componentes
dvar int+ quantidadeArmazenadaC[Componentes][periodoArmazenamento]; 

//	Quantidade de produto em atraso 
dvar int+ quantidadeAtraso[Produtos][Clientes][periodo]; 

//Quantidade de artigos não entregues 
dvar int+ quantidadeNaoEntregue[Produtos][periodo]; 

//Quantidade entregue dos componentes na empresa 
dvar int+ quantidadeEntregueComponentes[Componentes][Fornecedores][periodo]; 

//Quantidade enviada para os fornecedores 
dvar int+ ofertaFornecedores[Fornecedores][Componentes][periodo]; 



/*Funcao Objetivo*/
 minimize sum ( i in periodo)
 (
 	sum (p in Produtos) QuantidadeProduzida[p][i]*custoProducao[p]+
 	sum (f in Fornecedores, c in Componentes) ofertaFornecedores[f][c][i]*custoUnitarioPorComponente[f][c]+
 	sum (p in Produtos, c in Clientes) quantidadeAtraso[p][c][i]*custoAtraso[p]+ //custos do atraso
 	sum (p in Produtos) quantidadeNaoEntregue[p][i]*custoNaoEntrega[p]+
 	custoExtensaoCapacidade*extensaoCapacidade[i] + //custo das horas extras
 	sum (p in Produtos) custoArmazenamentoProduto[p]*quantidadeArmazenadaP[p][i] + //custo de armazenamento
  	sum (comp in Componentes) quantidadeArmazenadaC[comp][i]*custoArmazenarComponente[comp] 
  ); 



 /*Restricoes*/
 
 subject to {
 //1.capacidade de producao, retrição das horas 
 forall(p in Produtos, i in periodo)
    QuantidadeProduzida[p][i]*(consumoR1[p]/taxaProducao[p])<=capacidadeR1+extensaoCapacidade[i]; 
  
 //limite das horas extras até no máximo 8 
 forall (j in periodo)
 	extensaoCapacidade[j]<=8;  
 	
  //2.procura 
forall(p in Produtos,d in periodo, c in Clientes)
  quantidadeEntregue[p][c][d] + quantidadeArmazenadaP[p][d] >= procura[p][c][d]; 
 
 //no maximo é igual à procura
forall(p in Produtos,d in periodo, c in Clientes)
  quantidadeEntregue[p][c][d] <= procura[p][c][d];
  



}











