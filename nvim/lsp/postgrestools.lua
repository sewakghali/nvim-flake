local get_env = function(name)
	return os.getenv(name) or nil
end

return {
	cmd = { "postgrestools" },
	filetypes = {
		"sql",
	},

	settings = {
		["$schema"] = "https://github.com/supabase-community/postgres-language-server/blob/a621abcc66bfa300cbfb6d115b28d4027d629df0/docs/schema.json",
		-- "vcs": {
		--   "enabled": false,
		--   "clientKind": "git",
		--   "useIgnoreFile": false
		-- },
		-- "files": {
		--   "ignore": []
		-- },
		linter = {
			enabled = true,
			rules = {
				recommended = true,
			},
		},
		db = {
			host = get_env("PG_HOST"),
			port = tonumber(get_env("PG_PORT") or "5432"),
			username = get_env("PG_USER"),
			password = get_env("PG_PASSWORD"),
			database = get_env("PG_DB"),
			connTimeoutSecs = 10,
			allowStatementExecutionsAgainst = { "postgres/*", "localhost/*" },
		},
	},
}
