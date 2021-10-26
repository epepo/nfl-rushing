alias NFLRushing.{Repo, Importer}

[__DIR__, "rushing.json"]
|> Path.join()
|> File.read!()
|> Jason.decode!()
|> Enum.map(&Importer.parse_entry!/1)
|> Enum.each(&Repo.insert!(&1, on_conflict: :nothing))
