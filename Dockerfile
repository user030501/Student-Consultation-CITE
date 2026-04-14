# Serve the prebuilt Flutter web app with Nginx.
# Build it locally first with:
# flutter build web --release --dart-define=API_BASE_URL=/api
FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
