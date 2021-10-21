data =
  [__DIR__, "rushing.json"]
  |> Path.join()
  |> File.read!()
  |> Jason.decode!()

IO.puts("Found #{length(data)} seed entries.")
