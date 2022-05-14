### issue
https://github.com/yarnpkg/berry/issues/4455

### requirement
- docker

### reproduce
```sh
$ ./test.sh
...
>>> OK: offline pnpm install test
...
>>> FAILED: offline yarn berry bootstrap test
...
+ yarn add lodash@4.17.21
➤ YN0000: ┌ Resolution step
➤ YN0001: │ RequestError: getaddrinfo EAI_AGAIN registry.yarnpkg.com
...
>>> FAILED: offline yarn install test
```
