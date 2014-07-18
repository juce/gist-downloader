-- Gist

function setup()
    url = ""
    parameter.action("Paste gist url", function()
        url = pasterboard.text
        parameter.action("Download", function()
            http.request(url, function(data)
                saveProjectTab("Main", data)
                msg = "Success!"
                parameter.action("Quit", function()
                    close()
                end)
            end, function(err)
                msg = err
                parameter.action("Quit", function()
                    close()
                end)
            end)
    end)
end

function draw()
    background(0, 0, 0)
    fill(128, 128, 128)
    textWrapWidth(WIDTH-100)
    fontSize(40)
    if msg then
        text(msg, WIDTH/2, HEIGHT/2)
    else
        text(url, WIDTH/2, HEIGHT/2)
    end
end

