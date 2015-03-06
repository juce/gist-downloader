-- Gist uploader/downloader
-- v3.0 by juce, Jmv38 and HyroVitalyProtago

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
        http.request("https://gist.githubusercontent.com" ..
            "/HyroVitalyProtago/5965767/raw/" ..
            "73facb82eda4c92393c51535f8dd08728e25555d/Dkjson.lua",
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
    parameter.action("DOWNLOAD: Paste link", function()
        local url = pasteboard.text or ""
        url = url:match("[^%s]+")
        msg = #url>256 and url:sub(1,256).."..." or url
        parameter.clear()
        parameter.action("Download gist", function()
            if not url:match("/raw") then
                url = url .. "/raw"
            end
            msg = "Downloading ..."
            http.request(url, function(data)
                pasteboard.copy(data)
                msg = "Success!\nDownloaded and copied to pasteboard."
                print("You can now close this project, then " ..
                      "long-press 'Add New Project' button, and then " ..
                      "choose 'Paste Into Project'")
                c = colors.green
                parameter.clear()
            end, function(err)
                msg, c = err, colors.red
                parameter.clear()
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
        msg = "Uploading ..."
        http.request('https://api.github.com/gists', function(res)
            local link = "https://gist.github.com/anonymous/" .. json.decode(res).id
            msg, c = "Success!\n" .. link, colors.green
            pasteboard.copy(link)
            saveLink(link)
            print("link copied in the pasteboard and in tab myGists")
            parameter.action("View gist", function()
                openURL(link, true)
            end)
        end, function(err)
            msg, c = err, colors.red
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
