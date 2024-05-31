/*
* Para cálculo de TPV/MDR foi utilizada a tabela [Adquirencia.masters.BaseProcessada]
* Para cálculo de RAV foi utilizada a tabela [mining.dbo.AntecipacaoSubAdquirencia]
*/

SELECT ISNULL(SUM(ValorReceitaAntecipacao),0) as RAV
FROM mining.dbo.AntecipacaoSubAdquirencia
where DataLiquidacaoRealizada between '2024-01-01' and '2024-01-31'
and CodigoClienteRedeFlex = '840767'

SELECT ISNULL(SUM(ValorMdrRedeflex) - SUM(ValorPagarCliente),0) as MDR
From Adquirencia.masters.BaseProcessada
where DataProcessamento between '2024-01-01' and '2024-01-30'
and CodigoClienteRedeFlex = '840767'

SELECT *
From Adquirencia.masters.BaseProcessada
where DataProcessamento > '2023-11-01'
order by DataProcessamento asc
   
SELECT * FROM Injecoes_012024    