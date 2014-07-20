-- Gist uploader/downloader
-- v1.0 by juce

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

function setup()
    colors = {
        red = color(177, 49, 49, 255),
        yellow = color(203, 209, 60, 255),
        green = color(96, 181, 47, 255)
    }
    url, c = "", colors.yellow
    
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
        data = pasteboard.text
        parameter.clear()
        http.request('http://gist-proxy.aws.mapote.com:8888/gists', function(link)
            msg, c = "Success!\n" .. link, colors.green
            parameter.action("Copy link", function()
                pasteboard.copy(link)
                parameter.action("Quit", function()
                    close()
                end)
            end)
        end, function(err)
            msg, c = err, colors.red
            parameter.action("Quit", function()
                close()
            end)
        end,
        { method = 'POST', data = data })
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
