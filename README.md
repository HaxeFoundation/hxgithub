# hxgithub

Some externs for the GitHub API in src/github.

## Release helper

Example command line:

```
neko release.n -t personal_access_token -h 4.0.0-preview.1 -f haxe_latest.tar.gz -d -u -ur -uw -doc
```

Session for Haxe releases:

```
# download binaries
neko release.n -t personal_access_token -h 4.0.0-preview.1 -f haxe_2017-09-12_master_2344f23.tar.gz -d
# upload binaries
neko release.n -t personal_access_token -h 4.0.0-preview.1 -u
# update release & website
neko release.n -t personal_access_token -h 4.0.0-preview.1 -uw -ur
# generate & upload documentation
neko release.n -t personal_access_token -h 4.0.0-preview.1 -doc
```