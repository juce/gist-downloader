-- Gist uploader/downloader
-- v2.0 by juce, Jmv38 and HyroVitalyProtago

local function iter(obj)
    if not obj.name then
        return
    end
    local data = obj.data
    local name, pos = obj.name, obj.pos
    local s, e, next = data:find("\n[-][-]# ([%w_]+)[^\n]*\n.", pos)
    obj.name, obj.pos = next, e
    return name, data:sub(pos, s and s-1 or nil)
end

local function tabs(data)
    local s, e, name = data:find("^%s*[-][-]# ([%w_]+)[^\n]*\n.")
    local obj = {
        pos = e or 1, 
        name = name or "Main",
        data = data,
    }
    return iter, obj
end

function saveLink(link)
    local name = "myGists"
    local tab = ""
    for i,v in ipairs(listProjectTabs()) do
        if name == v then tab = readProjectTab(v) end
    end
    tab = tab .. "-- " .. link .. "  -- project: \n"
    saveProjectTab(name,tab)
end

function getDkjson(cb)
    if not readGlobalData("Dkjson") then
        status, msg = "", "Downloading dkjson..."
        http.request("https://gist.githubusercontent.com/HyroVitalyProtago/5965767/raw/73facb82eda4c92393c51535f8dd08728e25555d/Dkjson.lua",
            function(data)
                saveGlobalData("Dkjson", data)
                msg = ""
                cb()
            end)
    else
        cb()
    end
end

function setup()
    colors = {
        red = color(177, 49, 49, 255),
        yellow = color(203, 209, 60, 255),
        green = color(96, 181, 47, 255)
    }
    url, c = "", colors.yellow
    
    -- load dkjson library (download, if necessary)
    getDkjson(function()
        assert(loadstring(readGlobalData("Dkjson")))()
        assert(json.encode)
        assert(json.decode)
        -- display button menu
        menu()
    end)
end

function menu()
    -- Download gist via link in pasteboard
    parameter.action("DOWNLOAD: Paste gist link", function()
        url = pasteboard.text
        parameter.clear()
        parameter.action("Download gist", function()
            if not url:match("/raw") then
                url = url .. "/raw"
            end
            http.request(url, function(data)
                msg = "Downloaded. Splitting into tabs ..."
                tween.delay(1, function()
                    saveProjectTab("myGists", nil)
                    for tabname,tabdata in tabs(data) do
                        saveProjectTab(tabname, tabdata)
                    end
                    msg, c = "Success!", colors.green
                    parameter.action("Quit", function()
                        close()
                    end)
                end)
            end, function(err)
                msg, c = err, colors.red
                parameter.action("Quit", function()
                    close()
                end)
            end)
        end)
    end)

    -- Upload data from pasteboard to gist
    parameter.action("UPLOAD: Create new gist", function()
        local data = {
            description = 'Gists Codea Upload',
            public = true,
            files = {
                ['Project.lua'] = {
                    content = pasteboard.text
                }
            }
        }
        parameter.clear()
        msg = "Starting upload ..."
        http.request('https://api.github.com/gists', function(res)
            local link = "https://gist.github.com/anonymous/" .. json.decode(res).id
            msg, c = "Success!\n" .. link, colors.green
            pasteboard.copy(link)
            saveLink(link)
            print("link copied in the pasteboard and in tab myGists")
            parameter.action("View gist", function()
                openURL(link, true)
            end)
            parameter.action("Quit", function()
                close()
            end)
        end, function(err)
            msg, c = err, colors.red
            parameter.action("Quit", function()
                close()
            end)
        end,
        { method = 'POST', data = json.encode(data) })
    end)    
end

function draw()
    background(18, 18, 19, 255)
    fill(c)
    textWrapWidth(WIDTH-100)
    fontSize(35)
    if msg then
        text(msg, WIDTH/2, HEIGHT/2)
    else
        text(url, WIDTH/2, HEIGHT/2)
    end
end
