#!/bin/sh

#start a mariadb container
linkedContainer="osixia-phpmyadmin-mariadb"

echo "docker.io run --name $linkedContainer -d osixia/mariadb"
docker.io run --name $linkedContainer -d osixia/mariadb 
sleep 10

dir=$(dirname $0)

runOptions="--link $linkedContainer:db"
. $dir/tools/run-container.sh

echo "curl -c $testDir/cookie.txt $IP"
curl -c $testDir/cookie.txt $IP

echo "curl http://$IP/index.php -L -b $testDir/cookie.txt -H 'Origin: http://172.17.0.4' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: http://$IP/' -H 'Connection: keep-alive' --data 'pma_username=admin&pma_password=toor&server=1&target=index.php&token=c38f6e514c047ffa2d16a2b10949ff2e' --compressed"

curl curl http://$IP/index.php -L -b $testDir/cookie.txt -H 'Origin: http://172.17.0.4' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: http://$IP/' -H 'Connection: keep-alive' --data 'pma_username=admin&pma_password=toor&server=1&target=index.php&token=c38f6e514c047ffa2d16a2b10949ff2e' --compressed

docker.io stop $linkedContainer
docker.io rm $linkedContainer

$dir/tools/delete-container.sh
