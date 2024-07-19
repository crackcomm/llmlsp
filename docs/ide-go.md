# Go editor support

If you want `gopls` to pickup protobuf generated stubs you will need to add
`GOPACKAGESDRIVER` environment variable to your language server configuration.

Example `coc-settings.json`:

```JSON
{
  "languageserver": {
    "go": {
      "command": "gopls",
      "rootPatterns": ["go.mod"],
      "trace.server": "verbose",
      "filetypes": ["go"],
      "env": {
        "GOPACKAGESDRIVER": "./tools/gopackagesdriver.sh"
      }
    }
}
```

See [editor setup](https://github.com/bazelbuild/rules_go/wiki/Editor-setup) for more information
as well as VS Code setup.
