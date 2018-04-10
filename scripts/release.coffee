exec = require('shelljs').exec
fs   = require('fs')

# Lint
throw 'lint command failed' if exec('./node_modules/.bin/tslint ./src/**/*.ts ./tests/**/*.ts').code != 0

# Test
throw 'jest command faild' if exec('./node_modules/.bin/jest --no-cache').code != 0

# Write next version
pkg = JSON.parse fs.readFileSync('./package.json', 'utf-8')
versions = pkg.version.split(".").map (v) ->
    return parseInt v
versions[versions.length - 1] = versions[versions.length - 1] + 1
pkg.version = versions.join(".")
fs.writeFileSync "./package.json", JSON.stringify(pkg, null, 2)

# Commit next version
throw 'git commit failed' if exec("git add . && git commit -m '[release] #{pkg.version}'").code != 0

# Build
throw 'build failed' if exec('npm run build').code != 0

# Publish
throw 'publish failed' if exec('npm publish').code != 0
