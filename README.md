# osixia/phpmyadmin

A docker image to run a phpMyAdmin.
> [phpmyadmin.net](http://www.phpmyadmin.net/)

## Quick start
Run phpMyAdmin docker image, make sure to replace `db.example.org` by your database hostname or IP :

	docker run -p 80:80 -e HTTPS=false -e DB_HOSTS=db.example.org -d osixia/phpmyadmin
	
you can now connect to phpMyadmin on http://localhost
