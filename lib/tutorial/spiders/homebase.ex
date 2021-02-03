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

    # Extract individual product page URLs
    urls =
      document
      |> Floki.find("a.product-tile2")
      |> Floki.attribute("href")

    # Convert URLs into Requests
    requests =
      urls
      |> Enum.uniq()
      |> Enum.map(&build_absolute_url/1)
      |> Enum.map(&Crawly.Utils.request_from_url/1)

    # Create item (for pages where items exists)
    item = %{
      title: product_title(document),
      sku: product_sku(document),
      price: product_price(document),
      image: product_image(document)
    }

    %Crawly.ParsedItem{:items => [item], :requests => requests}
  end

  defp build_absolute_url(url), do: URI.merge(base_url(), url) |> to_string()

  defp product_title(document) do
    document
    |> Floki.find("div.page-title h1")
    |> Floki.text()
  end

  defp product_sku(document) do
    document
    |> Floki.find(".product-header-heading span")
    |> Floki.text()
  end

  defp product_price(document) do
    document
    |> Floki.find(".price-value [itemprop=priceCurrency]")
    |> Floki.text()
  end

  defp product_image(document) do
    links =
      document
      |> Floki.find("a.rsImg")
      |> Floki.attribute("href")

    do_product_image(links)
  end

  defp do_product_image([]), do: nil
  defp do_product_image([link|_]) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(link)

    local_file_link = "/tmp/homebase_" <> Path.basename(link)

    File.write!(local_file_link, body)
    local_file_link
  end
end
