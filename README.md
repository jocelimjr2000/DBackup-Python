# DBackup v 1.1

<p>
  Script simples desenvolvido para automatizar backup de bancos de dados MySQL e MariaDB em servidores Linux.
</p>
<p>
  ATENÇÃO! UTILIZE DISCOS DEDICADOS AO ARMAZENAMENTO DESTES BACKUPS, POIS O SCRIPT SEMPRE APAGARÁ-LOS PARA LIBERAR ESPAÇO QUANDO NECESSÁRIO.
</p>
<p>
  Passos de execução:
  <br>
  <b>1 - Verifica os HDs listados:</b> Este processo seleciona o primeiro hd da lista. Caso tenha selecionado anteriormente, ele verifica se há espaço disponível, se não, seleciona e formata o próximo disco da lista. No último disco, o primeiro será selecionado.
  <br>
  Ex.: 
  <br>
  Se configurado 3 discos, automaticamente é selecionado o primeiro. 
  <br>
  Quando o espaço disponível dele acabar, o segundo será selecionado. 
  <br>
  Quando o do segundo acabar, o último será selecionado. 
  <br>
  Quando o deste acabar, o primeiro será selecionado.
  <br>
  <b>2 - Exporta as bases selecionadas:</b> Exporta com triggers e procedures.
  <br>
  <b>3 - Compacta:</b> De acordo com o configurado.
  <br>
  <b>4 - Move para o disco definido</b>
  <br>
  <b>5 - Gera arquivo 'Log.txt'</b>
</p>
<p>
  Plataforma utilizada para o desenvolvimento: Linux Debian 10
</p>

# Configuração
<p>
  <b>percent: </b> Percentual aceitavel, utilizado para verificar até qual percentual será utilizado do hd.
</p>
<p>
  <b>compactType: </b> Tipo de compactação do arquivo.
</p>
<p>
  Opções:
  <br>
  compactType="" - Não compactar
  <br>
  compactType="tar.gz" - Compactar em tag.gz (mais rápido)
  <br>
  compactType="tar.xz" - Compactar em tag.xz (mais lento, porém compacta mais)
</p>
<p>
  <b>sepFiles: </b> Separar tabelas
</p>
<p>
  Opções:
  <br>
  sepFiles=0 - Salva em 1 arquivo.sql
  <br>
  sepFiles=1 - Salva a estrutura principal (procedures, triggers, tabelas sem dados, etc.) e salva as tabelas com dados separadamente
</p>
<p>
  <b>baseTmpFolder: </b> Pasta temporária, onde serão exportados os bancos antes da compactação.
</p>
<p>
  <b>comp_hddMarkup: </b> Arquivo de marcação, onde será salvo o HD atual.
</p>
<p>
  <b>Hdds[0]: </b> Lista de HDs onde serão armazenados os arquivos exportados.
</p>
<p>Ex.: </p>
<p>
  Hdds[0]="/mmt/hdd1"
  <br>
  Hdds[1]="/mmt/hdd2"
</p>
<p>
  <b>circular: </b> Habilita(1) ou desabilita(0) o modo circular. Esta função faz com que selecione e formate o próximo disco sempre o percentual de uso do disco atual for igual ao configurado na opção "percent".
</p>
<p>Ex.: </p>
<p>
  Se configurado 3 discos e limitado a 90% de uso, quando o primeiro disco chegar a este percentual de uso, o segundo será selecionado e formatado. Quando ocorrer o mesmo este, o terceiro será utilizado e no último disco, será selecionado o primeiro.
</p>
<p>
  Lista de servidores
</p>
<p>
  <b>Server[0]: </b> Nome do servidor
  <br>
  <b>ServerPrefix[0]: </b> Prefixo (utilizado no início dos arquivos compactados)
  <br>
  <b>ServerIP[0]: </b> IP para conexão
  <br>
  <b>ServerUser[0]: </b> Usuário com permissão
  <br>
  <b>ServerPass[0]: </b> Senha
  <br>
  <b>ServerDB[0]: </b> Bases à copiar dividias por ';' (ex "base1;base2;base3")
</p>
<p>
  Para inclusão de múltiplos servidores, repita os parâmetros alterando o número dentro deles
</p>
<p>
  Server[0]
  <br>
  ...
  <br>
  Server[1]
  <br>
  ...
  <br>
</p>

# Instalação

Após a configuração, execute manualmente ou agende no cron.

# Erros
<p>
  Este é um projeto simples porém me auxiliou muito. Caso encontre erros ou tenha sugestões de melhoria, ficarei muito grato. 
  <br>
  <br>
  :)
</p>
