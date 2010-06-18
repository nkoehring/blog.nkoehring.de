require 'rubygems'
require 'redcloth'
require 'coderay'
require 'redclothcoderay'


configuration.preview_server_port = 3010
configuration.preview_server_host = "0.0.0.0"

configuration.sass_options = {
    :style => :compact
}

configuration.haml_options = {
      :format => :html5
}

RedclothCoderay.coderay_options :line_numbers => :table

