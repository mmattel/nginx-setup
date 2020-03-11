server {
        listen 80;
        server_name <owncloud.your-domain.com>;

        # necessary for letsencrypt
        location /.well-known/acme-challenge {
                default_type "text/plain";
                root /var/www/letsencrypt/<owncloud.your-domain.com>;
        }

        # necessary for letsencrypt
        location / {
                return 301 https://$server_name$request_uri;  # enforce https
        }
}

server {
        listen 443 ssl http2;
        server_name <owncloud.your-domain.com>;

        # ssl letsencrypt
        include /etc/nginx/ssl_rules/ssl_<owncloud.your-domain.com>;

        # no variables can be used, therefore not in shared_owncloud.conf

        access_log /var/log/nginx/owncloud.your-domain.com.access_log combined if=$loggable;
        error_log  /var/log/nginx/owncloud.your-domain.com.error_log;

        # this sets the variable $instance for the shared_owncloud config to parameterize it.
        set $instance <owncloud.your-domain.com>;

        # include shared headers
        include /etc/nginx/common_rules/shared_owncloud.conf;
}
