# [MobileDoc](https://github.com/bustlelabs/content-kit-editor/blob/master/MOBILEDOC.md) HTML Renderer for Elixir


### (WIP)

Similarly to
[MobileDoc HTML Renderer](https://github.com/bustlelabs/mobiledoc-html-renderer),
this an HTML renderer for the
[MobileDoc](https://github.com/bustlelabs/content-kit-editor/blob/master/MOBILEDOC.md)
format used by the [ContentKit](https://github.com/bustlelabs/content-kit-editor)
editor, written in [Elixir](http://elixir-lang.org/).

## Usage

```elixir
mobiledoc = Poison.decode!(~s(
  {
    "version": "0.2.0",
    "sections": [
      [
        ["B"]
      ],
      [
        [1, "P", [
          [[0], 0, "hello world"]
        ]]
      ]
    ]
  }
))

rendered = MobileDoc.Renderer.render(mobiledoc)
# renders <div><p><b>hello world</b></b></div>
```
