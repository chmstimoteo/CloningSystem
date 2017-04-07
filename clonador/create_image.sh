#!/bin/bash

# Sistema de clonagem
# Versão 2.0
# FITec - Fundação para Inovações Tecnológicas
# Autor: Carlos Timóteo, Rodrigo Lira, Cristóvão Zuppardo Rufino
# Email: stimoteo@fitec.org.br, rlsilva@fitec.org.br
# Descrição: Cria uma imagem e guarda no repositório de imagens

criar_imagem(){
	
	#Selecionando o tipo de Sistema Operacional
#	tipo=$(dialog --backtitle "Replicador N3" --title "Tipo de Sistema Operacional" \
#		      --menu "Escolha uma opção" 0 0 0 "windows" "Sistema Operacional Windows" \
#		      "linux" "Sistema Operacional Linux" "dual-boot" "Sistema Operacional Windows/Linux" \
#		      "outro" "Outro tipo de Sistema Operacional" 3>&1 1>&2 2>&3)

#	if [ $tipo = "linux" ]; then
#		FOLDER=$Linux
#	elif [ $tipo = "windows" ]; then
#		FOLDER=$Windows
#	elif [ $tipo = "dual-boot" ]; then
#		FOLDER=$Dualboot
#	elif [ $tipo = "outro" ]; then
#	 	FOLDER=$Outros
#	else
#		criar_imagem
#	fi
	sleep 1

	FOLDER=$(dialog --backtitle "Replicador N3" --title "Tipo do Sistema Operacional" --inputbox "Digite o Tipo do Sistema Operacional" 0 50 3>&1 1>&2 2>&3)


	if [ -z $FOLDER ] ; then clear ; criar_imagem; fi
	echo "$FOLDER" | egrep ' ' &> /dev/null
	if [ $? -eq 0 ]; then clear ; criar_imagem; fi

	#FOLDER=`echo $FOLDER | tr "A-Z" "a-z"`
	#[ ! -d $FOLDER ] && mkdir $FOLDER

	#Selecionando o Nome da Imagem
	nome=$(dialog --backtitle "Replicador N3" --title "Nome da Imagem" --inputbox "Digite o nome da Imagem" 0 50 3>&1 		1>&2 2>&3)

	if [ -z $nome ] ; then clear ; criar_imagem; fi
	echo "$nome" | egrep ' ' &> /dev/null
	if [ $? -eq 0 ]; then clear ; criar_imagem; fi
	nome=$FOLDER"/"$nome

	clear
	echo "Iniciando cópia. Esse processo pode demorar um pouco"

	ocs-sr -b -q2 -sc -j2 -z1p -p command savedisk $nome sdb 2>&1 | tee -a logCreate.txt

	echo "Processo concluído!"
	echo "$nome" > /home/n3/ultima_imagem	# Memoriza a última imagem utilizada
	echo -n "Desligando em " ; for i in 5 4 3 2 1; do echo -n "$i " ; sleep 1; done
	poweroff
}

#######################
###### MAIN ###########
####################### 


#Windows=/home/partimag/windows
#Linux=/home/partimag/linux
#Outros=/home/partimag/outros
#Dualboot=/home/partimag/dualboot
Windows=windows
Linux=linux
Outros=outros
Dualboot=dualboot

sizeLog=`ls -l logCreate.txt | awk '{ print $5 }'`
[ $sizeLog -gt 104857600 ] && rm logCreate.txt

clear

# Detecta se existe um disco em /dev/sdb onde estará o HD de origem de onde será criada a imagem
# para guardar no repositório
# WARNING! Apenas um disco é usado como fonte para se criar a imagem

if [ ! -e /dev/sdb ]; then
	echo -e "\n\n\t\033[31m"
	echo "Não foi encontrado disco para usar como origem!"
	echo "Não pode continuar!"
	echo -e "\033[0m"
	echo -n "O computador irá desligar em "
	for i in 5 4 3 2 1; do echo -n "$i "; sleep 1; done
	echo -n "Desligando!"
	poweroff
fi

#Ou parted
sfdisk -l /dev/sdb | egrep -i "ntfs|swap|ext2|ext3|ext4|FAT|FAT32|reiserfs|HFS|jfs|ufs|xfs" #&> /dev/null(parted)

if  [ $? -eq 0 ]; then
	criar_imagem
else
	echo -e "\n\n\t\033[31m Tipo de partição não detectada!"
	echo "Não pode continuar!"
	echo -e "\033[0m"
	echo -n "O computador irá desligar em "
	for i in 5 4 3 2 1 ; do echo -n "$i " ; sleep 1; done
	echo -n "Desligando!"
	poweroff
fi

exit 0
