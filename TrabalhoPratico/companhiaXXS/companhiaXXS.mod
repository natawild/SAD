/*********************************************
 * OPL 12.8.0.0 Model
 * Author: Celia
 * Creation Date: 19/11/2018 at 10:29:42
 *********************************************/
 {string} Produtos =...;
 {string} Componentes =...; 
 {string} Recursos =...; 
 {string} Fornecedores=...; 
 {string} Clientes = ...; 
 range dia = 1..45;
 
 float HorasDia = ...; //restricao do tempo das maquinas a trabalhar
 float Tx = ...; //taxa de producao do produto i
 float CEC = ...;//Custo da Extensao da capacidade
 
 int tempo = ...;
 


tuple custoComponentes{
 string componente; 
	string fornecedor; 
	float custo; 
}
{custoComponentes} custosFornecedoresComponentes=...;

                
tuple custoProdutos{
	float custoProducao; 
	float custoAtraso; 
	float custoNaoEntrega; 
	float custoArmazenamento; 
} 
custoProdutos custosProdutos[Produtos] = ...;

float custoProducaoProdutos[Produtos]= ...; 
float custoArmazenamentoDia[Produtos][dia]; 


tuple custoArmazenamentoComponente {
	string Componente; 
	float custo; 
}
{custoArmazenamentoComponente} custosArmazenamentoComponente=...;


 tuple consumoProdutos{
 	float consumoX1; 
 	float consumoX2;  
 }
consumoProdutos consumosComponentes[Produtos] = ...;

 
float ConsumoR1[Produtos] = ...;//Consumo de R1 pelo produto i
  
dvar float+ quantidadeProduzida[Produtos];
dvar float+ EC; // duvidas como restringir apenas até 8 i.e do 0 ao 8  
dvar float+ qtatrasada[Produtos][dia];//quantidade de produto i atrasada para o dia d
dvar float+ qtNentregue[Produtos];//quantidade de produto i nao entregue
dvar float+ qtParmazenada[Produtos];//quantidade de produto i armazenada
dvar float+ qtCarmazenada[Componentes];//quantidade de componente c armazenada
dvar float+ qtCfornecedor[Componentes][Fornecedores];//quantidade do componente c fornecida pelo fornecedor s
dvar float+ qtEntregueProdCli[Produtos][Clientes];// quantidade de entregue do produto i ao cliente j


minimize
  	sum (p in Produtos) (quantidadeProduzida[p] * custoProducaoProdutos[p]) + EC*CEC 
  	+ sum(c in Componentes, f in Fornecedores) qtCfornecedor[c][f]
  	+ sum (d in dia, p in Produtos) qtParmazenada[p]
  	+ sum (c in Componentes) qtCarmazenada[c]
  	+ sum (d in dia, p in Produtos) qtatrasada[p][d]
  	+ sum (p in Produtos) qtNentregue[p]   ;
  	
  	
  	
  	
  subject to {
   forall(p in Produtos)
      capacidadeProducao: sum(p in Produtos) ConsumoR1[p]/Tx <= EC;
      
      
  // forall(p in Produtos)
     // procura: sum (p in Produtos) qtEntregueProdCli[p][] ;
   
  // forall (f in Fornecedores)
    // capacidadeDeResposta: 
    
}

 /*
 tuple ProcuraProdutoClientePeriodo
{
  string produto;
  string cliente;
  int periodo; 
  float valor;           //The amount of the resource needed to produce                     //1 unit of the product
}

{ProcuraProdutoClientePeriodo} procuras=...; //declares a set of values which are 

*/
 
  
