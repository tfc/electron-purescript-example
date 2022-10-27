# Electron Purescript Example

This repository presents a skeleton of a minimal example [Electron](https://www.electronjs.org/) app that is implemented in [Purescript](https://www.purescript.org/) and [React](https://reactjs.org/).

Big thank you to [@i-am-the-slime](https://github.com/i-am-the-slime) for providing me access to one of his applications to learn how Electron works together with Purescript!

In order to run the examples, install [nix](https://nixos.org/download.html) first.

![Screenshot from 2022-10-27 22-06-37](https://user-images.githubusercontent.com/29044/198387800-d68cb47c-caea-4a35-bbc4-f9f93fe40745.png)

## Running the application

You can run the application without checking the repository out:

```sh
nix run github:tfc/electron-purescript-example
```

## Development workflow

Check out the application and then run:

```sh
nix develop
npm install
npm run build
```

The `nix develop` step can be skipped if you have [`direnv`](https://direnv.net/)
