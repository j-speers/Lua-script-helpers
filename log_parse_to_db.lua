--=================================Vex Custom Func=======================================

local luasql = require "luasql.mysql"
local socket = require "socket"  -- Required for sleep functionality

-- Write to log file
function mylogfunc(text)
    local outstr = os.date("%Y/%m/%d %H:%M:%S") .. " [" .. "game__GetWorldTag()" .. "] " .. text .. "\n"
    local file = io.open("hwidlog.txt", "a")
    file:write(outstr)
    file:close()
    io.write(outstr)
end

-- Function to insert a new row into the log_hwid table
function WriteHwidToDB(roleid, hw)
    mylogfunc("Entered WriteHwidToDB roleid = " .. roleid .. " hwid = " .. hw)

    -- Database connection parameters
    local db_user = ""**********""
    local db_password = "**********"
    local db_name = "pw"
    local db_host = "localhost"
    local db_port = 3306

    -- Creating a MySQL environment
    local env = luasql.mysql()
    mylogfunc("Setup DB connection")

    -- Connecting to the database
    local conn = env:connect(db_name, db_user, db_password, db_host, db_port)

    -- Check if the connection was successful
    if not conn then
        mylogfunc("Vex: Database connection failed")
        return
    end

    -- SQL query to insert a new row
    local insert_sql = string.format(
        "INSERT INTO log_hwid (role_id1, role_hwid, last_login) VALUES (%d, '%s', NOW())",
        tonumber(roleid), hw
    )
    mylogfunc("insert_sql = " .. insert_sql)

    -- Execute the insert query
    local success, err = conn:execute(insert_sql)

    -- Check for errors in execution
    if not success then
        mylogfunc("Vex: SQL insert execution failed: " .. err)
    else
        mylogfunc("Vex: Successfully inserted role_id1 = " .. tonumber(roleid) .. ", role_hwid = " .. hw)
    end

    -- SQL query to update role_name1 based on log_main
    local update_sql = string.format(
        "UPDATE log_hwid h " ..
        "JOIN log_main m ON h.role_id1 = m.role_id1 " ..
        "SET h.role_name1 = m.role_name1 " ..
        "WHERE h.role_id1 = %d", tonumber(roleid))
    mylogfunc("update_sql = " .. update_sql)

    -- Execute the update query
    success, err = conn:execute(update_sql)

    -- Check for errors in execution
    if not success then
        mylogfunc("Vex: SQL update execution failed: " .. err)
    else
        mylogfunc("Vex: Successfully updated role_name1 for role_id1 = " .. tonumber(roleid))
    end

    -- Closing the connection
    conn:close()
    env:close()
end

-- Function to process a line and extract roleid and hwid
function ProcessLine(line)
    local roleid, hwid = line:match("Role_ID=(%d+)%s+Hardware_ID=(-?%d+)")
    if roleid and hwid then
        mylogfunc("Vex: Found roleid = " .. roleid .. ", hwid = " .. hwid)
        WriteHwidToDB(roleid, hwid)
    end
end

-- Function to continuously monitor the log file
function MonitorLogFile()
    local filename = "/home/logs/world2.log"
    local file = io.open(filename, "r")
    if not file then
        mylogfunc("Vex: Failed to open " .. filename)
        return
    end

    -- Move to the end of the file
    file:seek("end")

    while true do
        local line = file:read("*line")
        if line then
            ProcessLine(line)
        else
            -- No new line found, sleep for a short duration before retrying
            socket.sleep(1)  -- Sleep for 1 second
            file:seek("cur", 0)  -- Ensure we stay at the end of the file
        end
    end

    file:close()
end

-- Start monitoring the log file
MonitorLogFile()
