# Replace 'assemulator' with your actual container name if different

# Copy the main nginx config from the container
docker cp assemulator:/etc/nginx/conf.d/default.conf D:\source\repos\assemulator_ynh\container_info\default.conf

# (Optional) Copy the main nginx.conf if you want it too
docker cp assemulator:/etc/nginx/nginx.conf D:\source\repos\assemulator_ynh\container_info\nginx.conf

# Copy the appsettings.json from the container's web root
docker cp assemulator:/usr/share/nginx/html/appsettings.json D:\source\repos\assemulator_ynh\container_info\appsettings.json

# (Optional) Copy the environment file if you have one
# docker cp assemulator:/path/to/your/envfile D:\source\repos\assemulator_ynh\container_info\envfile