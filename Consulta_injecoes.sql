	
SELECT	EntidadePontoCapturaID as PontoCapturaID,
		CodigoClienteRedeFlex, 
		CONCAT(Mes,' - ', Ano) as Referencia,
		Descricao as Campanha,
		case
		ClienteRetencao
		when 0 then 'Não'
		When 1 then 'Sim' end as Retencao,
		SolicitacaoExcecaoAluguel = '',
		ModeloPOS,
		isnull(FaturamentoRecarga,0) as FaturamentoRecarga,
		ReceitaRav,
		ReceitaMdr,
		isnull((ReceitaRav + ReceitaMdr ),0) as 'Receita MDR + RAV',
		ValorTpv,
		ValorAluguel,
		ValorSujerido,
		'###' as '####'
  FROM Projetos.dbo.Injecoes_012024
  WHERE
	--EntidadePontoCapturaId in (569602) and
	--Descricao Like '%rata%' --and ValorSujerido > 0
	
	Descricao Like '%sem campanha%' --and ValorSujerido > 0
	and ModeloPOS Like 'Move%' 
	--and ValorAluguel <> ValorSujerido
	--and ValorTpv >= 0 And ValorTpv < 2000 And ValorSujerido <> 120 and ValorAluguel <> ValorSujerido
	--and ValorTpv >= 2000 and ValorTpv < 5000 And ValorSujerido <> 60 and ValorAluguel <> ValorSujerido
	--ValorTpv >= 5000 and ValorTpv < 10000
	--and ValorTpv >= 10000 and ValorSujerido > 0 
	--FaturamentoRecarga > 10000 and ValorSujerido > 0 
		 
   ORDER BY EntidadePontoCapturaId
   