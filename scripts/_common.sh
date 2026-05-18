#!/bin/bash

app=$YNH_APP_INSTANCE_NAME
final_path="/var/www/$app"
compose_file="$final_path/docker-compose.yml"

install_container_dependencies() {
	local compose_dep=""

	if apt-cache show docker-compose-plugin >/dev/null 2>&1; then
		compose_dep="docker-compose-plugin"
	elif apt-cache show docker-compose >/dev/null 2>&1; then
		compose_dep="docker-compose"
	fi

	if [ -z "$compose_dep" ]; then
		ynh_die --message="Neither docker-compose-plugin nor docker-compose is available from apt repositories"
	fi

	ynh_exec_warn_less ynh_install_app_dependencies docker.io "$compose_dep"
}

compose_upstream_available() {
	if command -v docker-compose >/dev/null 2>&1; then
		echo "docker-compose"
		return 0
	fi

	if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
		echo "docker compose"
		return 0
	fi

	ynh_die --message="Docker Compose command is unavailable. Expected either 'docker compose' or 'docker-compose'."
}

get_setting_or_die() {
	local key=$1
	local value
	value=$(ynh_app_setting_get --app="$app" --key="$key")
	[ -n "$value" ] || ynh_die --message="Missing $key setting"
	echo "$value"
}

render_compose_file() {
	local app_port=$1
	local image=$2

	mkdir -p "$final_path"
	cp ../conf/docker-compose.yml "$compose_file"
	ynh_replace_string --match_string="__APP__" --replace_string="$app" --target_file="$compose_file"
	ynh_replace_string --match_string="__PORT__" --replace_string="$app_port" --target_file="$compose_file"
	ynh_replace_string --match_string="__APPDIR__" --replace_string="$final_path" --target_file="$compose_file"
	ynh_replace_string --match_string="__IMAGE__" --replace_string="$image" --target_file="$compose_file"
}

compose_pull_up() {
	local compose_cmd
	compose_cmd=$(compose_upstream_available)

	if [ "$compose_cmd" = "docker-compose" ]; then
		ynh_exec_warn_less docker-compose -f "$compose_file" pull
		ynh_exec_warn_less docker-compose -f "$compose_file" up -d
	else
		ynh_exec_warn_less docker compose -f "$compose_file" pull
		ynh_exec_warn_less docker compose -f "$compose_file" up -d
	fi
}

compose_down_if_exists() {
	if [ -f "$compose_file" ]; then
		if command -v docker-compose >/dev/null 2>&1; then
			ynh_exec_warn_less docker-compose -f "$compose_file" down || true
		elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
			ynh_exec_warn_less docker compose -f "$compose_file" down || true
		fi
	fi
}
