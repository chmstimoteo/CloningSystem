#! /bin/bash

# Sistema de clonagem
# Versão 2.1
# FITec - Fundação para Inovações Tecnológicas
# Autor: Carlos Timoteo, Rodrigo Lira, Cristóvão Zuppardo Rufino
# Email: stimoteo@fitec.org.br, rlsilva@fitec.org.br
# Descrição: Faz a clonagem de uma imagem do repositório para um HD de destino

progresso() {
	clear
	#Informando o progresso da Clonagem
	SSTART=$(date +%s)
	MIN=0
	HOR=0
	TEMPO=0
	percent=0
	COUNT=0
	PARTES=`echo "100 / $qtdediscos" | bc -l`  
	PARTES=`echo $PARTES | awk -F "." '{print $1}'`
	(
	while [ 0 ]
	do	
		clonados=`cat clonados`
		sleep 1
		if [ $COUNT -le 100 ]; then
			COUNT=`echo "$PARTES * $clonados" | bc -l`         
			COUNT=`echo $COUNT | awk -F "." '{print $1}'`
		fi

		SEND=$(date +%s)
		SDIFF=$(( $SEND - $SSTART ))
		if [ $(($SDIFF%60)) -eq 0 ]; then
			[ $SDIFF -ne 0 ] && MIN=$(($MIN+1))
		fi

		if [ $(($MIN%60)) -eq 0 ]; then
			[ $MIN -ne 0 ] && HOR=$(($HOR+1))
		fi

		#FORMATAR HORA
		CHOR=$HOR		
		if [ `echo $CHOR | wc -m` -eq 2 ]; then CHOR="0$CHOR"; fi		
		
		CMIN=$(($MIN%60))
		if [ `echo $CMIN | wc -m` -eq 2 ]; then 
			CMIN="0$CMIN"
		fi
		
		CSDIFF=$(($SDIFF%60))		
		if [ `echo $CSDIFF | wc -m` -eq 2 ]; then 
			CSDIFF="0$CSDIFF"
		fi

		TEMPO="$CHOR:$CMIN:$CSDIFF"

#		TEMPO="$HOR:$(($MIN%60)):$(($SDIFF%60))"
#		clear
		echo $COUNT
		echo "XXX"
		echo "Progresso:\nImagem Selecionada: $imagem\nTipo de Sistema Operacional: $sistema\nDiscos Detectados: $qtdediscos\nDiscos Clonados: $clonados\nTempo Geral: $TEMPO"
		echo "XXX"

		[ $clonados -eq $qtdediscos ] && break
	done; 
	) | dialog --backtitle "Replicador N3" --title "Replicando Imagem" --gauge "Progresso:\nImagem Selecionada: $imagem \nTipo de Sistema Operacional: $sistema\nDiscos Detectados: $qtdediscos\nDiscos Clonados: $clonados\nTempo Geral: 00:00:00" 12 100 0
	
	rm clonados
	sleep 7
	#clear

}

imprime_relatorio() {
	echo
	echo
	echo
	while read l ; do
		disk=`echo "$l" | awk '{print $1}'`
		status=`echo "$l" | awk '{print $2}'`
		if [ $status -eq 1 ]; then
			echo -e "\e[32;1m$disk foi clonado com sucesso!\e[0m"
		else
			echo -e "\e[31;1mERRO CLONANDO $disk\e[0m"
		fi
	done < /home/n3/relatorio
}

clonar_hds() {
	echo "Detectando HD's..."
	discos=`ls /dev/sd* | egrep -v '[0-9]' | egrep -v 'a'`
#	discos="/dev/sdb /dev/sdc /dev/sdd /dev/sde"
	qtdediscos=`echo $discos | wc -w`
	for d in $discos ; do echo "Disco encontrado em $d" ; done
	echo
	echo "Clonando a imagem $imagem..."
	echo -n '' > /home/n3/relatorio
	clonados=0
	echo "$clonados" > clonados
	sleep 6
	sync

	progresso&

	for d in $discos ; do
		disco=`echo "$d" | sed -e 's/\// /g' | awk '{ print $2 }'`
		disk_status=1
		#ping 127.0.0.1 -c 10 > /dev/null # operação...
		ocs-sr -b -e1 auto -r -k1 -j2 -p command restoredisk $1 $disco >>logClone1.txt 2>>logClone2.txt
#		echo "RESULTADO: $?"
		if [ $? -eq 0 ] ; then
#			echo "$d foi clonado com sucesso!" #| tee -a /home/n3/relatorio
			disk_status=$(($disk_status * 1))
		else
#			echo "ERRO CLONANDO $d!" #| tee -a /home/n3/relatorio
			disk_status=$(($disk_status * 0))
		fi
		clonados=$(($clonados+1))
		echo "$clonados" > clonados
		sync
		echo "$d $disk_status" >> /home/n3/relatorio
	done
	cont=0
	while [  -f clonados ]; do sleep 1; cont=$(($cont + 1)); done
	clear
	imprime_relatorio
	echo
	echo
	echo "Processo concluído!"
	echo -n "Pressione [Enter] para desligar o computador"
	read nullInput
	chown -R n3:n3 /home/n3/*
	poweroff
}

#################################
############## MAIN #############
#################################

sizeLogClone1=`ls -l logClone1.txt | awk '{ print $5 }'`
[ $sizeLogClone1 -gt 104857600 ] && rm logClone1.txt

sizeLogClone2=`ls -l logClone2.txt | awk '{ print $5 }'`
[ $sizeLogClone2 -gt 104857600 ] && rm logClone2.txt


clear

# Procura pela última imagem utilizada
if [ ! -e /home/n3/ultima_imagem ]; then
	echo "Não foi escolhida uma imagem para clonar!"
	echo "Não pode continuar!"
	echo -n "Reiniciando computador em "
	for $i in 5 4 3 2 1 ; do echo "$i " ; sleep 1 ; done ; echo "Reiniciando!"
	touch /home/n3/ultima_imagem
	reboot
fi

#Verifica se alguma imagem foi salva
diretorioImagem=`cat /home/n3/ultima_imagem`
if [ -z $diretorioImagem ]; then
	echo "Não foi escolhida uma imagem para clonar!"
        echo "Não pode continuar!"
        echo -n "Reiniciando computador em "
        for $i in 5 4 3 2 1 ; do echo "$i " ; sleep 1 ; done ; echo "Reiniciando!"
       reboot
fi

#Valida o nome da imagem
if [ -d "/home/partimag/"$diretorioImagem ]; then
	sistema=`echo $diretorioImagem | awk -F "/" '{print $1}'`
	imagem=`echo $diretorioImagem | awk -F "/" '{print $2}'`
	clonar_hds $diretorioImagem
else
	echo "Imagem desconhecida!"
	echo "Não pode continuar!"
	echo -n "Reiniciando computador em "
	for i in 5 4 3 2 1 ; do echo "$i " ; sleep 1 ; done ; echo "Reiniciando!"
	reboot
fi
