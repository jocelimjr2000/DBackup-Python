#!/bin/bash


####################################
# CONFIGURAÇÕES

# Percentual Aceitavel (verificar até qual percentual será utilizado do hd)
percent="95"

# Compactação ( "" - Não compactar | "tar.gz" | "tar.xz" )
compactType="tar.gz"

# Pasta temporária (onde serão exportados os bancos antes da compactação)
folderTemporary="/BKPTMP"

# Arquivo de marcação (define o hd utilizado atualmente)
comp_hddMarkup="/mnt/home/user/hdd.txt"

# LISTA DE HDS (utilizados para armazenar os bancos compactados)
Hdds[0]="/mnt/hdd1"
Hdds[1]="/mnt/hdd2"
Hdds[2]="/mnt/hdd3"

# SERVIDORES (o [0] determina o número do servidor)
#Server[0]         - Nome do servidor
#ServerPrefix[0]   - Prefixo (utilizado no início dos arquivos compactados)
#ServerIP[0]       - IP para conexão
#ServerUser[0]     - Usuário com permissão
#ServerPass[0]     - Senha
#ServerDB[0]       - Bases à copiar dividias por ';' (ex "base1;base2;base3")

Server[0]="Banco de Dados 1"
ServerPrefix[0]="db1_"
ServerIP[0]="192.168.0.1" 
ServerUser[0]="root" 
ServerPass[0]="senha" 
ServerDB[0]="databaseA"

Server[1]="Banco de Dados 2"
ServerPrefix[1]="db2_"
ServerIP[1]="192.168.0.2" 
ServerUser[1]="root" 
ServerPass[1]="senha" 
ServerDB[1]="databaseB;databaseC"

#
####################################


####################################
# PARÂMETROS GERAIS

# Marca o inicio da execução
inicio=$(date +%s)

# Caminho completo do arquivo de log
comp_fileLog="$folderTemporary/$fileLog"

# Hora Atual
current_datetime=$(date +%d-%m-%Y_%H)

# Nome do arquivo de log que será criado
fileLog="Log_"$current_datetime".txt"

#
####################################


####################################
# DEFINIR FUNÇÕES

# Iniciar arquivo log
function func_ImprimirIni(){
	echo $(date +%D" "%T)"  -  "$* > $comp_fileLog
}

# Escrever dados em arquivo Log
function func_Imprimir(){
	echo $(date +%D" "%T)"  -  "$* >> $comp_fileLog
}

# Escrever em arquivo de marcação do HD
function func_MarkupFile(){
    # Log
	func_Imprimir "Alterar disco do arquivo de marcação (disco $*)"

	# Escrever em arquivo
	echo $* > $comp_hddMarkup
}

