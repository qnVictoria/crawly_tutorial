defmodule Homebase do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.homebase.co.uk"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://www.homebase.co.uk/our-range/tools/power-tools/drills/corded-drills"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # Parse response body to document
    {:ok, document} = Floki.parse_document(response.body)

    # # Extract product category URLs
    # product_categories =
    #   document
    #   |> Floki.find("section.wrapper")
    #   |> Floki.find("div.article-tiles.article-tiles--wide a")
    #   |> Floki.attribute("href")

    # Extract individual product page URLs
    urls =
      document
      |> Floki.find("a.product-tile2")
      |> Floki.attribute("href")

    # urls = product_pages ++ product_categories

    # Convert URLs into Requests
    requests =
      urls
      |> Enum.uniq()
      |> Enum.map(&build_absolute_url/1)
      |> Enum.map(&Crawly.Utils.request_from_url/1)

    # Create item (for pages where items exists)
    item = %{
      title:
        document
        |> Floki.find("div.page-title h1")
        |> Floki.text(),
      sku:
        document
        |> Floki.find(".product-header-heading span")
        |> Floki.text(),
      price:
        document
        |> Floki.find(".price-value [itemprop=priceCurrency]")
        |> Floki.text()
    }

    %Crawly.ParsedItem{:items => [item], :requests => requests}
  end

  defp build_absolute_url(url), do: URI.merge(base_url(), url) |> to_string()
end
