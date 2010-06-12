require 'date'
require 'fileutils'
include FileUtils


module BlogHelper

  class Article
    attr_accessor :title, :date, :url, :abstract, :tags
  end

  class Tag
    attr_accessor :title, :rate, :articles

    def initialize title, article
      @title = title
      @rate = 1
      @articles = [article]
    end
  end


  def blog articles_dir = "articles"
    dir = File.join(Dir.getwd, 'src', 'pages', articles_dir)
    articles = []
    Dir["#{dir}/*.haml"].each do |f|
      if f =~ /([0-9]{14})_(.+)\.haml/
        data = File.read(f)
        article = Article.new
        article.url = articles_dir + "/#{$1}_#{$2}.html"
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
    tags = {}

    blog do |artcl|
      artcl.tags.each do |tag|
        if tags.has_key? tag
          tags[tag].articles << artcl
          tags[tag].rate += 1 if tags.has_key? tag
        else
          tags[tag] = Tag.new tag, artcl
        end
      end
    end
    
    rates = tags.values.collect {|tag| tag.rate}
    max = rates.max
    tags.values.shuffle.each do |tag|
      tag.rate = (tag.rate/max*6).ceil
      yield tag
    end
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

