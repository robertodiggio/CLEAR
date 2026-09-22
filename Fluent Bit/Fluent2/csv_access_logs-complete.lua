local SECONDS=30
local first_epoch=0
local host_table={}
local new_records = {}

function aggregate(tag, timestamp, record)

    local epoch_seconds = math.floor(timestamp)
    local host = record["host"]

    local ip = record["ip"]

    local method = record["method"]
    if method ~= "GET" and method ~= "POST" then
        method = "OTHER"
    end

    local status = record["status"]
    status = status:sub(1, 2) .. "x"

    if first_epoch==0 then
        if epoch_seconds%100 < SECONDS then
            first_epoch = epoch_seconds - epoch_seconds%100
        else
            first_epoch = epoch_seconds - epoch_seconds%100 + SECONDS
        end
    end

    local interval_of_time = epoch_seconds - first_epoch

    if interval_of_time>SECONDS then

        for host, data_host in pairs(host_table) do

            for epoch, data_epoch in pairs(data_host) do
                
                for method, data_method in pairs(data_epoch) do
                    
                    for status, data_status in pairs(data_method) do

                        for ip, data_ip in pairs(data_status) do

                            local start_end = data_ip.time.start .. "-" .. data_ip.time.last

                            local new_record = {
                                host = host,
                                ip = ip,
                                interval_data_time = start_end,
                                status = status,
                                method = method,
                                request = data_ip.request,
                                bytes = data_ip.bytes
                            }

                            table.insert(new_records, new_record)

                        end

                    end

                end

            end

        end

        host_table = {}
        first_epoch = first_epoch + SECONDS

    end

    if host_table[host]==nil then
        host_table[host] = {}
    end

    if host_table[host][first_epoch]==nil then
        host_table[host][first_epoch] = {}
    end

    if host_table[host][first_epoch][method]==nil then
        host_table[host][first_epoch][method] = {}
    end

    if host_table[host][first_epoch][method][status]==nil then
        host_table[host][first_epoch][method][status] = {}
    end

    if host_table[host][first_epoch][method][status][ip]==nil then
        host_table[host][first_epoch][method][status][ip] = {
            request = 0,
            bytes = 0,
            time = {
                start = "",
                last = ""
            }
        }
    end

    host_table[host][first_epoch][method][status][ip].request = host_table[host][first_epoch][method][status][ip].request + 1
    host_table[host][first_epoch][method][status][ip].bytes = host_table[host][first_epoch][method][status][ip].bytes + tonumber(record["bytes"])
    host_table[host][first_epoch][method][status][ip].time.last = record["data"]
    if host_table[host][first_epoch][method][status][ip].time.start == "" then
        host_table[host][first_epoch][method][status][ip].time.start = record["data"]
    end

    if interval_of_time>SECONDS then
        local records_to_send = new_records
        new_records = {}
        return 2, timestamp, records_to_send --invio le righe modificate
    else
        return -1, timestamp, record --escludo le righe dei record
    end
end