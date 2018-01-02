#!/bin/bash

#find /home/alex/projetos_dataprev/ -type d -name "target" -exec rm -Rvf {} \;
echo "Apagando conteúdo da pasta target."
path_code=/home/alex/projetos_dataprev
path_sag=$path_code/sag-agu
path_get=$path_code/get

cd $path_sag/portal-atendimento-negocio
mvn clean

cd $path_sag/SagBatch
mvn clean

cd $path_sag/SagBatchSigma
mvn clean

cd $path_sag/SagGestaoAguVisao
mvn clean

cd $path_sag/SagInternetVisao
mvn clean

cd $path_sag/SagIntranetVisao
mvn clean

cd $path_sag/SagService
mvn clean

cd $path_get/get-intranet
mvn clean

cd $path_get/get-rest-api
mvn clean

cd $path_get/get-consumidores
mvn clean

path_dst_code=~/Desktop/code-sag-get
if [ ! -d ${path_dst_code} ];then
    echo "criando diretório de destino ${path_dst_code}"
    mkdir -p ${path_dst_code}
    [ $? -ne 0 ] && echo "Erro na criação de diretório" && exit 1
fi

echo "Compactando código sag"
cd $path_code
tar -cjf ~/Desktop/code-sag-get/sag.tar.bz2 sag-agu/
#tar -czf ~/Desktop/code-sag-get/sag.tar.gz sag-agu/

echo "Compactando código get"
cd $path_code
tar -cjf ~/Desktop/code-sag-get/get.tar.bz2 get/
#tar -czf ~/Desktop/code-sag-get/get.tar.gz get/

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
