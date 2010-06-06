require 'date'
require 'fileutils'
include FileUtils


module BlogHelper

  class Article
    attr_accessor :title, :date, :permalink, :abstract, :tags
  end


  def blog articles_dir = "articles"
    dir = File.join(Dir.getwd, 'src', 'pages', articles_dir)
    articles = []
    Dir["#{dir}/*.haml"].each do |f|
      if f =~ /([0-9]{14})_(.+)\.haml/
        data = File.read(f)
        article = Article.new
        article.permalink = articles_dir + "/#{$1}_#{$2}.html"
        article.date = DateTime.parse $1
        article.title = extract_instance_variable(data, :title)
        article.abstract = extract_instance_variable(data, :abstract)
        article.tags = extract_instance_variable(data, :tags)
        articles << article
      end
    end
    articles.sort_by { |item| item.date }.reverse_each { |item| yield item }
  end


  def tags
    tags = []
    rates = {}

    blog do |artcl|
      tags << artcl.tags
    end
    
    tags.flatten.each do |tag|
      rates[tag] = 0 unless rates.has_key? tag
      rates[tag] += 1
    end

    max = rates.values.max.to_f
    rates.collect { |tag, count| yield [tag, (count/max*6).ceil] }
  end


  def random_tags
    tags = {
      'lorem' => 1,
      'ipsum' => 2,
      'sit' => 3,
      'dolor' => 4,
      'amet' => 5,
      'consetetur' => 6
    }

    keys = tags.keys.collect {|x| [x] * ((rand*15)+1) }
    keys.flatten.shuffle.collect { |x| yield [x, tags[x]] }
  end


  private
  def extract_instance_variable data, var
    if data =~ /@#{var} ?= ?(.+)/
      eval($1)
    end
  end
end

