require 'openssl'
require 'base64'
require 'salsa20'
require 'digest'
require 'ltec'
require "jekyll"
module Jekyll
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

    def  contentEncrypt(content,page)
      keyOri = getKey(content,page)
      key = Digest::MD5.hexdigest(keyOri).downcase()
      iv = Digest::MD5.hexdigest(content).downcase()
      ivHex = iv[0...16]
      iv = ivHex.scan(/../).map { |x| x.hex.chr }.join
      encryptor = Salsa20.new(key, iv)
      encrypted_text = encryptor.encrypt(content)
      return ivHex + ":" + Base64.strict_encode64(encrypted_text)
    end

    
  end
end

Liquid::Template.register_filter(Jekyll::EncFilter)



def bin2hex(str)
  str.unpack('C*').map{ |b| "%02x" % b }.join('')
end

def hex2bin(str)
  [str].pack "H*"
end

# # modifies the final html page by encrypting its secure-container content
# Jekyll::Hooks.register :posts, :post_render do |post|
#   # puts "---------"
#   # puts post.site.config['enc_tags']
#   # puts post.data["tags"]
#   # puts post.data["key"]
#   # puts "<<<<<<<"

#   key = post.data["key"]
#   if key 
#     key = '' + key
#   end
#   if !key || key.length == 0
#     # find key for tag 
#     posttags = post.data["tags"]
#     enctags = post.site.config['enc_tags']
#     if posttags && posttags
#       for tag in posttags
#         if key && key.length > 0
#           break;
#         end
#         for enctag in enctags
#           if enctag['tag'] == tag 
#             key = enctag['password']
#             break
#           end
#         end
#       end 
#     end
#   end

  


#   if key && key.length
#     # prepare
#     key = post.data['key']  	
#     out = post.output

#     next
#     page = Nokogiri::HTML(out)
#     content = page.css('div#secure-container')[0].inner_html

#     # encrypt
#     aes = OpenSSL::Cipher.new('AES-256-CBC')
#     aes.encrypt	
#     salt = OpenSSL::Random.random_bytes(8)
#     iv = aes.random_iv
#     aes.key = Digest::SHA256.digest(key + bin2hex(salt))
#     aes.iv = iv
#     encrypted = bin2hex(aes.update(content) + aes.final).strip
  	
#     # save
#     page.css('div#secure-container')[0].inner_html = encrypted
#     post.output = page

#     # put iv and salt on page for decryption
#     page.css('div#crypt_params')[0].inner_html = "<script>var _gj = {salt: '"+bin2hex(salt)+"',  iv: '"+bin2hex(iv)+"' } </script>"

#   end
# end