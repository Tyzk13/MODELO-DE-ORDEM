# Meu Orçamento

Sistema simples para controlar o orçamento do mês. É um único arquivo (`index.html`): basta abrir no navegador, sem instalar nada.

## O que dá para fazer

- **Renda**: cadastre salário e rendas extras.
- **Contas fixas**: luz, água, aluguel, internet… com dia de vencimento e marcação de "paga". Elas são copiadas automaticamente para o mês seguinte.
- **Gastos do dia a dia**: lance cada gasto com categoria e data.
- **Limites**: defina um limite geral do mês e limites por categoria. As barras ficam amarelas a partir de 80% e vermelhas quando passa do limite. Ao lançar um gasto que estoura o limite, o sistema pede confirmação.
- **Meta de economia**: quanto você quer guardar no mês.
- **Resumo**: sobra do mês e quanto você ainda pode gastar por dia até o fim do mês.
- **Alertas**: limites perto de estourar, contas vencendo em até 3 dias ou atrasadas, saldo negativo.
- **Backup**: exporte/importe tudo em um arquivo `.json`.

Os dados ficam salvos no próprio navegador (localStorage). Se trocar de navegador ou limpar os dados do site, use o backup.
