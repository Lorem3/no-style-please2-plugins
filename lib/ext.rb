require "jekyll"
require "liquid"

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
        @img_name =  text.strip
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
        return "![](#{link})" 
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
    

    
    class IncludeCode < Liquid::Tag
      @filecontent = ""
      def initialize(tag_name, text, tokens)

        rootPath = $g_config['code_root_path'] || 'static'
        filePath = "#{rootPath}/#{text}".strip!()
        begin
          file = File.open(filePath)
          @filecontent = file.read()
        rescue => exception
          puts exception
          @filecontent = "load file:#{text} failed"
          
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

    

    

  
  Liquid::Template.register_tag('asset_img', Jekyll::AssetImg)
  Liquid::Template.register_tag('include_code', Jekyll::IncludeCode)
  Liquid::Template.register_tag('post_link', Jekyll::PostLink)
  


module Reading
  class Generator < Jekyll::Generator
    def generate(site)
      $g_config = Jekyll::sites[0].config
      if !File.directory?("tags")
        Dir.mkdir "tags"
      end
      reading = site.tags.keys


      for tag in reading
        tagpath = "tags/#{tag}.md"
        if !File.file?(tagpath)
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
        puts "post_link:#{pg["title"]} #{pg.url}"
        $g_title_link[pg["title"]] = pg.url
      end  
     }

    if rebuild == 1
      puts "rebuild"
      st.process

    end


    
  end

end