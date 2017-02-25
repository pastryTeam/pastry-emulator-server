parser = require './common/parser'
http = require 'http'
express = require 'express'
httpProxy = require 'http-proxy'
session = require 'express-session'
cookieParser = require 'cookie-parser'
favicon = require 'serve-favicon'
paths = require './common/paths'

RES = require './common/response'

args = parser.parseArgs()
[ip, port] = args.server.split('\:')

PREFIX_PROXY = '/proxy/'
PREFIX_EMULATOR = '/emulator/'

rest = express()
server = http.createServer(rest)
rest.use cookieParser()

emulators = {}
store = new session.MemoryStore()
_destroy = store.destroy
store.destroy = (sessionId, callback) ->
  _destroy.call store, sessionId, callback
  delete emulators[sessionId]
  console.log 'session destroy ok.'
  return

rest.use favicon(paths.wwwroot('images', 'favicon.ico'))

rest.use session
  store: store
  resave: false
  saveUninitialized: false
  secret: 'keyboard cat'

Emulator = require './Emulator'

router = express.Router()
rest.use PREFIX_EMULATOR, router
router.route '/init?(*)'
.get (req, res) ->
  business = JSON.parse(req.query.data)
  emulator = req.session.emulator
  if emulator
    # 模拟器已启动，返回提示信息信息
    res.jsonp new RES.Success.Info('模拟器已经启动!')
  else
    # 模拟器未启动，创建新的模拟器
    emulator = emulators[req.sessionId] = new Emulator(
      server: args.server
      pubKey: paths.data('keystore', 'pastry_cert.pem')
    )
    handshakeData = business.handshakeData || {}
    emulator.init handshakeData, (error, data) ->
      if error
        res.jsonp new RES.Error.EmulatorInitFailedError(error)
      else
        req.session.emulator = 'mark'
        res.jsonp new RES.Success.Data(data)
      return
  return

router.route '/exit?(*)'
.get (req, res) ->
  req.session.destroy() if req.session.emulator
  res.jsonp new RES.Success.Info('模拟器已关闭.')
  return

router.route '/getPassword?(*)'
.get (req, res) ->
  business = JSON.parse(req.query.data)
  emulator = req.session.emulator
  if emulator
    text = business.text
    res.jsonp new RES.Success.Value(emulators[req.sessionId].getPassword text)
    return
  else
    res.jsonp new RES.Error.EmulatorNotInitError()
  return

router.route "#{PREFIX_PROXY}(*)"
.get (req, res) ->
  business = JSON.parse(req.query.data)
  emulator = req.session.emulator
  if emulator
    emulators[req.sessionId].send req.url[PREFIX_PROXY.length...req.url.indexOf('&data=')], business, (error, data) ->
      if error
        res.jsonp new RES.Error.EmulatorSendDataFailedError(error)
      else
        res.jsonp new RES.Success.Data(data)
      return
  else
    res.jsonp new RES.Error.EmulatorNotInitError()
  return

proxy = httpProxy.createProxyServer()

proxy.on 'proxyReq', (proxyReq, req, res, options) ->
  if args.verbose
    console.log '== start req headers =='
    console.log req.headers
    console.log '== end req headers =='
  return

proxy.on 'proxyRes', (proxyRes, req, res, options) ->
  buffer = new Buffer(0)
  proxyRes
  .on 'data', (chunk) ->
    buffer = Buffer.concat([buffer, chunk])
    return
  .on 'end', ->
    if args.verbose
      console.log '===='
      console.log buffer + ''
      console.log '===='
    return

  if proxyRes.headers['service-number']
    proxyRes.headers['Service-Number'] = proxyRes.headers['service-number']
    delete proxyRes.headers['service-number']

  if args.verbose
    console.log '== start res headers =='
    console.log proxyRes.headers
    console.log '== end res headers =='
  return

proxy.on 'error', (error) ->
  console.log "proxy error:#{error}"
  return

rest.use '/', (req, res) ->
  console.log 'proxy:' + req.url
  console.log 'proxy:' + args.server + req.url

  proxy.web(req, res,
    target: args.server
    changeOrigin: true
  )
  return

server.listen args.port1, args.addr, ->
  console.log "模拟器服务已启动[#{args.addr}:#{args.port1}] -> #{args.server}"
  return