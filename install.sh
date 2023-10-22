
apt install sudo -y
apt install wget -y
apt-get install nginx -y
cd /usr/local/src
NGINX_VERSION=$(nginx -v 2>&1 | awk '{print $3}' | awk -F/ '{print $2}')
wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
# Downloading Lua
wget https://github.com/openresty/luajit2/archive/v2.1-20200102.tar.gz
# Downloading Nginx development kit
wget https://github.com/simplresty/ngx_devel_kit/archive/v0.3.1.tar.gz
# Downloading Nginx Lua Module
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.15.tar.gz
# Downloading Resty Core
wget https://github.com/openresty/lua-resty-core/archive/v0.1.17.tar.gz
# Downloading Resty LRU Cache
wget https://github.com/openresty/lua-resty-lrucache/archive/v0.09.tar.gz

apt-get install tar make gcc -y

sudo apt install build-essential tar -y

sudo apt-get install libpcre2-dev -y

sudo apt-get install libaio1-dev -y

sudo apt install git -y

find . -type f -name '*.tar.gz' -exec tar -xzf {} \;

cd luajit*
make
make install
export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.1

cd /usr/local/src/lua-resty-core*
make install

cd /usr/local/src/lua-resty-lrucache*
make install

apt-get install -y libpcre3-dev libaio-dev libgd-dev libxslt1-dev librust-openssl-dev

cd /usr/local/src
rm *.tar.g

cd /usr/local/src/nginx*
NGINX_CONFIGURE_ARGUMENTS=$(echo $(nginx -V 2>&1) | sed -nr '/configure arguments:/ s/.*configure arguments:([^"]+).*/\1/p'|sed 's/--with-ipv6 //g'|sed 's/--add-dynamic-module=\/build\/nginx-zctdR4\/nginx-1.18.0\/debian\/modules\/http-geoip2 //g'|sed 's/-Wl,-z,relro -Wl,-z,now -specs=\/usr\/lib\/rpm\/redhat\/redhat-hardened-ld -Wl,-E/-Wl,-rpath,\/usr\/local\/lib/g')

eval "CFLAGS=-Wno-error ./configure --add-dynamic-module=../ngx_devel_kit-0.3.1 --add-dynamic-module=../lua-nginx-module-0.10.15 $NGINX_CONFIGURE_ARGUMENTS"

make modules

cp objs/*.so /usr/lib/nginx/modules

echo -e "load_module /usr/lib/nginx/modules/ndk_http_module.so;\nload_module /usr/lib/nginx/modules/ngx_http_lua_module.so;" > /etc/nginx/modules-enabled/lua.conf

echo -e 'lua_package_path "/usr/local/nginx/conf/?.lua;/usr/local/share/lua/?.lua;/usr/local/lib/lua/?.lua;/etc/nginx/waf/?.lua;;";\nlua_shared_dict limit 10m;\n\ninit_by_lua_file  /etc/nginx/waf/init.lua;\naccess_by_lua_file /etc/nginx/waf/waf.lua;' >> /etc/nginx/conf.d/openresty.conf

mkdir /etc/nginx/waf/logs

chmod -R 777 /etc/nginx/waf/logs
