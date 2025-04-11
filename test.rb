#!/usr/bin/env ruby

require 'openssl'
require 'base64'
require_relative "lib/enc"
$Key = {}
def genKey(password)
    cache = $Key[password]
    if cache
        puts "cache",cache
        return cache
    end
    salt = 'this is a salt string 20221019'
    iter = 12345
    key_len = 32
    key = OpenSSL::KDF.pbkdf2_hmac(password, salt: salt, iterations: iter,
        length: key_len, hash: "sha256")
    $Key[password] = key
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


def decrypt(enstring,password)
    b64 = enstring[3..-1]
    data = Base64.strict_decode64 b64

    len = data.bytesize
    iv = data[0...12]
    auth_tag = data[0...16] #data[len-16..-1]
    encdata = data[12...len-16]


    cipher = OpenSSL::Cipher::AES.new(256, :GCM).decrypt
    cipher.iv = iv
    cipher.key = genKey password
    # cipher.auth_tag = '1234567890123456'
    
    result = cipher.update(encdata)
    return result 
    
end 




msg = '我的 12a23007'
z = encrypt msg,'123'
puts z 

puts z[3..-1]

m = decrypt z ,'123'
puts m

genKey '123'
genKey '123'
genKey '123'
genKey '456'
 
puts '---'
a = Jekyll::nmberToBinary4(256)
puts a.unpack1('H*')
a = a.bytes.map.each_with_index do |byte,i | byte ^ i 
end.pack('C*')
 
puts a.unpack1('H*') 

puts Jekyll::Test.encrypt_content_v2('333333a','00000000000000052f5c9b07ebc4464717978b174c440573df03e2962d98946c')
text = "oo"
if text.start_with?("/")
    puts "aaa"
else
    puts "bbb"
end

puts "12334"[1..2]
puts "12334"[1...2]
puts "12334"[1..-1]
puts "12334"[1...-1]