require "jekyll"
require "liquid"
require "fileutils"

module Jekyll
    class RenderTimeTag < Liquid::Tag
  
      def initialize(tag_name, text, tokens)
        super
        @text = text
      end
  
      def render(context)
        "#{@text} #{Time.now}"
      end
    end
    class EmptyTag < Liquid::Tag
  
      def initialize(tag_name, text, tokens)
      end
    
      def render(context)
        ""
      end
    end

    class AssetImg < Liquid::Tag


      def initialize(tag_name, text, tokens)
        arr =  text.strip.split(" ")
        @img_name = arr[0]
        @img_width = nil
        if arr.count > 1
          @img_width = arr[1]
        end
      end
    
      def render(context)
        path = context['page']['path']
        

        dirPath0 = path[0...(path.length - 3)]
        pathComponent = dirPath0.split("/")
        dirPath = pathComponent[-1]
        
        base = $g_config['baseurl']
        link = "/pics/#{dirPath}/#{@img_name}"
        if base && base.length
          link = "#{base}/pics/#{dirPath}/#{@img_name}"
        end 

        if @img_width != nil
          return "<img src='#{link}' style='width:#{@img_width}px'>"
        else
          return "![](#{link})" 
        end

        
      end
    end

    class ImgLink < Liquid::Tag


      def initialize(tag_name, text, tokens)
        arr = text.strip.split(' ',2)
        if arr.count == 2 
          @img_name =  arr[1]
          @title =  arr[0]
        else
          @img_name =  arr[0]
          @title =  "img_link"
        end
      end
    
      def render(context)
        path = context['page']['path']
        

        dirPath0 = path[0...(path.length - 3)]
        pathComponent = dirPath0.split("/")
        dirPath = pathComponent[-1]
        
        base = $g_config['baseurl']
        link = "/pics/#{dirPath}/#{@img_name}"
        if base && base.length
          link = "#{base}/pics/#{dirPath}/#{@img_name}"
        end 
        return "[#{@title}](#{link})" 
      end
    end

    $g_title_link ||= {}
    LOADINGFLG = :LOADINGFLG

    class PostLink < Liquid::Tag
  
      def initialize(tag_name, text, tokens)
         @linkTitle = text.strip

        # page = Jekyll::sites[0].pages.find { |pg| 
        #   pg.name == @linkTitle 
        # }
       
      end
    
      def render(context)
        # puts 'zzaa',context['site']['posts'][1].data,"zz"
        url = $g_title_link[@linkTitle]
        if url == nil || url == LOADINGFLG
          $g_title_link[@linkTitle] = LOADINGFLG
          return "`#{@linkTitle} Not Found`"
        else 
          
          if $g_config["baseurl"] && $g_config["baseurl"].length > 0
            return "[#{@linkTitle}](#{$g_config["baseurl"]}/#{url})"
          else
            return "[#{@linkTitle}](#{url})"
          end
          
        end 
      end
    end

    class IncludeFile < Liquid::Tag
  
      def initialize(tag_name, text, tokens)
        rootPath0 = $g_config['include_file_path'] || 'assets'
        filePath0 = "#{rootPath0}/#{text}".strip()
        begin
          file = File.open(filePath0)
          @filecontent = file.read()
        rescue => exception
          puts exception
          @filecontent = "load file:#{text} failed"
          
        end
       
      end
    
      def render(context)
        return @filecontent
      end
    end

    
    
    class IncludeCode < Liquid::Tag
      @filecontent = ""
      def initialize(tag_name, text, tokens)

        rootPath = $g_config['code_root_path'] || 'static'
        if text.start_with?("/")
          filePath = "#{text}"[1..-1].strip()
        else
          filePath = "#{rootPath}/#{text}".strip()
        end
        filePath = File.expand_path(filePath)
        puts "--------- include code: #{filePath}"
        
        begin
          file = File.open(filePath)
          @filecontent = file.read()
        rescue => exception
          puts exception
          @filecontent = "load file:#{filePath} failed"
          
        end
        
      end
      
      def render(context)
        s="``````"
        r= <<EOF
