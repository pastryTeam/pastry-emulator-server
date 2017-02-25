crypto = require 'crypto'
constants = require 'constants'

module.exports =
  encrypt: (alg, data, key, encode = 'base64') ->
    switch alg
      when 'none'
        data
      when 'rsa'
        blockSize = 256
        blockCount = data.length / blockSize
        ret = new Buffer(0)
        for i in [0...blockCount]
          buffer = new Buffer(data[blockSize * i...blockSize * (i + 1)])
          buffer = Buffer.concat([new Buffer(new Array(blockSize - buffer.length)),
                                  buffer]) if buffer.length < blockSize
          ret = Buffer.concat([ret, crypto.publicEncrypt(key: key, padding: constants.RSA_NO_PADDING, buffer)])
        ret.toString(encode)
      else
        cipher = crypto.createCipheriv(alg, new Buffer(key), new Buffer(0))
        ciph = cipher.update(data, 'utf8', encode)
        ciph += cipher.final(encode)
        ciph
  decrypt: (alg, data, key, encode = 'base64') ->
    switch alg
      when 'none'
        data
      when 'rsa-pub'
        ''
      else
        decipher = crypto.createDecipheriv(alg, new Buffer(key), new Buffer(0))
        deciph = decipher.update(data, encode, 'utf8')
        deciph += decipher.final('utf8')
        deciph
  hash: (alg, data, encode = 'base64') ->
    switch alg
      when 'none'
        undefined
      else
        h = crypto.createHash(alg)
        h.update(data)
        h.digest(encode)
  getRandom: (size = 16, encode = 'hex') -> crypto.randomBytes(size).toString(encode).toUpperCase()