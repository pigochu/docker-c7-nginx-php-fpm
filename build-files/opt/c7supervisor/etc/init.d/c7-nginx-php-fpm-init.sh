envnames=$(env | sed 's/=/ /g' | awk '{print "${"$1"}"}' | paste -sd ':')
envsubst $envnames < /etc/nginx/nginx.template> /etc/nginx/nginx.conf