# Formatar disco
function func_FormatDisk () {
	# Log
	func_Imprimir "Formatando disco $*"

	# Apagar
	rm -rf $*/*

	# Log
	func_Imprimir "Formatação concluída"
}

# Verificar espaço em disco
function func_CheckSpace(){
	# Guardar Informações do disco em variáveis
	esp=($(df $* |awk 'NR==2 {print $2,$3,$4,$5}'|sed 's/%//'))
	
	# Percentual utilizado
	space_percent="${esp[3]}"
	
	# Espaço livre
	space_free="${esp[2]}"
	
	# Espaço utilizado
	space_occupied="${esp[1]}"
	
	# Espaço total
	space_total="${esp[0]}"
	
	# Condição para verificar se há espaço em disco
	if [[ $space_percent -gt $percent ]] 
	then
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
function func_ExportDB (){
	
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
	if [[ $? == 0 ]]
	then
		# Log
	    func_Imprimir "Base existe, iniciando exportação"
	
		# Exportar banco em pasta temporária
		/usr/bin/mysqldump -h $expIP -u $expUser -p$expPass --routines --triggers --single-transaction --quick $expDB > $folderTemporary/$expPrefix"_"$expDB"_"$current_datetime.sql
		
		# Condição para informar se ouve erro
		if [[ $? == 0 ]]
		then
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
function func_CompactDB (){
	# Verificar se compactação está desativada
	if [[ $compactType == "" ]]
	then
		# Log
		func_Imprimir "Compactação desativada"
	else
	    
		# Loop varrendo todos os arquivos gerados desta com a mesma hora
		for fileExp in `ls $folderTemporary/*"_"$current_datetime.sql`
		do
		    
		    # Condição para verificar tipo de compactação é válida
		    if [[ $compactType == "tar.xz" ]] || [[ $compactType == "tar.gz" ]]
		    then
    		    
    		    # Log
		        func_Imprimir "Iniciando compactação de $fileExp ($compactType)"
    		    
				# Compactar de acordo com o formato desejado
    		    if [[ $compactType == "tar.xz" ]]
    			then
    				tar Jcf ${fileExp//sql/$compactType} $fileExp
    			
    			elif [[ $compactType == "tar.gz" ]]
    			then
    				tar -czvf ${fileExp//sql/$compactType} $fileExp
    			
    			fi
    			
    		    # Condição informar se ouve erro
    			if [[ $? == 0 ]]
    			then
    				# Log
    				func_Imprimir "Base compactada com sucesso"
    			else
    				# Log 
    				func_Imprimir "Atenção! Erro ao compactar"
    			fi
		
	    	else
			    # Log
	            func_Imprimir "Tipo de compactação inválida"
			fi
		done
	fi
}

# Deletar DB
function func_DeleteDB (){
    # Log
    func_Imprimir "Apagando bases de dados exportadas"
    rm $folderTemporary/*"_"$current_datetime.sql
   
    # Condição informar se ouve erro
	if [[ $? == 0 ]]
	then
		# Log
		func_Imprimir "Bases deletadas com sucesso"
	else
		# Log 
		func_Imprimir "Atenção! Erro ao deletar bases"
	fi
}

# Mover DB
function func_MoveDB () {
    # Log
    func_Imprimir "Mover arquivos compactados"
    
	# Novo logfile
    comp_fileLog="$diskSelect/$current_datetime/$fileLog"
    
	#Criar pasta
    mkdir --parents $diskSelect/$current_datetime;
    
	#Mover
    mv $folderTemporary/*$current_datetime*.* $diskSelect/$current_datetime
    
    #Condição informar se ouve erro
	if [[ $? == 0 ]]
	then
		# Log
		func_Imprimir "Arquivos compactados movidos com sucesso"
	else
		# Log 
		func_Imprimir "Atenção! Erro ao mover arquivos compactados"
	fi
}
#
####################################


####################################
# DEFINIR HD DE DESTINO

# Log
func_ImprimirIni "Verificar se arquivo de marcação existe ($comp_hddMarkup)"

# Verificar se Arquivo de marcação existe
if [[ ${#Hdds[@]} > 1 ]] && [[ -e "$comp_hddMarkup" ]];
then

	# Se existir, ler arquivo e selecionar disco escrito no arquivo
	while read line; do
	    # Selecionar disco
		diskSelect=$line
		
		# Log
		func_Imprimir "Selecionado disco do arquivo de marcação para verificar espaço disponível"
	done < $comp_hddMarkup
	
	# Verificar espaço em disco
	func_CheckSpace $diskSelect
	
	# ----- DISCO CHEIO
	# Se retorno for '0', o disco está cheio, selecionar o próximo
	if [ $retorno == 0 ]
	then
	    # Log
		func_Imprimir "Verificar próximo disco"
	    
	    # Loop - varrer hdds (descobrir posição do hdd atual)
        for ((hddCount=0; hddCount<${#Hdds[@]}; hddCount++))
        do
            if [ ${Hdds[$hddCount]} == $diskSelect ]
            then
                break
            fi
        done
        
        # Selecionar novo disco
        if [ $hddCount == $(( ${#Hdds[@]} -1)) ]
        then
            diskSelect=${Hdds[0]}
        else
            diskSelect=${Hdds[$hddCount+1]}
        fi
        
        # Alterar arquivo de marcação
		func_MarkupFile $diskSelect
		
        # Log
		func_Imprimir "Iniciando formatação"
		
		# Formatar disco
		func_FormatDisk $diskSelect
		
	fi
	# ----- /DISCO CHEIO
	
else
	# Se arquivo não existir, cria setando o primeiro hd
    diskSelect=${Hdds[0]}
fi
#
####################################


####################################
# EXECUTAR BACKUP

# Loop - Varrer servidores
for ((i=0; i<${#Server[@]}; i++))
do

	# Dividir String (ServerDB)
    bases=$(echo ${ServerDB[$i]} | tr ";" "\n")
	
    # Loop Bases
    for base in $bases
    do
        func_ExportDB "${Server[$i]}" "${ServerPrefix[$i]}" "${ServerIP[$i]}" "${ServerUser[$i]}" "${ServerPass[$i]}" "$base"
    done

done

# Compactar
func_CompactDB

# Deletar
func_DeleteDB

# Mover para destino
func_MoveDB
####################################

# Tempo gasto na execução do script
tempogasto=$(($(date +%s) - $inicio))

# Converter tempo total de execução
MIN=$(($tempogasto/60))
SEC=$(($tempogasto-$MIN*60))
HOR=$(($MIN/60))
MIN=$(($MIN-$HOR*60))
tempoTotal=$HOR"h "$MIN"m "$SEC"s "

# Log
func_Imprimir "Backup concluído. Tempo gasto desse script foi de: $tempoTotal !"
