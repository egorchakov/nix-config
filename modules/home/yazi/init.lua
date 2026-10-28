return function(hosts)
	require("full-border"):setup({
		set = "plain",
	})
	require("git"):setup()
	require("duckdb"):setup({
		mode = "standard",
		cache_size = 100,
	})

	local hostname = (ya.host_name() or "localhost"):match("^[^.]+")
	local pending = {}
	if #rt.args.entries == 0 then
		ya.emit("tab_rename", { hostname })
		for _, host in ipairs(hosts) do
			if host ~= hostname then
				pending[host] = true
				ya.emit("tab_create", {})
				ya.emit("tab_rename", { host })
			end
		end
		ya.emit("tab_switch", { 0 })
	end

	ps.sub("tab", function(event)
		local tab = cx.active
		if tab.id.value ~= event.idx or not pending[tab.name] then
			return
		end
		local host = tab.name
		pending[host] = nil
		ya.emit("cd", { "sftp://" .. host, tab = event.idx })
	end)

	ps.sub("cd", function(event)
		for _, tab in ipairs(cx.tabs) do
			if tab.id.value == event.tab and not pending[tab.name] then
				local spec = tab.current.cwd.spec
				ya.emit("tab_rename", { spec.scheme == "sftp" and spec.domain or hostname, tab = event.tab })
				break
			end
		end
	end)
end
