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
 
 //Capacidade
 int capacidadeR1=...;
 //extensao da capacidade horas de trabalho no maximo 16
 
 int taxaProducao[Produtos]=...; 
 
 int custoAtraso[Produtos]=...; 
 
 int custoNaoEntrega [Produtos]=...; 
 
 int tempoDeProcessamentoProdutos[Produtos]=...; 
 

 
 
 /*Parametros*/
  


 int custoExtensaoCapacidade=...;

 int custoProducao[Produtos]=...;

 int consumoComponentes[Produtos][Componentes]=...;
 int consumoR1[Produtos]=...;

 int custoArmazenamentoProduto[Produtos]=...;
 

 float custoArmazenarComponente[Componentes]=...;
 int custoUnitarioPorComponenteS1[Componentes]=...;
 int custoUnitarioPorComponenteS2=...;
 

 
int procura[Produtos][Clientes][periodo]=...;


 
 /* Variaveis Decisao */
//Quantidade do produto p produzido no periodo i 
dvar int+ QuantidadeProduzida [Produtos][periodo] ;

//extenção capacidade
dvar int+ extensaoCapacidade [periodo] ;

//Quantidade entregue do produto i no dia j  
dvar int+ quantidadeEntregue[Produtos][periodo]; 

//Quantidade armazenada do produto i, para o cliente j no periodo d
dvar int+ quantidadeArmazenada[Produtos][periodo]; 

//Quantidade do componente c fornecido pelo fornecedor s 
dvar int+ quantidadeFornecidaFornecedorS1[Componentes][periodo]; 
//Quantidade do componente c fornecido pelo fornecedor s 
dvar int+ quantidadeFornecidaFornecedorS2[Componentes][periodo]; 

//quantidades dos componentes produzidos 
dvar int+ quantidadeComponentesConsumidos[Componentes][periodo]; 




/*Funcao Objetivo*/

 minimize sum (p in Produtos, i in periodo, c in Componentes)  (QuantidadeProduzida[p][i]*custoProducao[p]+
  quantidadeArmazenada[p][i]*custoArmazenamentoProduto[p]+ quantidadeFornecidaFornecedorS1[c][i]*custoUnitarioPorComponenteS1[c]
  +quantidadeFornecidaFornecedorS2[c][i]*custoUnitarioPorComponenteS2 ); 

 /*Restricoes*/
 
 subject to {
 //capacidade de producao
 forall(p in Produtos, i in periodo)
    QuantidadeProduzida[p][i]*(consumoR1[p]/taxaProducao[p])<=capacidadeR1+extensaoCapacidade[i]; 
 //procura 
forall(p in Produtos,d in periodo)
  quantidadeEntregue[p][d] + quantidadeArmazenada[p][d] >= sum (c in Clientes) procura[p][c][d]; 
  
  //Componentes que são necessários para a producão do x1 1
  forall (c in Componentes, i in periodo)
    quantidadeComponentesConsumidos["X1"][i]<=quantidadeFornecidaFornecedorS1[c][i]+quantidadeFornecidaFornecedorS2[c][i]; 
  

}

