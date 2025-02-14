require 'webrick'
require 'json'

# Create the server
server = WEBrick::HTTPServer.new(
  Port: 64014,
  BindAddress: 'localhost',
  AccessLog: [],
  Logger: WEBrick::Log.new('/dev/null') # Disable logging
)

puts "Server started on port #{server.config[:Port]}. Ready and listening."

# Define the branch switching handler
server.mount_proc '/switch-branch' do |req, res|
  if req.request_method == 'OPTIONS'
    res.status = 200
    res['Access-Control-Allow-Origin'] = '*'
    res['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
    res['Access-Control-Allow-Headers'] = 'Content-Type'
    next
  end

  if req.request_method == 'POST'
    begin
      data = JSON.parse(req.body)
      branch = data['branch']
      project_slug = data['projectSlug']
      home = data['home']

      if branch && project_slug
        command = "cd #{home}/#{project_slug} && git checkout #{branch}"
        puts "Executing command: #{command}"
        output = `#{command}`
        result=$?.success?
        puts "Switch result: #{output}. Result: #{result}"
        res.status = 200
        res['Content-Type'] = 'application/json'
        res['Access-Control-Allow-Origin'] = '*'
        res.body = { status: 'success', message: output }.to_json
      else
        res.status = 400
        res['Content-Type'] = 'application/json'
        res['Access-Control-Allow-Origin'] = '*'
        res.body = { status: 'error', message: 'Invalid branch or project slug' }.to_json
      end
    rescue => e
      res.status = 500
      res['Content-Type'] = 'application/json'
      res['Access-Control-Allow-Origin'] = '*'
      res.body = { status: 'error', message: e.message }.to_json
    end
  else
    res.status = 405
    res['Allow'] = 'POST, OPTIONS'
  end
end

# Start the server
trap 'INT' do server.shutdown end
server.start
