defmodule Niacademy.StateTest do
  use Niacademy.DataCase

  alias Niacademy.State

  describe "sessions" do
    alias Niacademy.State.Session

    @valid_attrs %{data: "some data"}
    @update_attrs %{data: "some updated data"}
    @invalid_attrs %{data: nil}

    def session_fixture(attrs \\ %{}) do
      {:ok, session} =
        attrs
        |> Enum.into(@valid_attrs)
        |> State.create_session()

      session
    end

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert State.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert State.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      assert {:ok, %Session{} = session} = State.create_session(@valid_attrs)
      assert session.data == "some data"
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = State.create_session(@invalid_attrs)
    end

    test "update_session/2 with valid data updates the session" do
      session = session_fixture()
      assert {:ok, %Session{} = session} = State.update_session(session, @update_attrs)
      assert session.data == "some updated data"
    end

    test "update_session/2 with invalid data returns error changeset" do
      session = session_fixture()
      assert {:error, %Ecto.Changeset{}} = State.update_session(session, @invalid_attrs)
      assert session == State.get_session!(session.id)
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = State.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> State.get_session!(session.id) end
    end

    test "change_session/1 returns a session changeset" do
      session = session_fixture()
      assert %Ecto.Changeset{} = State.change_session(session)
    end
  end
end
