# Glitter 

Simple git server written in Elixir.

## How to setup
0. Get Elixir
1. Clone repo
3. Run `mix deps.get`
4. Run `mix deps.compile`
5. Run `MIX_ENV=prod mix release`
6. Then run the command it returns

## CLI
Add bin/gl to your PATH. Usage: 
```
gl new [repo name] - Create repo
gl init - Create repo from current folder name, init git and add remote as local
gl rm [repo name] - Delete repo
gl server [server url] - Add server
```

## API
* "/a/new?name={REPO NAME}"
> Create a repo
* "/a/rm?name={REPO NAME}"
> Delete repo
