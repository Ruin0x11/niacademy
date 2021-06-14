defmodule Niacademy.Session do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Niacademy.Repo
  alias Niacademy.Session

  schema "sessions" do
    field :regimen_id, :string
    field :position, :integer
    field :activities, :string
    field :categories, {:array, :string}, default: []
    field :show_controls, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:regimen_id, :position, :activities, :categories, :show_controls])
    |> validate_required([:regimen_id, :position, :activities, :categories, :show_controls])
  end

  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list()
      [%Session{}, ...]

  """
  def list do
    Repo.all(Session)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get!(123)
      %Session{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Session, id)

  @doc """
  Creates a session.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Session{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a session.

  ## Examples

      iex> update(session, %{field: new_value})
      {:ok, %Session{}}

      iex> update(session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a session.

  ## Examples

      iex> delete(session)
      {:ok, %Session{}}

      iex> delete(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session changes.

  ## Examples

      iex> change(session)
      %Ecto.Changeset{data: %Session{}}

  """
  def change(%Session{} = session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end
end
