# VS Code extenstion for Helium language

## Building extension

`npx vsce package`

This will create `vscode-helium-lang-x.y.z.vsix` file (where `x.y.z` is current version)

## Installing from package (recommended)

`code --install-extension vscode-helium-lang-x.y.z.vsix`

## Installing manually

`mkdir -p ~/.vscode/extensions/vscode-helium-lang/`

`cp -r syntaxes language-configuration.json package.json ~/.vscode/extensions/vscode-helium-lang`

(You need to copy those 2 .json files and syntaxes directory)