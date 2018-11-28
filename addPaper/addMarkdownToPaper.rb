#!/usr/bin/ruby

require 'faraday'
require 'json'


def doc_list(aReq)
     aReq.url '/2/paper/docs/list'
     aReq.headers['Content-Type'] = 'application/json'
     aReq.body = "{\"filter_by\": \"docs_created\",\"sort_by\": \"modified\",\"sort_order\": \"descending\",\"limit\": 100}"
end #def

def dir_info(aReq, doc_id)
     aReq.url '/2/paper/docs/get_folder_info'
     aReq.headers['Content-Type'] = 'application/json'
     aReq.body = "{\"doc_id\": \"" + doc_id + "\"}"
end #def

def post_md(aReq, mdFile)
    aReq.url '/2/paper/docs/create'
    aReq.headers['Dropbox-API-Arg'] = { 'import_format': 'markdown' }.to_json
    aReq.headers['Content-Type'] = 'application/octet-stream'
    aReq.body = File.binread(mdFile)
end #def

def post_html(aReq, mdFile)
    aReq.url '/2/paper/docs/create'
    aReq.headers['Dropbox-API-Arg'] = { 'import_format': 'html' }.to_json
    aReq.headers['Content-Type'] = 'application/octet-stream'
    aReq.body = File.binread(mdFile)
end #def

conn = Faraday.new(url: 'https://api.dropboxapi.com') do |faraday|
    faraday.authorization :Bearer, 'WL1_ZargfHEAAAAAAAPUzyiz3lIGPAWYNSNSQG88vDz41jkTm0FlmiYhyoQLtsav'
    faraday.response :logger
    faraday.adapter Faraday.default_adapter
end

res = conn.post do |req|
        if ARGV[0] == 'list' then
                doc_list(req)
        elsif ARGV[0] =='md' then
                post_md(req, ARGV[1])
        elsif ARGV[0] =='html' then
                post_html(req, ARGV[1])
        elsif ARGV[0] =='dir' then
                dir_info(req, ARGV[1])
        end #if 
end

puts res.body


# curl -X POST https://api.dropboxapi.com/2/paper/docs/create \
#     --header "Authorization: Bearer WL1_ZargfHEAAAAAAAPUzyiz3lIGPAWYNSNSQG88vDz41jkTm0FlmiYhyoQLtsav" \
#     --header "Dropbox-API-Arg: {\"import_format\": \"markdown\",\"parent_folder_id\": \"e.gGYT6HSafpMej9bUv306GarglI7GGeAM3yvfZvXHO9u4mV\"}" \
#     --header "Content-Type: application/octet-stream" \
#     --data-binary @local_file.txt
# {
#     "import_format": "html",
#     "parent_folder_id": "e.gGYT6HSafpMej9bUv306GarglI7GGeAM3yvfZvXHO9u4mV"
# }


# res = conn.post do |req|
#     req.url '/2/paper/docs/list'
#     req.headers['Content-Type'] = 'application/json'
#     req.body = "{\"filter_by\": \"docs_created\",\"sort_by\": \"modified\",\"sort_order\": \"descending\",\"limit\": 100}"
# end
# 
# puts res.body
#
# curl -X POST https://api.dropboxapi.com/2/paper/docs/list \
#     --header "Authorization: Bearer WL1_ZargfHEAAAAAAAPUzyiz3lIGPAWYNSNSQG88vDz41jkTm0FlmiYhyoQLtsav" \
#     --header "Content-Type: application/json" \
#     --data "{\"filter_by\": \"docs_created\",\"sort_by\": \"modified\",\"sort_order\": \"descending\",\"limit\": 100}"


# curl -X POST https://api.dropboxapi.com/2/paper/docs/create \
#     --header "Authorization: Bearer WL1_ZargfHEAAAAAAAPUzyiz3lIGPAWYNSNSQG88vDz41jkTm0FlmiYhyoQLtsav" \
#     --header "Dropbox-API-Arg: {\"import_format\": \"markdown\"}" \
#     --header "Content-Type: application/octet-stream" \
#     --data-binary @local_file.txt

# curl -X POST https://api.dropboxapi.com/2/paper/docs/get_folder_info \
#     --header "Authorization: Bearer WL1_ZargfHEAAAAAAAPUzyiz3lIGPAWYNSNSQG88vDz41jkTm0FlmiYhyoQLtsav" \
#     --header "Content-Type: application/json" \
#     --data "{\"doc_id\": \"uaSvRuxvnkFa12PTkBv5q\"}"