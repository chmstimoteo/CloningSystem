#!/bin/bash

# Sistema de clonagem
# Versão 2.1
# FITec - Fundação para Inovações Tecnológicas
# Autor: Carlos Timóteo, Rodrigo Lira, Cristóvão Zuppardo Rufino
# Email: stimoteo@fitec.org.br, rlsilva@fitec.org.br
# Descrição: Software que cria uma imagem a partir do disco em /dev/sdb

escolher_imagem() {
	#Selecionando o tipo de Sistema Operacional
	sleep 1
	j=1
	SOS=""
	TITULOS=""
	list=`ls -l "/home/partimag/" | egrep "^d" | awk '{print $9}'` #Colocar para 9
	#list=`ls -l "/home/partimag/" | egrep "^d" | awk '{print $8}'` #Colocar para 9
	if [ -z $list ]; then dialog --backtitle "Replicador N3" --title "Tipo de Sistema Operacional" --infobox "Não há imagens salvas." 3 30; sleep 2; escolher_imagem; fi

	for tipo in $list; do 
		SOS="$SOS $j $tipo"
		TITULOS="$TITULOS $tipo"
		j=$(($j+1))
	done

	cmdo=(dialog --backtitle "Replicador N3" --title "Tipo de Sistema Operacional" 
		    --menu "Escolha uma opção:" 0 70 0)
	options=($SOS)
	posicao=$("${cmdo[@]}" "${options[@]}" 2>&1 >/dev/tty)

	if [ -z $posicao ]; then 
		escolher_imagem
	else
		j=1
		for token in $TITULOS; do
			if [ $j -eq $posicao ]; then 
				FOLDER=$token
			break
			fi
			j=$(($j+1))
		done 
	fi

#	tipo=$(dialog --backtitle "Replicador N3" --title "Tipo de Sistema Operacional" \
#		      --menu "Escolha uma opção" 0 0 0 "windows" "Sistema Operacional Windows" \
#		      "linux" "Sistema Operacional Linux" "dual-boot" "Sistema Operacional Windows/Linux" \
#		      "outro" "Outro tipo de Sistema Operacional" 3>&1 1>&2 2>&3)
#
#	if [ $tipo = "linux" ]; then
#		FOLDER=$Linux
#	elif [ $tipo = "windows" ]; then
#		FOLDER=$Windows
#	elif [ $tipo = "dual-boot" ]; then
#		FOLDER=$Dualboot
#	elif [ $tipo = "outro" ]; then
#	 	FOLDER=$Outros
#	else
#		escolher_imagem
#	fi

	#Selecionando o nome da imagem
	i=1
	IMGS=""
	NOMES=""
	LIST=`ls -l "/home/partimag/"$FOLDER | egrep "^d" | awk '{print $9}'` #Colocar para 9
	#LIST=`ls -l "/home/partimag/"$FOLDER | egrep "^d" | awk '{print $8}'` #Colocar para 9
	if [ -z $LIST ]; then dialog --backtitle "Replicador N3" --title "Nome das Imagens" --infobox "Não há imagens desse tipo." 3 30; sleep 2; escolher_imagem; fi

	for sistema in $LIST; do 
		IMGS="$IMGS $i $sistema"
		NOMES="$NOMES $sistema"
		i=$(($i+1))
	done

	cmd=(dialog --backtitle "Replicador N3" --title "Nome das Imagens" 
		    --menu "Escolha uma das imagens a ser restaurada:" 0 70 0)
	options=($IMGS)
	POSICAO=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	if [ -z $POSICAO ]; then 
		escolher_imagem
	else
		i=1
		for token in $NOMES; do
			if [ $i -eq $POSICAO ]; then 
				NOME=$token
			break
			fi
			i=$(($i+1))
		done 
	fi
}

###########################
######## MAIN #############
###########################

Windows=windows
Linux=linux
Outros=outros
Dualboot=dualboot

#clear

escolher_imagem


clear

echo -e "\n\n\tIMAGEM SELECIONADA: \033[32m$NOME\n\n"
echo -e "\033[0m"
echo "$FOLDER"/"$NOME" > /home/n3/ultima_imagem
echo "Para cancelar a clonagem aperte o botão de 'Desligar' ou 'Reiniciar' do computador"
echo -n "Iniciando o processo de clonagem em "
for i in 5 4 3 2 1 ; do echo -n "$i " ; sleep 1 ; done

exec /opt/clonador/clone.sh

