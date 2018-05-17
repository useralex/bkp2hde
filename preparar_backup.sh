#!/bin/bash

#find /home/alex/projetos_dataprev/ -type d -name "target" -exec rm -Rvf {} \;
echo "Apagando conteúdo da pasta target."
path_code_raiz=/home/alex/projetos_dataprev/
path_code=$path_code_raiz/git

cd $path_code/portal-atendimento-negocio
mvn clean

cd $path_code/SagBatch
mvn clean

cd $path_code/SagBatchSigma
mvn clean

cd $path_code/SagGestaoAguVisao
mvn clean

cd $path_code/SagInternetVisao
mvn clean

cd $path_code/SagIntranetVisao
mvn clean

cd $path_code/SagService
mvn clean

cd $path_code/get-intranet
mvn clean

cd $path_code/get-rest-api
mvn clean

cd $path_code/get-consumidores
mvn clean

cd $path_code/get-gestao
mvn clean

path_dst_code=~/Desktop/code-sag-get
if [ ! -d ${path_dst_code} ];then
    echo "criando diretório de destino ${path_dst_code}"
    mkdir -p ${path_dst_code}
    [ $? -ne 0 ] && echo "Erro na criação de diretório" && exit 1
fi

echo "Compactando código sag e get"
cd $path_code_raiz
tar -cjf ~/Desktop/code-sag-get/sag_get.tar.bz2 git/

path_dst_email=~/Desktop/thunderbird
if [ ! -d ${path_dst_email} ];then
    echo "criando diretório de destino ${path_dst_email}"
    mkdir -p ${path_dst_email}
    [ $? -ne 0 ] && echo "Erro na criação de diretório" && exit 1
fi

echo "Compactando thunderbird"
cd 
tar -cjf Desktop/thunderbird/thunderbird.tar.bz2 .thunderbird

echo "FIM"
