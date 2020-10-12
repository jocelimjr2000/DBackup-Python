#!/bin/bash

#####################################################
#                 DBackup v1.1                  	#
#                                               	#
# Bancos: 	MySQL e MariaDB                     	#
# Autor: 	Jocelim Rodrigues Abdala Junior     	#
# E-mail:	jocelimjr2000@hotmail.com           	#
# GitHub: https://github.com/jocelimjr2000/DBackup	#
#####################################################

##### CONFIGURAÇÕES

# Percentual Aceitavel (verificar até qual percentual será utilizado do hd)
percent="95"

# Compactação ( "" - Não compactar | "tar.gz" | "tar.xz" )
compactType="tar.xz"

# Separar arquivos (cria um sql com a estrutura das tabelas, procedures, etc., e salva as tabelas com os dados separadas)
sepFiles=1

# Pasta temporária base (onde serão exportados os bancos antes da compactação)
baseTmpFolder="/mnt/DBackup/tmp"

# Arquivo de marcação (define o hd utilizado atualmente)
comp_hddMarkup="/mnt/DBackup/hdd.txt"

# LISTA DE HDS (utilizados para armazenar os bancos compactados)
Hdds[0]="/mnt/DBackup/bkp"

# Modo circular (irá formatar o próximo hd para iniciar a gravação)
circular=0

# Servidores
Server[0]="Banco de Dados 1"
ServerPrefix[0]="db1"
ServerIP[0]="localhost"
ServerUser[0]="root"
ServerPass[0]="password"
ServerDB[0]="mydatabase"

##### PARÂMETROS GERAIS

# Marca o inicio da execução
inicio=$(date +%s)

# Hora Atual
current_datetime=$(date +%d-%m-%Y_%H)

# Nome do arquivo de log que será criado
logFile="Logs.txt"

# Pasta temporária por hora
tmpFolder="$baseTmpFolder/$current_datetime"

# Caminho completo do arquivo de log
comp_logFile="$tmpFolder/$logFile"

##### DEFINIR FUNÇÕES

# Iniciar arquivo log
function func_ImprimirIni() {
	echo $(date +%D" "%T)"  -  "$* >$comp_logFile
}

# Escrever dados em arquivo Log
function func_Imprimir() {
	echo $(date +%D" "%T)"  -  "$* >>$comp_logFile
}

# Escrever em arquivo de marcação do HD
function func_MarkupFile() {
	# Log
	func_Imprimir "Alterar disco do arquivo de marcação (disco $*)"

	# Escrever em arquivo
	echo $* >$comp_hddMarkup
}

