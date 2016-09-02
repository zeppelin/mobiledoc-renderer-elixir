defmodule MobileDoc.Renderer_0_2_Test do
  use ExUnit.Case
  import MobileDoc.Renderer_0_2

  @mobiledoc_version "0.2.0"

  test "renders an empty mobiledoc" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "sections" => [
        [], # markers
        []  # sections
      ]
    }

    assert render(mobiledoc) == "<div></div>"
  end

  test "renders a mobiledoc without markers" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
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

  test "renders a mobiledoc with simple (no attributes) marker" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "sections" => [
        [        # markers
          ["B"],
        ],
        [        # sections
          [1, "P", [
            [[0], 1, "hello world"]]
          ]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><p><b>hello world</b></p></div>"
  end

  test "renders a mobiledoc with complex (has attributes) marker" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "sections" => [
        [        # markers
          ["A", ["href", "http://google.com"]],
        ],
        [        # sections
          [1, "P", [
            [[0], 1, "hello world"]
          ]]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><p><a href=\"http://google.com\">hello world</a></p></div>"
  end

  test "renders a mobiledoc with multiple markups in a section" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "sections" => [
        [        # markers
          ["B"],
          ["I"]
        ],
        [        # sections
          [1, "P", [
            [[0], 0, "hello "], # b
            [[1], 0, "brave "], # b+i
            [[], 1, "new "], # close i
            [[], 1, "world"] # close b
          ]]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><p><b>hello <i>brave new </i>world</b></p></div>"
  end

  test "renders a mobiledoc with image section" do
    url = "data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACwAAAAAAQABAAACAkQBADs="
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "sections" => [
        [],      # markers
        [        # sections
          [2, url]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><img src=\"#{url}\"></div>"
  end

  test "renders a mobiledoc with card section and src in payload to image" do
    card_name = "title-card"
    payload = %{
      "src" => "bob.gif"
    }

    mobiledoc = %{
      "version" => @mobiledoc_version,
      "sections" => [
        [],      # markers
        [        # sections
          [10, card_name, payload]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><img src=\"bob.gif\"></div>"
  end

  test "renders a mobiledoc with card section and no src to nothing" do
    card_name = "title-card"
    payload = %{
      "name" => "bob"
    }

    mobiledoc = %{
      "version" => @mobiledoc_version,
      "sections" => [
        [],      # markers
        [        # sections
          [10, card_name, payload]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><p></p></div>"
  end

  test "renders a mobiledoc with card section that has been provided" do
    card_name = "title-card"
    payload = %{
      "name" => "bob"
    }

    defmodule TitleCard do
      defmodule Html do
        def setup(buffer, _options, _env, _payload) do
          buffer = buffer ++ ["Howdy "]
          buffer ++ ["friend"]
        end
      end
    end

    mobiledoc = %{
      "version" => @mobiledoc_version,
      "sections" => [
        [],      # markers
        [        # sections
          [10, card_name, payload]
        ]
      ]
    }

    rendered = render(mobiledoc, %{
      "title-card" => TitleCard
    })

    assert rendered == "<div><div>Howdy friend</div></div>"
  end

  test "renders a mobiledoc with default image section" do
    card_name = "image"
    payload = %{
      "src" => "example.org/foo.jpg"
    }

    mobiledoc = %{
      "version" => @mobiledoc_version,
      "sections" => [
        [],      # markers
        [        # sections
          [10, card_name, payload]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><div><img src=\"example.org/foo.jpg\"></div></div>"
  end

  test "render mobiledoc with list section and list items" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "sections" => [
        [],      # markers
        [        # sections
          [3, "ul", [
            [[[], 0, "first item"]],
            [[[], 0, "second item"]]
          ]]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><ul><li>first item</li><li>second item</li></ul></div>"
  end
end
