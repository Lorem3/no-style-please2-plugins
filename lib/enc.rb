require 'openssl'
require 'base64'
require 'salsa20'
require 'digest'
require 'ltec'
require "jekyll"
module Jekyll
  def test
  end
  module EncFilter
    def getKey(content,page)
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
    def encrypt_if_need(content,page)
      key = getKey(content,page)
      r = key != nil && key.length > 0
      return r ? "1":""
    end

    def  contentEncrypt(content,page,prefix)
      keyOri = getKey(content,page)
      keyOri = prefix + keyOri + prefix
      key = Digest::MD5.hexdigest(keyOri).downcase()
      iv = Digest::MD5.hexdigest(content).downcase()
      ivHex = iv[0...16]
      iv = ivHex.scan(/../).map { |x| x.hex.chr }.join
      encryptor = Salsa20.new(key, iv)
      encrypted_text = encryptor.encrypt(content)
      return ivHex + ":" + Base64.strict_encode64(encrypted_text)
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