require 'openssl'
require 'base64'
require 'digest'
require 'ltec'
require "jekyll"
module Jekyll
  def test
  end
  class EncFilterTool
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
  module EncFilter

    def genKey(password)
      salt = 'this is a salt string 20221019'
      iter = 12345
      key_len = 32
      key = OpenSSL::KDF.pbkdf2_hmac(password, salt: salt, iterations: iter,
          length: key_len, hash: "sha256")
      return key
    end 

    def encrypt(msg,password)
      cipher = OpenSSL::Cipher::AES.new(256, :GCM).encrypt
      iv = cipher.random_iv
      cipher.iv = iv
      cipher.key = genKey password
      encrypted = cipher.update(msg) + cipher.final
      return  'E1.' + Base64.strict_encode64(iv  + encrypted + cipher.auth_tag)
      
    end 
    def get_encrypt_id(content,page)
      key = EncFilterTool.getKey(content,page)
      if key != nil && key.length > 0
        return OpenSSL::HMAC.hexdigest("SHA256", "no-style-please2-key-digst-2022-05-21", key.to_s)[0..32]
      else
        return ""
      end 
    end

    def  encrypt_content(content,page,prefix)
      psw = EncFilterTool.getKey(content,page)
      psw = prefix + psw + prefix
      return encrypt content,psw
    end

    
  end


Liquid::Template.register_filter(Jekyll::EncFilter)



def bin2hex(str)
  str.unpack('C*').map{ |b| "%02x" % b }.join('')
end

def hex2bin(str)
  [str].pack "H*"
end



end