defmodule NiacademyWeb.ActivityView do
  use NiacademyWeb, :view

  def render_activity(activity) do
    content = render_content(activity)
    description = render_description(activity)

    """
    <div id="content">
    #{content}
    </div>
    #{description}
    """ |> raw()
  end

  def render_content(activity) do
    source = activity["source"]

    case source["type"] do
      x when x in ["Custom", "Categories", "File"] -> render_image_content(source)
      "Freeform" -> render_freeform_content(source)
      _ -> "<div>(error)</div>"
    end
  end

  def render_description(activity) do
    if activity["description"] do
      """
      <div class="description">
      #{activity["description"]}
      </div>
      """
    else
      ""
    end
  end

  defp render_single_image(image_file) do
    src = Routes.image_path(Endpoint, :show, image_file: image_file)
      """
      <img class="image-content" src="#{src}" alt="Content" phx-hook="ContentLoaded"/>
      """
  end

  def render_image_content(source) do
    case source["extra"]["imageFiles"] do
      [image_file] ->
        img = render_single_image(image_file)
        """
        <div id="image-content" class="image-single">
        #{img}
        </div>
        """
      image_files ->
        imgs = Enum.map(image_files, fn image_file -> render_single_image(image_file) end) |> Enum.concat('\n')
        """
        <div id="image-content" class="image-grid">
        #{imgs}
        </div>
        """
    end
  end

  def render_freeform_content(source) do
      """
      <h1 id="content" phx-hook="ContentLoadedText"/>#{source["data"]}</h1>
      """
  end
end