# Formatar disco
function func_FormatDisk() {
	# Log
	func_Imprimir "Formatando disco $*"

	# Apagar
	rm -rf $*/*

	# Log
	func_Imprimir "Formatação concluída"
}

# Verificar espaço em disco
function func_CheckSpace() {
	# Guardar Informações do disco em variáveis
	esp=($(df $* | awk 'NR==2 {print $2,$3,$4,$5}' | sed 's/%//'))

	# Percentual utilizado
	space_percent="${esp[3]}"

	# Espaço livre
	space_free="${esp[2]}"

	# Espaço utilizado
	space_occupied="${esp[1]}"

	# Espaço total
	space_total="${esp[0]}"

	# Condição para verificar se há espaço em disco
	if [[ $space_percent -gt $percent ]]; then
		# Log
		func_Imprimir "> Status: Error | Message: Disco cheio | Volume: "$*" | Espaço Total: "$space_total" | Espaço Livre: "$space_free" | Espaço Ocupado: "$space_occupied" | Percentual Ocupado: "$space_percent" |"

		# Variável para retorno, identificando se ocorreu erro ou não
		retorno=0
	else
		# Log
		func_Imprimir "> Status: Ok | Message: Disco selecionado | Volume: "$*" | Espaço Total: "$space_total" | Espaço Livre: "$space_free" | Espaço Ocupado: "$space_occupied" | Percentual Ocupado: "$space_percent" |"

		# Variável para retorno, identificando se ocorreu erro ou não
		retorno=1
	fi

	#Retornar resultado do identificador
	return $retorno
}

# Exportar DB
function func_ExportDB() {

	# Parâmetros do servidor selecionado
	expServer=$1
	expPrefix=$2
	expIP=$3
	expUser=$4
	expPass=$5
	expDB=$6

	# Log
	func_Imprimir "Verificando se base de dados ($expDB) existe em servidor ($expServer)"

	# Verificar se a banco de dados existe
	mysql -h $expIP -u $expUser -p$expPass -e "USE $expDB"

	# Condição para exportar banco caso exista
	if [[ $? == 0 ]]; then
		# Log
		func_Imprimir "Base existe, iniciando exportação"

		ref=$expPrefix"_"$expDB

		# Condição para exportar o banco em 1 arquivo sql ou em tabelas separadas
		if [[ $sepFiles == 0 ]]; then
			# Exportar banco em pasta temporária
			/usr/bin/mysqldump -h $expIP -u $expUser -p$expPass --routines --triggers --single-transaction --quick $expDB >$tmpFolder/$ref.sql

		else

			# Pasta das tabelas
			refFolder="$tmpFolder/$ref"
			tablesFolder="$refFolder/tables"

			# Verificar se pasta temporárias existe
			if [[ -d $tablesFolder ]]; then
				# Log
				func_ImprimirIni "Pasta temporária de tables existente"
			else
				mkdir --parents $tablesFolder
				chmod -R 0777 $tablesFolder
				# Log
				func_ImprimirIni "Criado pasta temporária de tabelas criada "$tablesFolder
			fi

			# Exportar estrutura do banco em pasta temporária
			/usr/bin/mysqldump -h $expIP -u $expUser -p$expPass --routines --triggers --single-transaction --quick --no-data $expDB >$refFolder/$ref.sql

			for T in $(mysql -h $expIP -u $expUser -p$expPass -N -B -e 'show tables from '$expDB); do
				mysqldump --skip-comments --compact -h $expIP -u $expUser -p$expPass $expDB $T >$tablesFolder/$T.sql
			done

		fi

		# Condição para informar se ouve erro
		if [[ $? == 0 ]]; then
			# Log
			func_Imprimir "Base exportada com sucesso"
		else
			# Log
			func_Imprimir "Atenção! Erro ao exportar"
		fi

	else
		# Log
		func_Imprimir "Atenção! Base não existe"
	fi
}

# Compactar Banco
function func_CompactDB() {
	# Verificar se compactação está desativada
	if [[ $compactType == "" ]]; then
		# Log
		func_Imprimir "Compactação desativada"
	else

		# Loop varrendo todos os arquivos gerados desta com a mesma hora
		for fileExp in $(ls $tmpFolder --ignore $logFile); do

			# Condição para verificar tipo de compactação é válida
			if [[ $compactType == "tar.xz" ]] || [[ $compactType == "tar.gz" ]]; then

				# Log
				func_Imprimir "Iniciando compactação de $fileExp ($compactType)"

				# Compactar de acordo com o formato desejado
				if [[ $compactType == "tar.xz" ]]; then
					tar JcfP "$tmpFolder/$fileExp.$compactType" "$tmpFolder/$fileExp"

				elif [[ $compactType == "tar.gz" ]]; then
					tar fczP "$tmpFolder/$fileExp.$compactType" "$tmpFolder/$fileExp"
				fi

				# Condição informar se ouve erro
				if [[ $? == 0 ]]; then
					# Log
					func_Imprimir "Base compactada com sucesso"

					func_DeleteDB "$tmpFolder/$fileExp"
				else
					# Log
					func_Imprimir "Atenção! Erro ao compactar"

					func_DeleteDB "$tmpFolder/$fileExp.$compactType"
				fi

			else
				# Log
				func_Imprimir "Tipo de compactação inválida"
			fi

		done

	fi
}

# Deletar DB
function func_DeleteDB() {
	# Log
	func_Imprimir "Apagando arquivo: "$1
	rm -Rf $1

	# Condição informar se ouve erro
	if [[ $? == 0 ]]; then
		# Log
		func_Imprimir "Arquivo apagado com sucesso"
	else
		# Log
		func_Imprimir "Atenção! Erro ao apagar arquivo"
	fi
}

# Mover DB
function func_MoveDB() {
	# Log
	func_Imprimir "Mover arquivos compactados"

	# Criar pasta
	mkdir --parents $diskSelect

	# Mover
	mv $tmpFolder $diskSelect/

	# Novo logfile
	comp_logFile="$diskSelect/$current_datetime/$logFile"

	# Condição informar se ouve erro
	if [[ $? == 0 ]]; then
		# Log
		func_Imprimir "Arquivos compactados movidos com sucesso"
	else
		# Log
		func_Imprimir "Atenção! Erro ao mover arquivos compactados"
	fi
}

##### VERIFICAR PASTA TEMPORARIS

# Verificar se pasta temporárias existe
if [[ -d $tmpFolder ]]; then
	# Log
	func_ImprimirIni "Pasta temporária existente"
else
	mkdir --parents $tmpFolder
	chmod -R 0777 $tmpFolder
	# Log
	func_ImprimirIni "Criado pasta temporária "$tmpFolder
fi

##### DEFINIR HD DE DESTINO

if [[ $circular == 1 ]]; then
	# Log
	func_Imprimir "Verificar se arquivo de marcação existe ($comp_hddMarkup)"
fi

# Verificar se Arquivo de marcação existe
if [[ $circular == 1 ]] && [[ ${#Hdds[@]} > 1 ]] && [[ -e "$comp_hddMarkup" ]]; then

	# Se existir, ler arquivo e selecionar disco escrito no arquivo
	while read line; do
		# Selecionar disco
		diskSelect=$line

		# Log
		func_Imprimir "Selecionado disco do arquivo de marcação para verificar espaço disponível"
	done <$comp_hddMarkup

	# Verificar espaço em disco
	func_CheckSpace $diskSelect

	# Se retorno for '0', o disco está cheio, selecionar o próximo
	if [ $retorno == 0 ]; then
		# Log
		func_Imprimir "Verificar próximo disco"

		# Loop - varrer hdds (descobrir posição do hdd atual)
		for ((hddCount = 0; hddCount < ${#Hdds[@]}; hddCount++)); do
			if [ ${Hdds[$hddCount]} == $diskSelect ]; then
				break
			fi
		done

		# Selecionar novo disco
		if [ $hddCount == $((${#Hdds[@]} - 1)) ]; then
			diskSelect=${Hdds[0]}
		else
			diskSelect=${Hdds[$hddCount + 1]}
		fi

		# Alterar arquivo de marcação
		func_MarkupFile $diskSelect

		# Log
		func_Imprimir "Iniciando formatação"

		# Formatar disco
		func_FormatDisk $diskSelect

	fi

else
	# Se arquivo não existir, cria setando o primeiro hd
	diskSelect=${Hdds[0]}
fi

##### EXECUTAR BACKUP

# Loop - Varrer servidores
for ((i = 0; i < ${#Server[@]}; i++)); do

	# Dividir String (ServerDB)
	bases=$(echo ${ServerDB[$i]} | tr ";" "\n")

	# Loop Bases
	for base in $bases; do
		func_ExportDB "${Server[$i]}" "${ServerPrefix[$i]}" "${ServerIP[$i]}" "${ServerUser[$i]}" "${ServerPass[$i]}" "$base"
	done

done

# Compactar
func_CompactDB

# Mover para destino
func_MoveDB

##### FIM

# Tempo gasto na execução do script
tempogasto=$(($(date +%s) - $inicio))

# Converter tempo total de execução
MIN=$(($tempogasto / 60))
SEC=$(($tempogasto - $MIN * 60))
HOR=$(($MIN / 60))
MIN=$(($MIN - $HOR * 60))
tempoTotal=$HOR"h "$MIN"m "$SEC"s "

# Log
func_Imprimir "Backup concluído. Tempo gasto desse script foi de: $tempoTotal !"
