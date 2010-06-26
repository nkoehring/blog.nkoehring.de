require 'date'
require 'fileutils'
require 'pathname'


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


  def current? page
    current_page == page ? "current" : nil
  end


  def menu_page?
    menu_pages = %w(/index.html /tags.html /about.html)
    menu_pages.index current_page
  end

  
  def tags_page?
    current_page =~ /\/tags\/.*\.html/
  end

  
  def parent_url
    parent = "/"
    menu_page? and parent = "http://nkoehring.de/"
    tags_page? and parent = "/tags.html"
  end

  def all_articles
    dir = File.join(Dir.getwd, 'src', 'pages', $articles_dir)
    articles = []
    Dir["#{dir}/*.haml"].each do |f|
      if f =~ /([0-9]{14})_(.+)\.haml/
        data = File.read(f)
        article = Article.new
        article.url = $articles_dir + "/#{$1}_#{$2}.html"
        article.date = DateTime.parse $1
        article.title = extract_instance_variable(data, :title)
        article.abstract = extract_instance_variable(data, :abstract)
        article.tags = extract_instance_variable(data, :tags)
        articles << article
      end
    end
    articles
  end


  def blog page = :all
    articles = all_articles
    if page == :all
      a, b = 0, articles.length
    else
      page = 1 if page < 1
      a = $articles_per_page * (page - 1)
      b = a + $articles_per_page
    end

    articles = all_articles.sort_by{ |item| item.date }.reverse[a...b]
    articles.each{ |item| yield item }
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
    max = rates.max.to_f
    tags.values.shuffle.each do |tag|
      tag.rate = (tag.rate/max*6).ceil
      yield tag
    end
  end


  def insert_picture uri, name
    dir = Pathname("site/images/") + Date.today.strftime("%Y%m%d")
    FileUtils.mkdir_p dir

    unless File.exist? dir+name
      if uri =~ /^[a-z]{3,5}:\/{2}.*\..{2,5}\//
        # it's an URL, so we need to download the picture first
        return nil unless system "wget #{uri} -O #{dir+name}"
      else
        # it's a local file, so we need to copy it into the blog images directory
        return nil unless File.exist? uri
        FileUtils.cp(uri, dir+name)
      end
    end

    return nil unless system "src/helpers/create_thumbs.sh #{dir+name}"

    [Date.today.strftime("%Y%m%d"), name]
  end


  private
  def extract_instance_variable data, var
    if data =~ /@#{var} ?= ?(.+)/
      eval($1)
    end
  end
end

