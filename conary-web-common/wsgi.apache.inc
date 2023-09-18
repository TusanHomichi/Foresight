WSGIScriptAlias / /srv/conary-repositories/config/common/conary.wsgi
<Location />
    Order deny,allow
    Allow from all
</Location>
Alias /conary-static /usr/share/conary/web-common/

RewriteEngine On
RewriteRule ^/conary$ /conary/ [R=301,L]
RewriteRule ^/$ /conary/browse [R=301,L]
