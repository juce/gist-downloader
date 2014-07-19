-- Gist downloader

local function iter(obj)
    if not obj.name then
        return
    end
    local data = obj.data
    local name, pos = obj.name, obj.pos
    local s, e, next = data:find("\n[-][-]# ([%w_]+)[^\n]*\n.", pos)
    obj.name, obj.pos = next, e
    return name, data:sub(pos, s)
end

function tabs(data)
    local s, e, name = data:find("^%s*[-][-]# ([%w_]+)[^\n]*\n.")
    local obj = {
        pos = e or 1, 
        name = name or "Main",
        data = data,
    }
    return iter, obj
end

function setup()
    url, c = "", color(203, 209, 60, 255)
    parameter.action("Paste gist url", function()
        url = pasteboard.text
        parameter.action("Download", function()
            if not url:match("/raw") then
                url = url .. "/raw"
            end
            http.request(url, function(data)
                msg = "Downloaded. Splitting into tabs ..."
                tween.delay(1, function()
                    for tabname,tabdata in tabs(data) do
                        saveProjectTab(tabname, tabdata)
                    end
                    msg, c = "Success!", color(96, 181, 47, 255)
                    parameter.action("Quit", function()
                        close()
                    end)
                end)
            end, function(err)
                msg, c = err, color(177, 49, 49, 255)
                parameter.action("Quit", function()
                    close()
                end)
            end)
        end)
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

