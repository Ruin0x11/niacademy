defmodule NiacademyWeb.ActivityView do
  use NiacademyWeb, :view

  def render_session(session) do
    activity = session.activities |> Enum.at(session.position) |> Map.get("activity")

    content = render_content(session, activity)
    description = render_description(session, activity)

    """
    <div id="content">
    <div class="main">
    #{content}
    </div>
    #{description}
    </div>
    """ |> raw()
  end

  def render_content(session, activity) do
    IO.inspect(activity)
    source = activity["source"]

    case source["type"] do
      x when x in ["Custom", "Categories", "File"] -> render_image_content(session, source)
      "Freeform" -> render_freeform_content(session, source)
      _ -> "<div>(error)</div>"
    end
  end

  def render_description(_session, activity) do
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

  def render_image_content(_session, source) do
    image_file = source["extra"]["imageFile"]
    src = Routes.image_path(Endpoint, :show, image_file: image_file)

    """
    <img class="image-content" src="#{src}" alt="Content"/>
    """
  end

  def render_freeform_content(_session, source) do
    """
    <h1>#{source["data"]}</h1>
    """
  end
end
