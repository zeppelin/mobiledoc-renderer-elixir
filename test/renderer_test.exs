defmodule MobileDoc.RendererTest do
  use ExUnit.Case
  import MobileDoc.Renderer

  test "renders a v0.2.0 mobiledoc" do
    mobiledoc = %{
      "version" => "0.2.0",
      "sections" => [
        [], # markers
        [   # sections
          [1, "P", [
            [[], 0, "hello world"]]
          ]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><p>hello world</p></div>"
  end

  test "renders a v0.3.0 mobiledoc" do
    mobiledoc = %{
      "version" => "0.3.0",
      "atoms" => [],
      "markups" => [],
      "sections" => [
        [1, "P", [
          [0, [], 0, "hello world"]]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><p>hello world</p></div>"
  end
end
