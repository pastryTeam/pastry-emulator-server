_ = require 'underscore'
encryptor = require './encryptor'

module.exports = class
  algList: ['none', 'des-ede3', '', '', 'rsa']
  hashList: ['none', 'md5', 'sha1']
  @getBusiness: (pkg, options) ->
    business = undefined
    try
      pkg = JSON.parse(pkg)
      business = pkg.dataPackage.business
      pkg.dataPackage.encryptFlag ||= pkg.dataPackage.cryptFlag
      if pkg.dataPackage.encryptFlag is 0
        business
      else
        business = encryptor.decrypt(@::algList[pkg.dataPackage.encryptFlag], business, options.key)
    catch e
      console.log e
    business
  constructor: (business, options) ->
    options = _.defaults {}, options,
      pkgFlag: 1
      errCode: 0
      errMsg: ''
      encryptFlag: 1
      hashFlag: 1
      signatureFlag: 0
    @pkgFlag = options.pkgFlag
    @errCode = options.errCode
    @errMsg = options.errMsg
    @crc = 0
    business = encryptor.encrypt(@algList[options.encryptFlag], JSON.stringify(business), options.key)
    @dataPackage =
      encryptFlag: options.encryptFlag
      cryptFlag: options.encryptFlag
      hashFlag: options.hashFlag
      signatureFlag: options.signatureFlag
      business: business
      hash: encryptor.hash(@hashList[options.hashFlag], business)