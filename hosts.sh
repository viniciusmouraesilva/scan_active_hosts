#!/usr/bin/env bash
#
# Extrai usuários do arquivo passwd + Script com opção para encontrar hosts ativos através do ping em uma rede /24 hosts.sh
#
# Autor: Vinicius Moura
# Manutenção: Vinicius Moura
#
# ------------------------------------------------------------------------ #
#
#
#  Exemplos:
#   $ ./hosts.sh -s -m
#   Neste exemplo ficara em maiusculo e ordem alfabetica
#
#   $ ./hosts.sh -c
#   Neste exemplo você obterá os hosts ativos na rede através de ping
#   O arquivo targets.txt será gerado com os HOSTS ativos via ping
#
#
# ------------------------------------------------------------------------ #
# Histórico:
#
#   v1.4 14/01/2022, Vinicius:
#
# ------------------------------------------------------------------------ #
# Testado em:
#   Debian 11.2.0
#   Centos 7.9.2009
# ------------------------------------------------------------------------ #
# Agradecimentos:
# ------------------------------------------------------------------------ #

# ------------------------------- VARIÁVEIS --------------------------
USUARIOS="$(cat /etc/passwd | cut -d : -f 1)"
IP_HOST="$(hostname -I | cut -d " " -f1)" #Qual é o IP do host?
MENSAGEM_USO="
  $0 - [OPÇÕES]
  -h - Menu de ajuda
  -v - Versão
  -s - Ordenar a saída
  -c - Hosts Ativos em uma rede /24
"
VERSAO="v1.4"
CHAVE_ORDENA=0
CHAVE_MAIUSCULA=0
HOSTS_ATIVOS=0 #Você precisa saber os hosts ativos?
INICIO=1 #Primeiro host.
FIM=254 #Ultimo host.
VERDE="\033[32m"
# ------------------------------- EXECUÇÃO --------------------------

#Case linux

while test -n "$1"
do
	case "$1" in
		-h) echo "$MENSAGEM_USO" && exit 0 			          ;;
		-v) echo "$VERSAO" && exit 0	   				  ;;
		-s) CHAVE_ORDENA=1	 	   				  ;;
		-m) CHAVE_MAIUSCULA=1						  ;;
		-c) HOSTS_ATIVOS=1 		   				  ;;
	 	*) echo " -- Opção inválida. Utilize -h para ajuda --" && exit 1  ;;
	esac
	shift
done

[ $CHAVE_ORDENA -eq 1 ] && USUARIOS=$(echo "$USUARIOS" | sort)  		#echo "$USUARIOS" | sort
[ $CHAVE_MAIUSCULA -eq 1 ] && USUARIOS=$(echo "$USUARIOS" | tr [a-z] [A-Z])	#echo "$USUARIOS" | tr [a-z] [A-Z]


if [ $HOSTS_ATIVOS -eq 1 ]; then #Opção -c Ativada?
	echo>pingnetwork
	echo>targets
	for octet in $(seq $INICIO $FIM ); do #De 1 até 254
    		#Pacote ping com quebra do último octeto concatenando o iterador do Loop para varrer a rede
    		ping -c1 "${IP_HOST%.*}.$octet" -W 1 >> pingnetwork;
	done;
	cat pingnetwork | grep "bytes from" | cut -d " " -f4 | cut -d ":" -f1 >> targets
	TARGETS="$(cat targets)" 
	echo -e "${VERDE} $TARGETS" #mostra hosts ativos
  	exit 0
fi

echo -e "${VERMELHO} $USUARIOS"
