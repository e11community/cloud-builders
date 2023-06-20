# node

A Debian-based image to be patch and upgraded roughly every 2 weeks. Downstream builders will update shortly thereafter to also get these upgrades.

* Has other common CLI utilities like jq.
* Core npm packages.

## Commands

```
./build.sh --project=PROJECT_ID --main-version=16.14.0-buster submit
```

