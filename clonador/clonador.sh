#! /bin/bash

# Sistema de clonagem
# Versão 2.0
# FITec - Fundação para Inovações Tecnológicas
# Autor: Carlos Timóteo, Rodrigo Lira, Cristóvão Zuppardo Rufino
# Email: stimoteo@fitec.org.br, rlsilva@fitec.org.br
# Descrição: Programa para tratar as informações que vem do KERNEL

if [ $UID != 0 ]; then
        echo "Execute como root!"
        echo "e.g.: sudo $0"
        exit 1
fi

# Cria o arquivo que contém a última imagem utilizada
if [ ! -e /home/n3/ultima_imagem ]; then touch /home/n3/ultima_imagem; fi

for c in `cat /proc/cmdline` ; do
	case $c in
		"CLONE")
			echo "Opção 'CLONE' passada!" > /opt/opcao_atual
			#exec /opt/clonador/clone.sh
			chvt 1 && openvt -c 1 -f /opt/clonador/clone.sh
			;;
		"CHOOSE_IMAGE")
			echo "Opção 'CHOOSE_IMAGE' passada!" > /opt/opcao_atual
			#exec /opt/clonador/choose_image.sh
			chvt 1 && openvt -c 1 -f /opt/clonador/choose_image.sh
			;;
		"CREATE_IMAGE")
			echo "Opção 'CREATE_IMAGE' passada!" > /opt/opcao_atual
			#exec /opt/clonador/create_image.sh
			chvt 1 && openvt -c 1 -f /opt/clonador/create_image.sh
			;;
		"LOAD_GUI")
			echo "Opção 'LOAD_GUI' passada!" > /opt/opcao_atual
			echo "Iniciando GUI..."
			;;
		"POWEROFF")
			poweroff
			;;
		*)
			;;
	esac
done

