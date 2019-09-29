#!/usr/bin/env bats
load test_helper

@test "image build" {

  run build_image
  [ "$status" -eq 0 ]

}

@test "http response" {

  tmp_file="$BATS_TMPDIR/docker-test"
  rm -f $tmp_file

  run_image
  wait_process apache2 php-fpm7.3
  
  sleep 5

  curl --silent --insecure https://$CONTAINER_IP >> $tmp_file
  run grep -c "loginform" $tmp_file
  rm $tmp_file
  clear_container

  [ "$status" -eq 0 ]
  [ "$output" = "1" ]

}

@test "http response with database login" {
  skip # broken

  tmp_file="$BATS_TMPDIR/docker-test"
  rm -f $tmp_file

  # we start a new mariadb container
  DB_CID=$(docker run -e MARIADB_ROOT_ALLOWED_NETWORKS="#PYTHON2BASH:['172.17.%.%', 'localhost', '127.0.0.1', '::1']" -d osixia/mariadb:10.1.19)
  DB_IP=$(get_container_ip_by_cid $DB_CID)

  # we start the wordpress container and set PHPMYADMIN_DB_HOSTS
  run_image -e PHPMYADMIN_DB_HOSTS=$DB_IP

  # wait mariadb
  wait_process_by_cid $DB_CID mysqld

  # wait wordpress container apache2 service
  wait_process apache2 php-fpm7.3

  curl -L --silent --insecure -c $BATS_TMPDIR/cookie.txt https://$CONTAINER_IP >> $tmp_file

  curl -L --silent --insecure -b $BATS_TMPDIR/cookie.txt https://$CONTAINER_IP/index.php -H 'Origin: https://$CONTAINER_IP' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/40.0.2214.111 Chrome/40.0.2214.111 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: https://$CONTAINER_IP' -H 'Connection: keep-alive' --data 'pma_username=admin&pma_password=admin&server=1&token=' --compressed >> $tmp_file

  run grep -c "pma_navigation_tree_content" $tmp_file

  rm $tmp_file
  rm $BATS_TMPDIR/cookie.txt
  #clear_container

  # clear mariadb container
  #clear_containers_by_cid $DB_CID

  [ "$status" -eq 0 ]
  [ "$output" = "1" ]

}
