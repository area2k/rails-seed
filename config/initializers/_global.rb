CONFIG_DIR = Rails.root.join('config/global').to_s

Global.configure do |config|
  Global.backend(:filesystem, environment: Rails.env.to_s, path: CONFIG_DIR)
end
