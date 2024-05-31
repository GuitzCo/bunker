 /*---////////////////  HML  //////////////----
 * Para cálculo de TPV/MDR foi utilizada a tabela [Adquirencia.masters.BaseProcessada]
* Para cálculo de RAV foi utilizada a tabela [mining.dbo.AntecipacaoSubAdquirencia]
*/
DECLARE @DataInicial DATE = '2023-12-01';
DECLARE @DataFinal   DATE = '2023-12-31';

SELECT		 CONCAT(t0.Ano,' -', t0.Mes) AS AnoMes
			,t6.CodigoClienteRedeFlex
			,t6.EntidadePontoCapturaId
			,t0.IdTerminal
			,t7.NomeFatansia
			,t7.CPF_CNPJ
			,t1.NomeModelo
			,ISNULL(t6.ValorAluguel,0) AS ValorAluguel
			,SUM(t0.Valor) AS TPV			
			,TPV_Total = ( SELECT  SUM(t99.Valor)  FROM	Adquirencia.dbo.TransacoesSumarizadas t99 WITH(NOLOCK)
													INNER JOIN	Adquirencia.masters.Terminal t1 WITH(NOLOCK) 
													ON			t1.IdTerminal = t99.IdTerminal								
													INNER JOIN	Adquirencia.masters.Estabelecimento t2 WITH(NOLOCK) 
													ON			t2.CodigoPessoaEstabelecimento = t1.CodigoPessoaEstabelecimento										
												INNER JOIN	Adquirencia.masters.ArranjoPagamento t3 WITH(NOLOCK) 
												ON			t3.CodigoProdutoCartaoAdquirente = t99.CodigoProdutoCartao 
												AND			t3.RedeAdquirenteId = t99.CodigoRedeAdquirente										
											INNER JOIN	Adquirencia.dbo.EntidadePontoCaptura t66 WITH(NOLOCK)
											ON			t66.CodigoMasters = t1.IdTerminal 										
									INNER JOIN	INTRAFLEX.dbo.Cliente t7 WITH(NOLOCK) 
									ON			t7.CodigoAdquirencia = t1.CodigoPessoaEstabelecimento										
								WHERE	t99.Ano =   YEAR(@DataInicial) 
								  AND	t99.Mes =  MONTH(@DataInicial)
								  AND   t66.CodigoClienteRedeFlex = t6.CodigoClienteRedeFlex
								)					
			,TPVRecarga = ( SELECT ISNULL(SUM(ValorLiquidoTotal) ,0) 
	  						      FROM Operadoras.dbo.VendaComercialAgrupadaProdutoFilhoDia tt
	  							      WHERE tt.CodigoClienteRedeFlex = t6.CodigoClienteRedeflex
	  							        AND tt.DataVenda BETWEEN @DataInicial AND @DataFinal
	  							        AND tt.Produto LIKE 'Recarga Online'
								)
			,ReceitaRAV = (	SELECT ISNULL(SUM(ValorReceitaAntecipacao),0)
								  FROM mining.dbo.AntecipacaoSubAdquirencia antsub
									  WHERE antsub.CodigoClienteRedeFlex = t6.CodigoClienteRedeflex	
										AND DataLiquidacaoRealizada BETWEEN @DataInicial AND @DataFinal
								)
			,ReceitaMDR = (	SELECT ISNULL(SUM(ValorMdrRedeflex) - SUM(ValorPagarCliente),0) 
								  FROM Adquirencia.masters.BaseProcessada bp
								      WHERE bp.CodigoClienteRedeFlex = t6.CodigoClienteRedeflex
									    AND DataProcessamento BETWEEN @DataInicial AND @DataFinal 
								)
			,'MDR + RAV' = ((	SELECT ISNULL(SUM(ValorReceitaAntecipacao),0)
								  FROM mining.dbo.AntecipacaoSubAdquirencia antsub
									  WHERE antsub.CodigoClienteRedeFlex = t6.CodigoClienteRedeflex	
										AND DataLiquidacaoRealizada BETWEEN @DataInicial AND @DataFinal
								)
							+ (	SELECT ISNULL(SUM(ValorMdrRedeflex) - SUM(ValorPagarCliente),0) 
								  FROM Adquirencia.masters.BaseProcessada bp
								      WHERE bp.CodigoClienteRedeFlex = t6.CodigoClienteRedeflex
									    AND DataProcessamento BETWEEN @DataInicial AND @DataFinal 
								))

	FROM	Adquirencia.dbo.TransacoesSumarizadas t0 WITH(NOLOCK)
			INNER JOIN	Adquirencia.masters.Terminal t1 WITH(NOLOCK) 
			ON			t1.IdTerminal = t0.IdTerminal
			AND			t1.CodigoStatus = 1

			INNER JOIN	Adquirencia.masters.Estabelecimento t2 WITH(NOLOCK) 
			ON			t2.CodigoPessoaEstabelecimento = t1.CodigoPessoaEstabelecimento

			INNER JOIN	Adquirencia.dbo.EntidadePontoCaptura t6 WITH(NOLOCK)
			ON			t6.CodigoMasters = t1.IdTerminal 
			
			INNER JOIN	INTRAFLEX.dbo.Cliente t7 WITH(NOLOCK) 
			ON			t7.CodigoAdquirencia = t1.CodigoPessoaEstabelecimento

	WHERE	 t0.Ano =   YEAR(@DataInicial) 
	  AND	 t0.Mes =  MONTH(@DataInicial)
	  AND    t6.CodigoClienteRedeflex in (840767)

 group by    t0.Ano, t0.Mes, t6.CodigoClienteRedeflex , t7.NomeFatansia,t7.CPF_CNPJ, t1.NomeModelo, t6.ValorAluguel, t1.NomeModelo
			,t6.EntidadePontoCapturaId ,t0.IdTerminal

 ORDER BY		 t6.CodigoClienteRedeflex 
				,t6.EntidadePontoCapturaId asc


/*
use RedeFlex
select * 
  from RedeFlex.dbo.ClienteSolicitacaoExcecaoAluguel

  order by DataCriacao desc
 */