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

  def render_image_content(source) do
    case source["extra"]["imageFiles"] do
      [image_file] ->
        src = Routes.image_path(Endpoint, :show, image_file: image_file)
        """
        <div class="image-single">
        <img id="image-content" class="image-content" src="#{src}" alt="Content" phx-hook="ContentLoaded"/>
        </div>
        """
      image_files ->
        imgs = Enum.map(image_files, fn image_file ->
        src = Routes.image_path(Endpoint, :show, image_file: image_file)
        """
        <img class="image-content" src="#{src}" alt="Content"/>
        """
      end) |> Enum.concat('\n')
        """
        <div id="image-content" class="image-grid" phx-hook="ContentLoadedText">
        #{imgs}
        </div>
        """
    end
  end

  def render_freeform_content(source) do
      """
      <div id="content" class="text-container">
      <h1 id="content-text" class="text-content" phx-hook="ContentLoadedText"/>#{source["data"]}</h1>
      </div>
      """
  end
end
