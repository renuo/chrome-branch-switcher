require 'webrick'
require 'json'

# Create the server
server = WEBrick::HTTPServer.new(
  Port: 64014,
  BindAddress: '0.0.0.0',
  AccessLog: [],
  Logger: WEBrick::Log.new('/dev/null') # Disable logging
)

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
        result = `cd #{home}/#{project_slug} && git checkout #{branch}`
        res.status = 200
        res['Content-Type'] = 'application/json'
        res['Access-Control-Allow-Origin'] = '*'
        res.body = { status: 'success', message: result }.to_json
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
