defmodule NiacademyWeb.StartView do
  use NiacademyWeb, :view
  use Timex

  defp split_seconds(seconds) do
    h = div(seconds, 60 * 60)
    m =
      seconds
      |> rem(60 * 60)
      |> div(60)
    s =
      seconds
      |> rem(60 * 60)
      |> rem(60)

    {h, m, s}
  end

  defp pad_int(int, padding \\ 2) do
    int
    |> Integer.to_string()
    |> String.pad_leading(padding, "0")
  end

  def format_time(seconds, class) do
    with {h, m, s} <- split_seconds(seconds) do
      """
      <span class="#{class} time-display">
         <span class="hours">#{pad_int(h)}:</span>
         <span class="minutes">#{pad_int(m)}:</span>
         <span class="seconds">#{pad_int(s)}</span>
      </span>
      """ |> raw()
    end
  end

  def link_class(type) do
    "#{type}-link"
  end

  def format_project_type(type) do
    class = "#{type}-type"
    text = case type do
             :tutorial -> "Tutorial"
             :free -> "Free"
             _ -> "(Unknown)"
           end

    """
    <div class="project-type">Project: <span class="#{class}">#{text}</class></div>"
    """ |> raw()
  end
end