#{s}
#{@filecontent}
#{s}
EOF
        return r
      end
    end


    class IncludeRaw < Liquid::Tag
      Syntax = /\s*file\s*=\s*(\S+)/
 
       
      def getPath(text,context)
        rootPath = $g_config['code_root_path'] || 'static'
        if text.start_with?("/")
          filePath = "#{text}"[1..-1].strip()
          filePath = File.expand_path(filePath)
        elsif  text.start_with?("@") 
          # _include/
          filePath = "#{text}"[1..-1].strip()


          site = context.registers[:site]
          user_include_path = File.join(site.source, "_includes", filePath)

          site = Jekyll.sites.first # 或你自己已有的 site
          theme = site.theme

          themeroot = theme.root # 就是当前主题的根目录
          plugin_include_file = File.join(themeroot, "_includes/" + filePath)

          if File.exist?(user_include_path)
            filePath = user_include_path
          elsif File.exist?(plugin_include_file)
            filePath = plugin_include_file
          else
            filePath = user_include_path
          end


        else
          filePath = "#{rootPath}/#{text}".strip()
          filePath = File.expand_path(filePath)
        end
        return filePath
      end
      def initialize(tag_name, text, tokens)

        @file = ""
        @dynamicFile = ""

        if text =~ Syntax
          dynfile = Regexp.last_match(1) 
          @dynamicFile = dynfile.gsub(/^['"]|['"]$/, '')
        else
          @filename = text.gsub(/^['"]|['"]$/, '')
        end
        
       
        
      end
      
      def render(context)
        filePath = @filename
        if @dynamicFile.length > 1
          filePath = context[@dynamicFile]
        end
        filePath = getPath(filePath,context)

        puts "include_raw :#{filePath} failed   #{@dynamicFile}"
        begin
          file = File.open(filePath)
          return file.read()
        rescue => exception
          puts exception
          return "Load file:#{filePath} failed   #{@dynamicFile}"
          
        end
      end
    end

    

    

  
  Liquid::Template.register_tag('asset_img', Jekyll::AssetImg)
  Liquid::Template.register_tag('include_code', Jekyll::IncludeCode)
  Liquid::Template.register_tag('include_raw', Jekyll::IncludeRaw)

  
  Liquid::Template.register_tag('post_link', Jekyll::PostLink)
  Liquid::Template.register_tag('img_link', Jekyll::ImgLink)
  Liquid::Template.register_tag('include_file', Jekyll::IncludeFile)

  
  


module Reading
  class Generator < Jekyll::Generator
    $auto_gen_tag_flag = 0
    def generate(site)
      $g_config = Jekyll::sites[0].config
      if !File.directory?("tags")
        Dir.mkdir "tags"
      end
      reading = site.tags.keys


      for tag in reading
        tagpath = "tags/#{tag}.md"
        if !File.file?(tagpath)
          $auto_gen_tag_flag += 1
          tagTmp = <<EOF
---
layout: tagpage
title: 'Tag: #{tag}'
tag: #{tag}
---
EOF

          File.open(tagpath , 'w+')  { |f| f.write(tagTmp) }
          print tagpath," "


        end


      end

    end
  end
end


 

  
     

  # Liquid::Template.register_filter(MyFilters)

 


  # Jekyll::Hooks.register :posts, :pre_render do |post|
  #   # code to call after Jekyll renders a page
  #   # site.pages.each { |pg| puts pg.url}
    

  #   puts post.url
  #   puts post["title"]
  #   puts "...."
  # end

  Jekyll::Hooks.register :site, :post_render do |st|
    # code to call after Jekyll renders a page
    rebuild = 0
    st.documents.each { |pg| 
      # puts "xx",pg.url,pg["title"]
      if $g_title_link[pg["title"]] == LOADINGFLG
        rebuild = 1
        # puts "post_link:#{pg["title"]} #{pg.url}"
        $g_title_link[pg["title"]] = pg.url
      end  
     }

    if rebuild == 1 || $auto_gen_tag_flag > 0
      puts "rebuild" , $auto_gen_tag_flag
      $auto_gen_tag_flag = 0
      st.process

    end


    
  end

  
  Jekyll::Hooks.register :site, :after_init do |st|
    # code to call after Jekyll renders a page


    assets = 'assets'
    
    if !Dir.exist?(assets)
      Dir.mkdir(assets)
    end 

    dynpath =  assets +'/dyn'
    puts dynpath
    if Dir.exist?(dynpath)
      FileUtils.rm_rf(dynpath)
    end 
    FileUtils.mkdir(dynpath)


    filename =  'index.html'
    if !File.file?(filename)
      tagTmp = "---\nlayout: paginate\n---"
      File.open(filename , 'w+')  { |f| f.write(tagTmp) }
      print 'generate ' + filename
    end 

    filename =  'HeatMap.md'
    if !File.file?(filename)
      tagTmp = "---\nlayout: heatmap\n---"
      File.open(filename , 'w+')  { |f| f.write(tagTmp) }
      print 'heatmpa ' + filename
    end 

    


  end

end