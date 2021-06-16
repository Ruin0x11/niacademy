defmodule Niacademy.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Niacademy.Repo
  alias Niacademy.User

  schema "users" do
    field :preset_position_tutorial, :integer, default: 0
    field :preset_position_free, :integer, default: 0
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:preset_position_tutorial, :preset_position_free, :username])
    |> validate_required([:preset_position_tutorial, :preset_position_free, :username])
    |> unique_constraint(:username)
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list()
      [%User{}, ...]

  """
  def list do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get!(123)
      %User{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create(%{field: value})
      {:ok, %User{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update(user, %{field: new_value})
      {:ok, %User{}}

      iex> update(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete(user)
      {:ok, %User{}}

      iex> delete(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def get_preset_position_key(type) do
    case type do
      :tutorial -> :preset_position_tutorial
      :free -> :preset_position_free
      _ -> raise "Unknown preset type #{type}"
    end
  end

  def get_preset_position(%User{} = user, type) do
    key = get_preset_position_key(type)
    get_in(user, [Access.key!(key)])
  end
end
