# hxgithub

Some externs for the GitHub API in src/github.

## Release helper

Example command line:

```
neko release.n -t personal_access_token -h 4.0.0-preview.1 -f haxe_latest.tar.gz -d -u -ur -uw -doc
```

## Haxe releases

You will need a [GitHub personal access token](https://github.com/settings/tokens). It needs to have at least the `repo_deployment` scope available. (TODO: confirm this; alternatively use a temporary token with all scopes granted.)

```
# build release script
haxe build-release.hxml
cd bin
# set GitHub personal access token
echo "<paste token here>" > .github-token
# set release version
export VER="4.0.0-rc.3"
# download binaries (replace filename with correct commit)
neko release.n -h "$VER" -d haxe_2017-09-12_master_2344f23.tar.gz
# upload binaries
neko release.n -h "$VER" -u
# dry run to create RELEASE.md and CHANGES.md
neko release.n --dry -h "$VER" -uw -ur
# put release notice into RELEASE.md
...
# update release and website
neko release.n -h "$VER" -uw -ur
# generate & upload documentation (may not work correctly)
neko release.n -h "$VER" -doc
```

Then to update the release version on haxe.org:

 - edit [`downloads/versions.json`](https://github.com/HaxeFoundation/haxe.org/blob/staging/downloads/versions.json)
 - (if applicable) edit [`views/DownloadVersion.html`](https://github.com/HaxeFoundation/haxe.org/blob/staging/views/DownloadVersion.html) to point to the latest preview
