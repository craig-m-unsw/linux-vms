# modules

Puppet will auto load modules from this directory.

We don't need to specify them in `Puppetfile` because `environment.conf` has this:

```
modulepath     = site-modules:modules:$basemodulepath
```

So to create a new module, from the control repo, you can:

```shell
mkdir -pv modules
cd modules
pdk new module cust01_mod
cd cust01_mod
pdk new class myfirstclass
```
