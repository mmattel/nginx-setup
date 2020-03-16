server {
        listen 80;
        server_name <your-domain.com> www.<your-domain.com>;

        # necessary for letsencrypt
        location /.well-known/acme-challenge {
                default_type "text/plain";
                root /var/www/letsencrypt/<your-domain.com>;
        }

        # necessary for letsencrypt
        location / {
                return 301 https://$server_name$request_uri;  # enforce https
        }
}

server {
        listen 443 ssl http2;
        server_name <your-domain.com> www.<your-domain.com>;

        # ssl letsencrypt
        # remark that line when manually setting up letsencrypt the first time as the files must be created
        # un-remark when done
        include /etc/nginx/ssl_rules/ssl_<your-domain.com>;

        access_log /var/log/nginx/<your-domain.com>.access_log;
        error_log  /var/log/nginx/<your-domain.com>.error_log;

        root /var/www/<your-domain.com>;
        index index.php index.html;

        # include shared headers
        include /etc/nginx/shared_rules/shared_headers.conf;

        # include site error management
        include /etc/nginx/sites-available/error_sites;

        # include all access to be return 444 (close connection)
        include /etc/nginx/shared_rules/shared_close_connection.conf;
        include /etc/nginx/shared_rules/shared_close_wordpress.conf;

        # add whatever is needed to run your site
        location = /robots.txt {
            allow all;
            log_not_found off;
            access_log off;
        }

        location = /favicon.ico {
                log_not_found off;
        }
}
