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
 
 float HorasDia = ...;//restricao do tempo das maquinas a trabalhar
 
 int tempo;
 int extencao; // 1 se utiliza a extencao capacidade e 0 caso contrário
 
 tuple ProdutoComponenteDados {
 	string produto; 
 	string componente; 
 	float procura; 
 	float custoProducao; 
 	float custoAtraso; 
 	float custoNaoEntrega; 
 	float CustoArmazenamento; 
 }
 
 tuple consumoProduto{
 	string produto; 
 	string componente; 
 	int consumoR1; //Consumo de horas
 	int tempoProcessamento; 
 	int taxaProducao; // número de artigos  
 }
 
 
  
