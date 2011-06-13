logger = Logger.new('log/mongodb.log')
MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, :logger => logger)
MongoMapper.database = "feedladder-production"