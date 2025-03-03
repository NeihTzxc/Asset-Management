#!/bin/bash

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd frappe-bench
    bench start
else
    echo "Creating new bench..."
fi

export PATH="${NVM_DIR}/versions/node/v${NODE_VERSION_DEVELOP}/bin/:${PATH}"

bench init --skip-redis-config-generation frappe-bench

cd frappe-bench

# Cấu hình sử dụng container thay vì localhost
bench set-mariadb-host mariadb
bench set-redis-cache-host redis:6379
bench set-redis-queue-host redis:6379
bench set-redis-socketio-host redis:6379

# Xóa Redis & Watch khỏi Procfile
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

# Lấy và cài đặt Asset Management
bench get-app https://github.com/NeihTzxc/Asset-Management

# Cập nhật Bench
bench update --reset

# Tạo site mới
bench new-site asset.localhost \
--force \
--mariadb-root-password 123 \
--admin-password admin \
--no-mariadb-socket

# Cài đặt Asset Management vào site
bench --site asset.localhost install-app asset_management
bench --site asset.localhost set-config developer_mode 1
bench --site asset.localhost enable-scheduler
bench --site asset.localhost clear-cache
bench use asset.localhost

bench start
