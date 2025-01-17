require 'openssl'
require 'base64'
require 'digest'
require 'ltec'
require "jekyll"
require "fileutils"
module Jekyll
  
  

  class EncFilterTool
    def EncFilterTool.getAllKey(page)
      site = Jekyll::sites[0]
      keys = []
      key = "#{page['key']}"
      if key != nil && key.length > 0
        keys << key
      end

     posttags = page["tags"]
     enctags = site.config['enc_tags']
     if posttags && posttags.length > 0 && enctags
       
       for tag in posttags
         for enctag in enctags
           if enctag['tag'] == tag 
             key = "#{enctag['password']}"
             keys << key
           end
         end
       end 
     end
     keys.map do |key| 
      if key.length > 50
        pubkey = ENV["JEKYLL_EC_PRIVATEKEY"]
        if pubkey == nil 
          raise 'JEKYLL_EC_PRIVATEKEY not set on envionment'
        end 
        key = Ltec::EC.decrypt(pubkey,key)

        if key == nil  || key.length == 0 
          raise "key decription fail"
        end
      end
      key
     end
    end
    def EncFilterTool.getKey(content,page)
      site = Jekyll::sites[0]
      key = "#{page['key']}"
      if key != nil
        key = "#{key}"
      end
      if !key || key.length == 0
          # find key for tag 
          posttags = page["tags"]
          enctags = site.config['enc_tags']
          if posttags && posttags.length > 0 && enctags
            
            for tag in posttags
              if key && key.length > 0
                break;
              end
              for enctag in enctags
                if enctag['tag'] == tag 
                  key = "#{enctag['password']}"
                  
                  break
                end
              end
            end 
          end
      end

      if !key
        return nil
      end

      if key.length > 50
        # the key is encrypt buy pulic key, 
        # we decrypt it with  privatekey on ENV

        pubkey = ENV["JEKYLL_EC_PRIVATEKEY"]
        if pubkey == nil 
          raise 'JEKYLL_EC_PRIVATEKEY not set on envionment'
        end 
        key = Ltec::EC.decrypt(pubkey,key)

        if key == nil  || key.length == 0 
          raise "key decription fail"
        end
      end

      return   "#{key}"
    end
  end
  # 大端模式
  def self.nmberToBinary4(num)
    [num].pack("N")[0, 4]
  end

  module EncFilter


    $KeyMap = {}
    def bin2hex(str)
      str.unpack('C*').map{ |b| "%02x" % b }.join('')
    end
  
    def self.hex2bin(str)
      [str].pack "H*"
    end
    def genKey(password)
      cacheKey = $KeyMap[password]
      if cacheKey
        return cacheKey
      end
      salt = 'this is a salt string 20221019'
      iter = 12345
      key_len = 32
      key = OpenSSL::KDF.pbkdf2_hmac(password, salt: salt, iterations: iter,
          length: key_len, hash: "sha256")
      $KeyMap[password] = key
      return key
    end 

    def encrypt(msg,password)
      cipher = OpenSSL::Cipher::AES.new(256, :GCM).encrypt
      iv = cipher.random_iv
      cipher.iv = iv
      cipher.key = genKey password
      encrypted = cipher.update(msg) + cipher.final
      return  'E2.' + Base64.strict_encode64(iv  + encrypted + cipher.auth_tag)
      
    end 
    def get_encrypt_id(content,page)
      key = EncFilterTool.getKey(content,page)
      if key != nil && key.length > 0
        enckey = genKey(key).unpack('H*').first 
        return OpenSSL::HMAC.hexdigest("SHA256", "no-style-please2-key-digst-2022-05-21", key.to_s + enckey)[0..32]
      else
        return ""
      end 
    end
    def  encrypt_content(content,page,prefix)
      psw = EncFilterTool.getKey(content,page)
      psw = prefix + psw + prefix
      return encrypt content,psw
    end

    def  write_file(new_content,file_path)

      dirpath  = File.dirname(file_path)
      File.dirname(dirpath)


      if File.exist?(file_path)
        # 读取现有文件内容
        current_content = File.read(file_path)
        # 如果内容不同，则写入新内容
        unless current_content == new_content
          File.write(file_path, new_content)
          puts "write file"  + file_path
        else
          puts "write file: same, skip " + file_path
        end
      else
        # 文件不存在，直接写入
        File.write(file_path, new_content)
        puts "write file"  + file_path
      end
      return ''
    end

    def rand_bytes(_,n2)
      return bin2hex(OpenSSL::Random.random_bytes(n2))
    end

    
    def encrypt_content_v2(content,pswHex)
      if !pswHex || pswHex.length != 64
        raise "invalid Key:" + pswHex
      end
      cipher = OpenSSL::Cipher::AES.new(256, :CTR).encrypt
      iv = cipher.random_iv
      cipher.iv = iv
      cipher.key = EncFilter.hex2bin(pswHex)
      encrypted = cipher.update(content) + cipher.final

      
      len = 4 +  iv.length + encrypted.length
      lenBf = Jekyll.nmberToBinary4(len)
      lenBf2 = lenBf.bytes.map.each_with_index do |v,i|
        z = i ^ iv.bytes[i ]
        v ^ z
      end.pack('C*')
      return   Base64.strict_encode64(lenBf2 + iv  + encrypted )
    end

    def encrypt_key(x,page,keyHex2Enc,encid)
      arr = EncFilterTool.getAllKey(page)
      newArr = arr.map do |k| 
        key = genKey  encid + k + encid
        hexKey = bin2hex key
        Base64.strict_decode64(encrypt_content_v2(EncFilter.hex2bin(keyHex2Enc),hexKey))
      end
      Base64.strict_encode64(newArr.join)
    end
    def gen_test_data_forkey(pswHex)
      rndBf = Base64.strict_encode64(EncFilter.hex2bin(rand_bytes('',63)))
      encData = encrypt_content_v2(rndBf,pswHex)
      rndBf + '.' + encData

    end
       
  end


Liquid::Template.register_filter(Jekyll::EncFilter)

class Test
  extend EncFilter
end



end