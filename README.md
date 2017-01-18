# ldap-auth-server

This is a small server for use with Nginx's [auth_request module](http://nginx.org/en/docs/http/ngx_http_auth_request_module.html).
It requires Nginx compiled with Lua support, such as found in OpenResty. It
also requires the following lua modules:

* lualdap
* luaposix
* etlua
* luafilesystem

## install + use

Just git clone this repository somewhere.

From there, you can install the needed lua modules however you regularly do.

If you install them into a folder named `lua_modules`, then the script
`bin/ldap-auth-server` will use (and *only* use) modules found under that
folder. For example, after cloning you could run:

```bash
luarocks install --tree lua_modules lualdap
luarocks install --tree lua_modules luaposix
luarocks install --tree lua_modules etlua
luarocks install --tree lua_modules luafilesystem
```

Make a copy of `etc/config.lua.example` to `etc/config.lua` and edit
as-needed, then run `bin/ldap-auth-server`.

By default, all temp files, compiled config files, etc are placed at
`$HOME/.ldap-auth-server` - this can be changed by setting the `work_dir`
variable in `etc/config.lua`

You can also copy `res/nginx.conf` somewhere and edit it, and setup
an nginx instance on your own. In that case, the only required module is
lualdap.

To run as a service, there's an example systemd unit file at
`misc/ldap-auth-server.service`:

```bash
sudo cp misc/ldap-auth-server.service /etc/systemd/system/ldap-auth-server.service
# edit /etc/systemd/system/ldap-auth-server.service as needed
sudo systemctl daemon-reload
sudo systemctl enable ldap-auth-server.service
sudo systemctl start ldap-auth-server.service
```

## License

Released under an MIT-style license. See the file `LICENSE` for details.

