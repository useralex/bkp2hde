#!/bin/bash
# programa      : bkp2hde.sh
# objetivo      : backup de volumes do hd para dispositivo externo
# autor         : lp (Luís Pessoa)
# versão        : 0.2.0b
# criação       : 16/07/2016
# dependências  : rsync e zenity
# manutenção    :
#     lp; 21/12/2016; escolha dos volumes a serem backpeados pelo zenity

###############
# functions
###############

###########
# function    : lu_echo
# description : echo improved with more information 
# usage       : lu_echo $msg [$tag01,$tag02,..]
# output      : echo <tags>;<date>;<msg>
# obs         : if tags was separeted by spaces or ; will be replaced by ,
function lu_echo {
    lu_echo_msg=$1
    lu_echo_tags=$2
    lu_echo_date=$(date +'%d/%m/%Y %H:%M:%S')
    
    if [ -z $lu_echo_tags ] ; then
       lu_echo_tags="${lu_echo_date}"
    else
       lu_echo_tags="${lu_echo_tags};${lu_echo_date}"
    fi   
    
    echo "${lu_echo_tags};${lu_echo_msg}"
}

###############
# end functions
###############

####################
# Settings 
####################

# pode variar dependendo do shell ou distribuição
NAME_HOST=$(hostname)
NAME_USER=${USER}

if [ -z ${NAME_HOST} -o -z ${NAME_USER} ];then
   echo "Redefina corretamente estas variáveis do sistema:"
   echo "NAME_HOST " $NAME_HOST
   echo "NAME_USER " $NAME_USER
fi 

#
# definição de paths: 
#
# $PATH_APP         : onde roda o aplicativo
# $PATH_OR_BACKUP   : diretório com os links para volumes a serem backupeados
# $PATH_MIDIAS      : local onde são montadas as mídias de backup
PATH_APP=/home/$NAME_USER/scripts
PATH_OR_BACKUP=/home/$NAME_USER/backups/rsync
PATH_MIDIAS=/media/$NAME_USER

#
# Seleção do dispositivo e path de destino de backup
#
LIST_MEDIAS=""
for item in `ls $PATH_MIDIAS`;do 
    LIST_MEDIAS="${LIST_MEDIAS}${item}\
"
done

DISP=`zenity --list \
  --title="Escolha o dispositivo de gravação" \
  --column="Dispositivo" \
"${LIST_MEDIAS}"`
case $? in
         0)
                echo "Dispositivo \"$DISP\" selecionado.";;
         1)
                echo "Nenhum dispositivo foi selecionado"
                exit 1
                ;;
        -1)
                echo "Ocorreu um erro na seleção do dispositivo"
                exit 1
                ;;
esac

PATH_DISP="${PATH_MIDIAS}/${DISP}"
PATH_DST_BACKUP="${PATH_DISP}/backup_${NAME_HOST}_${NAME_USER}"

# definição do comando rsync
RSCMD="/usr/bin/rsync -auq --delete"

##############
# checks 
##############

echo "Identificado o dispositivo:${DISP}..."
echo "Tecle <ctrl>+c para sair ou enter para para continuar " ; read

# verifica se o dispositivo está montado
if [ ! -d ${PATH_DISP} ];then
   echo "dispositivo ${DISP} não montado"
   exit 1
fi

# cria pasta backup de destino se não existir
if [ ! -d ${PATH_DST_BACKUP} ];then
   echo "criando pasta de deistino ${PATH_DST_BACKUP}"
   mkdir ${PATH_DST_BACKUP}
   [ $? -ne 0 ] && echo "Erro na criação de diretório" && exit 1
fi

########
# escolha dos locais que serão backupeados de acordo com o
# dispositivo deve ser estar nos if's abaixo
########

# itens backpeados por default (opcional)
lista_bkp_def="imagens musica arquivos"

# configuração de lista para meus dispositivos específicos
if [ "${DISP}" = "hde_lua" ];then
    lista_bkp_def="imagens musica arquivos"
elif [ "${DISP}" = "hde_io" ];then
    lista_bkp_def="imagens musica arquivos"
elif [ "${DISP}" = "hde_europa" ];then
    lista_bkp_def="imagens musica arquivos videos"
elif [ "${DISP}" = "hde_titan" ];then
    lista_bkp_def="imagens musica arquivos videos"                            
fi

# montando itens da coluna options
lista_opt=""
for elm in `ls "${PATH_OR_BACKUP}"`;do
    # filtra os arquivos que não são links
    if [ ! -L "${PATH_OR_BACKUP}/${elm}" ] ; then
        continue
    fi
    
    # verifica se link está na relação default
    is_check="FALSE"
    echo "${lista_bkp_def}" | grep -q "${elm}"
    if [ $? -eq 0 ] ; then
        is_check="TRUE"
    fi
    
    # montando lista de opções
    lista_opt="${lista_opt}${is_check} ${elm} "
done

# aborta se lista estiver vazia
[ -z "${lista_opt}" ] && echo "Lista de volumes de backup vazia. Verifique o diretório ${PATH_OR_BACKUP}" && exit 1


lista_bkp=$(zenity  --list  --text "Escolha os volumes para backup" --checklist  --column "Check" --column "Volumes" \
${lista_opt} --separator=" ")
case $? in
         1)
                echo "Lista de volumes para backup não selecionada"
                exit 1
                ;;
        -1)
                echo "Ocorreu um erro na seleção de volumes de backup"
                exit 1
                ;;
esac

#  última checagem antes do back-up
lu_echo "-----------------"
lu_echo "Configurações de backup"
echo "Dispositivo     : ${DISP}"
echo "itens de backup : ${lista_bkp}"
echo "diret. destino  : ${PATH_DST_BACKUP}"
echo "comando         : ${RSCMD}"
echo ""
echo "Tecle <ctrl>+c para sair ou enter para para iniciar " ; read

# loop de backups
lu_echo "Início"
for elm in ${lista_bkp};do
   lu_echo "-------------------"
   lu_echo "backpeando ${elm} "
   # tratando origem
   path_org="${PATH_OR_BACKUP}/${elm}"
   if [ ! -d ${path_org} ];then
       lu_echo "diretório de origem ${path_org} não encontrado"
       exit 1
   fi
   
   # tratando destino
   path_dst="${PATH_DST_BACKUP}/${elm}"
   if [ ! -d ${path_dst} ];then
       lu_echo "criando diretório de destino ${path_dst}"
       mkdir -p ${path_dst}
       [ $? -ne 0 ] && echo "Erro na criação de diretório" && exit 1
   fi
   
   # executando back-up
   ${RSCMD} ${path_org}/ ${path_dst}
   if [ $? -ne 0 ];then
      lu_echo "erro no backup de ${elm}. Tecle <ctrl>+c para sair ou enter para continuar"
      read
   fi
done
lu_echo "Concluido"
