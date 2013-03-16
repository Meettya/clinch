

packer.registerProcessor '.handelbar', (data, filename, cb) ->
  content = Handlebar.compile data
  res = "module.exports = #{content}"
  cb null, res