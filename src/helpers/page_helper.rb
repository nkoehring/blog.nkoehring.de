require 'date'
require 'fileutils'
require 'pathname'

include BlogHelper

module PageHelper
  def create_index_pages
    layout = @staticmatic.source_for_layout
    n = (all_articles.length.to_f / $articles_per_page).ceil

    (2..n).each do |i|
      content = partial('index', :locals => { :page => i, :pages => n })
      File.open("site/index#{i}.html", 'w') do |f|
        f.write @staticmatic.generate_html_from_template_source(layout) { content }
      end
    end
    [n, all_articles.length, $articles_per_page]
  end
end
 
