defmodule MobileDoc.Renderer_0_3_Test do
  use ExUnit.Case
  import MobileDoc.Renderer_0_3

  @mobiledoc_version "0.3.0"

  @markup_section_type 1
  @image_section_type 2
  @list_section_type 3
  @card_section_type 10

  @markup_marker_type 0
  @atom_marker_type 1

  test "renders an empty mobiledoc" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "atoms" => [],
      "cards" => [],
      "markups" => [],
      "sections" => []
    }

    assert render(mobiledoc) == "<div></div>"
  end

  test "renders a mobiledoc without markers" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "atoms" => [],
      "cards" => [],
      "markups" => [],
      "sections" => [
        [@markup_section_type, "P", [
          [@markup_marker_type, [], 0, "hello world"]]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><p>hello world</p></div>"
  end

  test "renders a mobiledoc with simple (no attributes) marker" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "atoms" => [],
      "cards" => [],
      "markups" => [
        ["B"]
      ],
      "sections" => [
        [@markup_section_type, "P", [
          [@markup_marker_type, [0], 1, "hello world"]]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><p><b>hello world</b></p></div>"
  end

  test "renders a mobiledoc with complex (has attributes) marker" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "atoms" => [],
      "cards" => [],
      "markups" => [
        ["A", ["href", "http://google.com"]],
      ],
      "sections" => [
        [@markup_section_type, "P", [
          [@markup_marker_type, [0], 1, "hello world"]
        ]]
      ]
    }

    assert render(mobiledoc) == "<div><p><a href=\"http://google.com\">hello world</a></p></div>"
  end

  test "renders a mobiledoc with multiple markups in a section" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "atoms" => [],
      "cards" => [],
      "markups" => [
        ["B"],
        ["I"]
      ],
      "sections" => [
        [@markup_section_type, "P", [
          [@markup_marker_type, [0], 0, "hello "], # b
          [@markup_marker_type, [1], 0, "brave "], # b+i
          [@markup_marker_type, [], 1, "new "], # close i
          [@markup_marker_type, [], 1, "world"] # close b
        ]]
      ]
    }

    assert render(mobiledoc) == "<div><p><b>hello <i>brave new </i>world</b></p></div>"
  end

  test "renders a mobiledoc with image section" do
    url = "data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACwAAAAAAQABAAACAkQBADs="
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "atoms" => [],
      "cards" => [],
      "markups" => [],
      "sections" => [
        [@image_section_type, url]
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
      "atoms" => [],
      "cards" => [
        [card_name, payload]
      ],
      "markups" => [],
      "sections" => [
        [@card_section_type, 0]
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
      "atoms" => [],
      "cards" => [
        [card_name, payload]
      ],
      "markups" => [],
      "sections" => [
        [@card_section_type, 0]
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
      "atoms" => [],
      "cards" => [
        [card_name, payload]
      ],
      "markups" => [],
      "sections" => [
        [@card_section_type, 0]
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
      "atoms" => [],
      "cards" => [
        [card_name, payload]
      ],
      "markups" => [],
      "sections" => [
        [@card_section_type, 0]
      ]
    }

    assert render(mobiledoc) == "<div><div><img src=\"example.org/foo.jpg\"></div></div>"
  end

  test "render mobiledoc with list section and list items" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "atoms" => [],
      "cards" => [],
      "markups" => [],
      "sections" => [
        [@list_section_type, "ul", [
          [[@markup_marker_type, [], 0, "first item"]],
          [[@markup_marker_type, [], 0, "second item"]]
        ]]
      ]
    }

    assert render(mobiledoc) == "<div><ul><li>first item</li><li>second item</li></ul></div>"
  end

  test "render mobiledoc with atom" do
    defmodule HelloAtom do
      defmodule Html do
        def render(text, _options, _env, _payload) do
          "Hello #{text}"
        end
      end
    end

    mobiledoc = %{
      "version" => @mobiledoc_version,
      "atoms" => [
        ["hello-atom", "Bob", %{ "id" => 42}]
      ],
      "cards" => [],
      "markups" => [],
      "sections" => [
        [@markup_section_type, "P", [
          [@atom_marker_type, [], 0, 0]]
        ]
      ]
    }

    rendered = render(mobiledoc, %{}, %{
      "hello-atom" => HelloAtom
    })

    assert rendered == "<div><p>Hello Bob</p></div>"
  end

  test "render mobiledoc with missing atom falls back to text" do
    mobiledoc = %{
      "version" => @mobiledoc_version,
      "atoms" => [
        ["hello-atom", "Bob", %{ "id" => 42}]
      ],
      "cards" => [],
      "markups" => [],
      "sections" => [
        [@markup_section_type, "P", [
          [@atom_marker_type, [], 0, 0]]
        ]
      ]
    }

    assert render(mobiledoc) == "<div><p>Bob</p></div>"
  end
end