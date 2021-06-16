# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Niacademy.Repo.insert!(%Niacademy.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Niacademy.Repo.insert!(%Niacademy.User{username: "nonbirithm", preset_position: 0})
