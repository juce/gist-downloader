-- Gist

function setup()
    url, c = "", color(203, 209, 60, 255)
    parameter.action("Paste gist url", function()
        url = pasteboard.text
        parameter.action("Download", function()
            if not url:match("/raw") then
                url = url .. "/raw"
            end
            http.request(url, function(data)
                saveProjectTab("Main", data)
                msg, c = "Success!", color(96, 181, 47, 255)
                parameter.action("Quit", function()
                    close()
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

