FROM nginx
COPY index.html /usr/share/nginx/html/
RUN chmod 777 -R /usr/share/nginx/html