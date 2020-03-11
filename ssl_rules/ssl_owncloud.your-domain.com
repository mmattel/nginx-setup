# ssl rules for <owncloud.your-domain.com>
# eases letsencrypt initial cert install

#        ssl on;

        ssl_certificate         /etc/letsencrypt/live/<owncloud.your-domain.com>/fullchain.pem;
        ssl_certificate_key     /etc/letsencrypt/live/<owncloud.your-domain.com>/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/<owncloud.your-domain.com>/cert.pem;

        ssl_stapling on;
        ssl_stapling_verify on;

        ssl_session_timeout 5m;
